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
  spec.description   = %q{<p><code>mvcoffee-rails</code> is a Rails gem that makes it easy to use the 
<a href="https://github.com/kirkbowers/mvcoffee">MVCoffee</a> client-side MVC framework in your
Rails project.</p>

<p>The full documentation for this gem is at <a href="http://mvcoffee.org/mvcoffee-rails">mvcoffee.org</a>.</p>
}
  spec.summary       = %q{The server-side Rails gem that makes it easy to use the 
MVCoffee client-side MVC framework in your
Rails project.  Full documentation is at mvcoffee.org.}
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
