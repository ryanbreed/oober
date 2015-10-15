module Oober
  class Cli < Thor
    class_option :config, default: File.join(ENV['HOME'],'.oober.json')

    desc 'poll_feed', 'poll a feed/exporter configuration'
    def poll_feed
      oob=Oober.configure(options[:config])
      oob.poll_messages
    end

  end
end