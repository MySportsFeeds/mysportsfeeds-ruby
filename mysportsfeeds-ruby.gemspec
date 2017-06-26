# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mysportsfeeds/version"

Gem::Specification.new do |spec|
  spec.name          = "mysportsfeeds-ruby"
  spec.version       = Mysportsfeeds::Ruby::VERSION
  spec.authors       = ["MySportsFeeds", "Brad Barkhouse"]
  spec.email         = ["brad.barkhouse@mysportsfeeds.com"]
  spec.required_ruby_version = '>= 2.2.0'

  spec.summary       = "MySportsFeeds API Ruby Client"
  spec.description   = "Easily retrieve sports data from the MySportsFeeds API"
  spec.homepage      = "https://github.com/MySportsFeeds/mysportsfeeds-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fileutils", "~> 0.7"
  spec.add_runtime_dependency "json", "~> 2.1"
  spec.add_runtime_dependency "base64", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
end
