require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward::Address do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::get_by_id' do
		it 'raises error' do
			id = 'whatever'
			expect{BillForward::Address.get_by_id id}.to raise_error(BillForward::DenyMethod)
		end
	end
	describe '::get_all' do
		it 'raises error' do
			expect{BillForward::Address.get_all}.to raise_error(BillForward::DenyMethod)
		end
	end
end