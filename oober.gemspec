# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oober/version'

Gem::Specification.new do |spec|
  spec.name          = 'oober'
  spec.version       = Oober::VERSION
  spec.authors       = ['rbreed']
  spec.email         = ['rbreed@ercot.com']

  spec.summary       = %q{ like taxii but easier }
  spec.description   = %q{ taxii-cef gateway }
  spec.homepage      = 'https://github.com/ryanbreed/oober'


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'cef'
  spec.add_dependency 'hashie'
  spec.add_dependency 'ruby-taxii'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'simplecov'

end
