module Oober
  class Cli < Thor
    class_option :config, default: File.join(ENV['HOME'],'.oober.json')

    desc 'poll_feed', 'poll a feed/exporter configuration'
    def poll_feed
      oob=Oober.configure(options[:config])
      oob.extract_blocks.each do |ext|
        e = CEF::Event.new(ext)
        oob.cef.emit(e)
        puts e.to_cef
      end
    end

    desc 'download_feed', 'download raw data for a feed/exporter config'
    option :dir, default: 'tmp'
    def download_feed
      oob=Oober.configure(options[:config])
      data_blocks = oob.get_content_blocks
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
  end
end
