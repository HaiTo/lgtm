# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lgtm/version'

Gem::Specification.new do |spec|
  spec.name          = 'lgtm'
  spec.version       = Lgtm::VERSION
  spec.authors       = ['HaiTo']
  spec.email         = ['kimura@sansan.com']

  spec.summary       = 'fetch image url in lgtm.in'
  spec.description   = 'fetch image url in lgtm.in to pbcopy'
  spec.homepage      = 'https://github.com/haito/lgtm'

  spec.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) {|f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_dependency 'mechanize'
  spec.add_dependency 'thor'
end
