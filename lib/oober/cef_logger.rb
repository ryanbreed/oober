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
    def check_taxii
      taxii.poll_service_available?
    end

    def get_feed
      full_results = Taxii::Messages::Parameters::Poll.new(response_type: 'FULL')
      taxii.poll_feed(collection_name: feed_name, poll_parameters: full_results)
    end

    def stix_package_type(package)
      package['Content']['STIX_Package'].keys.reject {|k| k.match(%r{\A(@|STIX_Header)})}.pop
    end

    def feed_exists?
      get_feed_info!=nil
    end

    def get_feed_info
      taxii.discover_feeds.find {|feed| feed['@feed_name']==feed_name }
    end
  end
end
