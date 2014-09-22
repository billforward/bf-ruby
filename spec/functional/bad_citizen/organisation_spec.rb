require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "spec_helper")

describe BillForward::Organisation do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client

		# Authorize.Net credentials used to test adding a payment gateway
		@authorize_net_login_id = BillForwardTest::AUTHORIZE_NET_LOGIN_ID
		@authorize_net_transaction_key = BillForwardTest::AUTHORIZE_NET_TRANSACTION_KEY
	end
	describe '.api_configurations' do
		it "can be updated" do
			organisations = BillForward::Organisation.get_mine
			first_org = organisations.first

			configs = first_org.apiConfigurations

			## remove all existing AuthorizeNetConfigurations (if any)
			## Wait, actually this is a bad idea, since some payment method might be using them..
			# filtered = configs.reject do |config|
			# 	config['@type'] == 'AuthorizeNetConfiguration'
			# end

			# first_org.api_configurations = filtered


			#add a new AuthorizeNetConfiguration
			new_configuration = BillForward::APIConfiguration.new({
				 "@type" =>          "AuthorizeNetConfiguration",
			     "APILoginID" =>     @authorize_net_login_id,
			     "transactionKey" => @authorize_net_transaction_key,
			     "environment" =>    "Sandbox"
				})

			first_org.apiConfigurations.push(new_configuration)

			puts first_org
			# updated_org = first_org.save

			# added_config = updated_org.apiConfigurations.last
			# expect(added_config.APILoginID).to eq(@authorize_net_login_id)
		end
	end
end