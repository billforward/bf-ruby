require 'bundler/setup'
Bundler.setup

require 'bill_forward' # and any other gems you need

# this file provides constants for tests to share
require File.join(File.expand_path(File.dirname(__FILE__)), "setup_test_constants")

RSpec.configure do |config|
  # some (optional) config here
end