module Oober
  class CefLogger < Hashie::Dash
    property :feed_name

    property :exporter
    property :extractor

    property :extractor_configs, default: []

    property :export_config,
      required: true,
      message: 'needs to point to a valid CEF config'
    property :taxii_config,
      required: true,
      message: 'needs to point to a valid ruby-taxii PollClient config'

    def event_defaults
      @event_defaults ||= {
        name: self.feed_name,
        deviceProduct: self.class.name,
        deviceVersion: Oober::VERSION,
        receiptTime: Time.new
      }.merge(Hashie.symbolize_keys(export_defaults))
    end

    def poll_messages
      extract_blocks.each do |ext|
        cef.emit(CEF::Event.new(ext))
      end
    end

    def cef
      @cef ||= CEF.logger(export_config)
    end

    def taxii
      @taxii ||= Taxii::PollClient.new(taxii_config)
    end

    def transform_extracts(events=extract)
      events.map {|e| CEF::Event.new(e) }
    end

    def extractor_pipeline(blocks=get_blocks)
      extractors = blocks.flat_map do |block|
        extractor_configs.map { |conf| extractor.new(conf.merge(data: block)) }
      end
      extractors.reject {|ext| ext.selected.empty? }
    end

    def extract_blocks(blocks=get_blocks)
      extractor_pipeline(blocks).flat_map(&:extract)
    end

    def get_blocks
      taxii.get_content_blocks(self.request_message)
    end

    def request_message
      full_results = Taxii::Messages::Parameters::Poll.new(response_type: 'FULL')
      req = Taxii::Messages::PollRequest.new(collection_name: feed_name, poll_parameters: full_results)
      req.to_xml
    end

  end
end
