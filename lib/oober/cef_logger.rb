module Oober
  class CefLogger < Hashie::Dash
    property :feed_name
    property :feed_url
    property :indicator_type
    property :map_observables
    property :cef_type, default: 'CEF::Loggers::SyslogUdp'
    property :cef_config,
      required: true,
      message: 'needs to point to a valid CEF config'
    property :taxii_config,
      required: true,
      message: 'needs to point to a valid ruby-taxii PollClient config'

    def cef
      @cef ||= CEF.logger(config: cef_config, type: cef_type)
    end

    def taxii
      @taxii ||= Taxii.configure(config: taxii_config, client: Taxii::PollClient)
    end

    def request_message
      full_results = Taxii::Messages::Parameters::Poll.new(response_type: 'FULL')
      req = Taxii::Messages::PollRequest.new(collection_name: feed_name, poll_parameters: full_results)
      req.to_xml
    end

  end
end
