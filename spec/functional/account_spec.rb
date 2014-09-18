require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward::Account do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::get_by_id' do
		context 'upon looking up non-existent ID' do
			it "should find empty results" do
				account_id = "nonexist"

				expect{BillForward::Account.get_by_id account_id}.to raise_error(IndexError)
			end
		end
	end
end