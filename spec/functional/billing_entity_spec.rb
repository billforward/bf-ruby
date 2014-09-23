require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward::BillingEntity do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::get_all' do
		context 'with query parameters' do
			it "should allow number of records to be specified" do
				records = BillForward::Account.get_all({
					'records' => 1
					})

				puts records
				# expect{BillForward::Account.get_by_id account_id}.to raise_error(IndexError)
			end
		end
	end
end