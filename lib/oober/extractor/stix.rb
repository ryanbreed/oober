module Oober
  module Extractor
    class Stix < Hashie::Dash
      PARSE_OPTIONS=Nokogiri::XML::ParseOptions::DEFAULT_XML|Nokogiri::XML::ParseOptions::NOBLANKS

      property :data
      property :select

      def xml
        @xml ||= Nokogiri::XML(data,nil,nil,PARSE_OPTIONS)
      end

      def selected
        @selected ||= xml.xpath(self.select).to_a
      end

      def extract(type: 'xpath', origin: nil, target: nil)
        selected.flat_map {|n| [target.to_sym, n.send(type,origin).first.to_s.strip] }
      end
    end
  end
end
