#require 'spec_helper'
require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward do
	describe 'ApiClient' do
		describe '#new' do
			before :each do
				BILLFORWARD_API_HOST="http://localhost:8080/RestAPI/"
				BILLFORWARD_ENVIRONMENT="development"
				BILLFORWARD_API_TOKEN="bfe56132-6439-4dda-8b4f-e130f569b768"
				@client = BillForward::ApiClient.new(
				    :host => BILLFORWARD_API_HOST,
				    :environment => BILLFORWARD_ENVIRONMENT,
				    :api_token => BILLFORWARD_API_TOKEN
					)
			end
  			it "should complain upon looking up non-existent ID" do
  				subscription_id = "where_the_subscription_at"
  				subscription = @client.get_first "subscriptions/#{subscription_id}"
  			end
  		end
	end
end