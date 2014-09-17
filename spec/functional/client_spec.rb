require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward::Client
	describe '#new' do
		before :all do
			@client = BillForwardTest::TEST_CLIENT
		end
		it "should find empty results upon looking up non-existent ID" do
			account_id = "nonexist"

			expect{@client.get_first "accounts/#{account_id}"}.to raise_error(IndexError)
		end
	end
end