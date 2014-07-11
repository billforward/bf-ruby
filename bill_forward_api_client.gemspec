# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bill_forward_api_client/version'

Gem::Specification.new do |spec|
  spec.name          = "bill_forward_api_client"
  spec.version       = BillForwardApiClient::VERSION
  spec.authors       = ["BillForward"]
  spec.email         = ["support@billforward.net"]
  spec.summary       = "BillForward Rest API Client"
  spec.description   = "Work in Progress"
  spec.homepage      = "http://www.billforward.net"
  spec.license       = "NONE"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
