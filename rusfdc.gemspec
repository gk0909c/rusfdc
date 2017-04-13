# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rusfdc/version'

Gem::Specification.new do |spec|
  spec.name          = 'rusfdc'
  spec.version       = Rusfdc::VERSION
  spec.authors       = ['gk0909c']
  spec.email         = ['gk0909c@gmail.com']

  spec.summary       = 'RUby SFDC operation'
  spec.description   = 'salesforce api operation client'
  spec.homepage      = 'https://github.com/gk0909c/rusfdc.git'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`
                       .split("\x0")
                       .reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'thor', '~> 0.19'
  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.48'
end
