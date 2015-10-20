def list_children(node)
  puts 'Children: '
  grouped = node.children.group_by {|n| name_of(n)}
  puts grouped.map {|n,c| format('%s: %d',n,c.size) }.join(', ')
end

def name_of(node)
  format('%s:%s',node.namespace.prefix, node.name)
end

module Oober
  class Cli < Thor
    class_option :config, default: File.join(ENV['HOME'],'.oober.json')

    desc 'poll_feed', 'poll a feed/exporter configuration'
    option :warn, type: :boolean, default: false
    def poll_feed
      oob=Oober.configure(options[:config])
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

    desc 'download_feed', 'download raw data for a feed/exporter config'
    option :dir, default: 'tmp'
    def download_feed
      oob=Oober.configure(options[:config])
      data_blocks = oob.get_blocks
      data_blocks.each_with_index do |block,index|
        filename = format('%s_%08d.%08d.xml',
                          oob.feed_name,
                          Time.new.to_i,
                          index)
        file_path = File.join(options[:dir],filename)
        FileUtils.mkdir_p(options[:dir]) unless Dir.exist?(options[:dir])
        File.open(file_path, 'w') do |file|
          file.puts(block)
        end
      end
    end

    desc 'console', 'interactive pry session'
    def console
      if File.exist?(options[:config])
        begin
          client = Oober.configure(options[:config]) 
          puts 'your oober client is in the local variable "client"'
        rescue JSON::ParserError => e
          puts "invalid config #{options[:config]}"
        end
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

      while query = Readline.readline(format('XPath Query[%d]> ',files.size), true)
        if matched = query.match(%r{\A(children|save) (.*)})
          cmd   = matched[1]
          query = matched[2]
        else
          q   = query
          cmd = nil
        end

        file_xmls.each do |filename, xml|
          begin
            [*xml.xpath(q)].each_with_index do |node,index|
              puts format(options[:separator],filename,index)
              case cmd
                when nil
                  puts node.to_s
                when /save/
                  fname = File.join(options[:dir],format('saved_%012d.xml',index))
                  File.open(fname,'w') {|f| f.puts node.children.first.to_s }
                when /children/
                  list_children(node)
                else
                  puts "unknown operation: #{cmd}"
              end
            end
          rescue Nokogiri::XML::XPath::SyntaxError => e
            #puts "could not get #{q}"
          end
        end
      end
    end
  end
end