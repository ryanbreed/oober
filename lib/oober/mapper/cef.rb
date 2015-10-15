module Oober
  module Mapper
    class Cef < Hashie::Dash
      def self.map_extract(data)
        CEF::Event.new(data)
      end
    end
  end
end
