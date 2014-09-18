require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "spec_helper")

describe BillForward::Account do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::create' do
		context 'upon creating minimal account' do
			before :all do
				@created_account = BillForward::Account.create
			end
			subject (:account) { @created_account }
			it "can get property" do
				expect(account['@type']).to eq(BillForward::Account.resource_path.entity_name)
			end
		end
		context 'upon creating account with profile' do
			email = 'always@testing.is.moe'
			before :all do
				profile = BillForward::Profile.new({
					'email' => email,
  					'firstName' => 'Test',
					})
				account = BillForward::Account.new({
					'profile' => profile
					})
				@created_account = BillForward::Account.create account
			end
			subject (:account) { @created_account }
			it "can get property" do
				expect(account['@type']).to eq(BillForward::Account.resource_path.entity_name)
			end
			it "has profile" do
				profile = account.get_profile
				expect(profile.email).to eq(email)
			end
		end
	end
end