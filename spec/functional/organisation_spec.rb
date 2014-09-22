require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward::Account do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::get_all' do
		it 'raises permissions error' do
			# 'admin' privilege is insufficient to see other organisations
			expect{BillForward::Organisation::get_all}.to raise_error(BillForward::ApiError, /415/)
		end
	end
	describe '::get_mine' do
		it "should find organisations" do
			organisations = BillForward::Organisation.get_mine
			organisations_first = organisations.first

			expect(organisations_first['@type']).to eq(BillForward::Organisation.resource_path.entity_name)
		end
	end
end