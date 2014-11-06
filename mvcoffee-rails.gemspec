# coding: utf-8
# lib = File.expand_path('../lib', __FILE__)
# $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
$:.push File.expand_path("../lib", __FILE__)

require 'mvcoffee/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "mvcoffee-rails"
  spec.version       = Mvcoffee::Rails::VERSION
  spec.authors       = ["Kirk Bowers"]
  spec.email         = ["kirkbowers@yahoo.com"]
  spec.description   = %q{I'll say something here eventually}
  spec.summary       = %q{Here too.}
  spec.homepage      = "https://github.com/kirkbowers/mvcoffee-rails"
  spec.license       = "MIT"

  spec.files         = Dir["{lib,app}/**/*"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_path  = "lib"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", ">= 0"

  spec.required_rubygems_version = ">= 1.3.6"

  spec.add_dependency "railties", ">= 3.2.16"
  
  spec.require_path = "lib"
end
