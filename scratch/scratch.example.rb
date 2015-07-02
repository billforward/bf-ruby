require 'bundler/setup'
require 'bill_forward'

my_client = BillForward::Client.new(
    :host =>      "API URL goes here",
    :api_token => "API token goes here"
)
BillForward::Client.default_client = my_client
