module Oober
  class CefLogger < Hashie::Dash
    property :feed_name
    property :mapper
    property :exporter
    property :extractor
    property :select
    property :extract_mappings
    
    property :export_config,
      required: true,
      message: 'needs to point to a valid CEF config'
    property :taxii_config,
      required: true,
      message: 'needs to point to a valid ruby-taxii PollClient config'

    def event_defaults
      @event_defaults ||= {
        name: self.feed_name,
        deviceProduct: 'oober',
        receiptTime: Time.new
      }
    end

    def poll_messages
      event_data = extract
      cef_events = map_extracts(event_data)
      cef.emit(*cef_events)
    end

    def cef
      @cef ||= CEF.configure(export_config)
    end

    def taxii
      @taxii ||= Taxii.configure(config: taxii_config, client: Taxii::PollClient)
    end

    def map_extracts(events=extract)
      events.map {|e| mapper.map_extract(event_defaults.merge(e))}
    end

    def extract
      get_content_blocks.map {|b| extractor.new(data: b, select: self.select)}
                        .reject {|e| e.selected.empty? }
                        .map {|e| Hash[extract_mappings.map {|m| e.extract(m)}]}
    end

    def get_content_blocks
      taxii.get_content_blocks(self.request_message)
    end

    def request_message
      full_results = Taxii::Messages::Parameters::Poll.new(response_type: 'FULL')
      req = Taxii::Messages::PollRequest.new(collection_name: feed_name, poll_parameters: full_results)
      req.to_xml
    end

  end
end
