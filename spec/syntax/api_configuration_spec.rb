require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward::Profile do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::create' do
		it 'raises error' do
			expect{BillForward::APIConfiguration.create}.to raise_error(BillForward::DenyMethod)
		end
	end
end