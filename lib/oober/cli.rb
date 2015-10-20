module Oober
  class Cli < Thor
    no_tasks do
      def name_of(node)
        if node.nil?
          "NIL"
        elsif node.namespace.nil?
          node.name
        else
          format('%s:%s',node.namespace.prefix, node.name)
        end
      end

      def children_of(node)
        node.children.to_a.map {|e| name_of(e)}
      end

      def print_nodes(xmls, query, separator)
        xmls.each do |filename, xml|
          begin
            [*xml.xpath(query)].each_with_index do |node,index|
              puts format(separator,filename,index)
              puts node.to_s
            end
          rescue Nokogiri::XML::XPath::SyntaxError => err
          end
        end
      end

      def save_nodes(xmls, query, dir)
        xmls.each do |filename, xml|
          begin
            # TODO: this is probably wrong
            [*xml.xpath(q)].each_with_index do |node,index|
              puts format(options[:separator],filename,index)
              fname = File.join(dir,format('saved_%012d.xml',index))
              File.open(fname,'w') {|f| f.puts node.children.first.to_s } 
            end
          rescue Nokogiri::XML::XPath::SyntaxError => err
          end
        end
      end

      def list_children(xmls, query)
        puts 'Children: '
        nodes = xmls.values.flat_map do |doc|
          begin 
            doc.xpath(query).to_a
          rescue Nokogiri::XML::XPath::SyntaxError => err
            []
          end
        end
        counts = nodes.flat_map {|node| children_of(node)}
                      .reduce(Hash.new(0)) {|h,name| h[name]+= 1 ; h }
        puts counts
      end

      def uniq_values(xmls, query)
        nodes = xmls.values.flat_map do |doc|
          begin 
            doc.xpath(query).to_a
          rescue Nokogiri::XML::XPath::SyntaxError => err
            []
          end
        end
        counts = nodes.flat_map {|node| node.to_s}
                      .reduce(Hash.new(0)) {|h,name| h[name]+= 1 ; h }
        puts JSON.pretty_generate(counts)
      end
    end

    class_option :config, default: File.join(ENV['HOME'],'.oober.json')

    desc 'poll', 'poll a feed/exporter configuration'
    option :warn, type: :boolean, default: false
    def poll(config=nil)
      oob=Oober.configure(config || options[:config])
      errored_blocks = []      
      oob.extract_blocks.each do |extracted_hash|
        begin
          event = CEF::Event.new(extracted_hash)
          oob.cef.emit(event)
        rescue Exception  => exception
          if options[:warn]
            errored_blocks.push([extracted_hash,exception])
          end
        else
          puts event.to_cef
        end
        errored_blocks.each do |blk|
          event, error = blk
          STDERR.puts "ERROR: #{error.to_s}"
          STDERR.puts "ERRORED MESSAGE: #{JSON.pretty_generate(event)}"
        end
      end
    end

    desc 'download', 'download raw data for a feed/exporter config'
    option :dir, default: 'tmp'
    def download(config=nil)
      oob=Oober.configure(config || options[:config])
      data_blocks = oob.get_blocks
      data_blocks.each_with_index do |block,index|
        filename = format('%s_%08d.%08d.xml',
                          oob.feed_name,
                          Time.new.to_i,
                          index)
        file_path = File.join(options[:dir],filename)
        FileUtils.mkdir_p(options[:dir]) unless Dir.exist?(options[:dir])
        puts "downloading package #{index} to #{file_path}"
        File.open(file_path, 'w') do |file|
          file.puts(block)
        end
      end
    end

    desc 'console', 'interactive pry session'
    def console(config=nil)
      config_file = config || options[:config]
      Pry.config.pager=false
      if File.exist?(config_file)
        begin
          client = Oober.configure(config_file)
          console_config_name = File.basename(config_file).gsub(/\.json$/,'')
          Pry.config.prompt_name= console_config_name
          puts 'your oober client is in the local variable "client"'
        rescue JSON::ParserError => e
          puts "invalid config #{config_file}"
        end
      else
        Pry.config.prompt_name='no config'
      end
      binding.pry
    end

    desc 'xpath FILE(s)', 'interactively test XPath queries against FILE(s)'
    option :dir, default: 'tmp'
    option :separator, type: :string, default: '----%s/%d----'
    def xpath(*files)
      xmls=files.map do |filename|
        filedata = File.read(filename)
        Nokogiri::XML(filedata,nil,nil,Nokogiri::XML::ParseOptions::DEFAULT_XML|Nokogiri::XML::ParseOptions::NOBLANKS)
      end

      file_xmls=Hash[files.zip(xmls)]

      while query_line = Readline.readline(format('XPath Query[%d]> ',files.size), true)
        if matched = query_line.match(%r{\A(children|save|uniq) (.*)})
          cmd   = matched[1]
          query = matched[2]
        else
          query = query_line
          cmd   = 'print'
        end

        case cmd
          when /print/
            print_nodes(file_xmls, query, options[:separator])
          when /save/
            save_nodes(file_xmls, query, options[:dir])
          when /children/
            list_children(file_xmls, query)
          when /uniq/
            uniq_values(file_xmls, query)
          else
            puts "unknown operation: #{cmd}"
        end

      end
    end
  end
end
