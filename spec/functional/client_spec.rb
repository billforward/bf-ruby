require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward::Client do
	describe '#new' do
		before :all do
			@client = BillForwardTest::TEST_CLIENT
			BillForward::Client.default_client = @client
		end
		it "should find empty results upon looking up non-existent ID" do
			account_id = "nonexist"

			expect{BillForward::Account.get_by_id account_id}.to raise_error(IndexError)
		end
		it "should raise upon bad token" do
			host=@client.host
			token="badtoken"
			dudclient = BillForward::Client.new(
			    :host => host,
			    :api_token => token
				)
			expect{BillForward::Organisation.get_mine(nil,dudclient)}.to raise_error(BillForward::ApiAuthorizationError)
		end
	end
end