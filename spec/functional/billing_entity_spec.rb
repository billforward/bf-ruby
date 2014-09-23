require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward::BillingEntity do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::get_all' do
		context 'with query parameters' do
			it "should allow number of records to be specified" do
				# ensure that at least one account exists in addition to our login
				BillForward::Account.create

				records = BillForward::Account.get_all({
					'records' => 1
					})

				expect(records.length).to eq(1)
			end
		end
	end
end