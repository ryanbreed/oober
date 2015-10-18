require 'ipaddr'
require 'hashie'
require 'taxii'
require 'cef'
require 'json'
require 'thor'

require 'oober/version'
require 'oober/cef_logger'
require 'oober/extractor/stix'

module Oober
  def self.configure(path=File.join(ENV['HOME'],'.oober.json'))
    configuration   = JSON.parse(File.read(path))
    export_klass    = Module.const_get(configuration.delete('exporter'))
    extractor_klass = Module.const_get(configuration.delete('extractor'))
    export_klass.new(
      Hashie.symbolize_keys(configuration)
            .merge( extractor: extractor_klass)
    )
  end
end
