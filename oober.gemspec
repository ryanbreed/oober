# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oober/version'

Gem::Specification.new do |spec|
  spec.name          = 'oober'
  spec.version       = Oober::VERSION
  spec.authors       = ['Ryan Breed']
  spec.email         = ['opensource@breed.org']

  spec.summary       = %q{ simplified interface for polling TAXII services and exporting structured data }
  spec.description   = %q{ flexible TAXII client for integrating cyber threat information with all your stuff }
  spec.homepage      = 'https://github.com/ryanbreed/oober'


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'hashie',     '~> 3.4'
  spec.add_dependency 'thor',       '~> 0.19'
  spec.add_dependency 'cef',        '~> 2.1'
  spec.add_dependency 'ruby-taxii', '0.3.1'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'simplecov'

end
