require 'ipaddr'
require 'hashie'
require 'taxii'
require 'cef'
require 'json'

require 'oober/version'
require 'oober/cef_logger'
require 'oober/extractor/stix'
require 'oober/mapper/cef'

module Oober
  def self.configure(path=File.join(ENV['HOME'],'.oober.json'))
    configuration   = JSON.parse(File.read(path))
    export_klass    = Module.const_get(configuration.delete('exporter'))
    mapper_klass    = Module.const_get(configuration.delete('mapper'))
    extractor_klass = Module.const_get(configuration.delete('extractor'))
    export_klass.new(
      Hashie.symbolize_keys(configuration)
            .merge( extractor: extractor_klass, mapper: mapper_klass)
    )
  end
end
