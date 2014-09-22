require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "spec_helper")

describe BillForward::Subscription do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	context 'upon creating required entities for chargeable Subscription' do
		before :all do
			# get our organisation
			organisations = BillForward::Organisation.get_mine
			first_org = organisations.first


			# remove from our organisation all existing AuthorizeNetConfigurations (if any)
			filtered = first_org.apiConfigurations.reject do |config|
				config['@type'] == 'AuthorizeNetConfiguration'
			end
			first_org.apiConfigurations = filtered


			# add to our organisation: a new AuthorizeNetConfiguration
			first_org.apiConfigurations.push BillForward::APIConfiguration.new({
				 "@type" =>          "AuthorizeNetConfiguration",
			     "APILoginID" =>     @authorize_net_login_id,
			     "transactionKey" => @authorize_net_transaction_key,
			     "environment" =>    "Sandbox"
				})
			updated_org = first_org.save


			# create a default account
			created_account = BillForward::Account.create account


			# create for our account: a tokenized card from Authorize.Net
			authorize_net_token = BillForward::AuthorizeNetToken.new({
				'accountID' => created_account.id,
				'customerProfileID' => @authorize_net_customer_profile_id,
				'customerPaymentProfileID' => @authorize_net_customer_payment_profile_id,
				'lastFourDigits' => @authorize_net_card_last_4_digits,
				})
			created_token = BillForward::AuthorizeNetToken.create(authorize_net_token)


			# create for our account: a new payment method, using Authorize.Net token
			payment_method = BillForward::PaymentMethod.new({
				'accountID' => created_account.id,
				'linkID' => created_token.id,
				'name' => 'Authorize.Net',
				'description' => 'Pay via Authorize.Net',
				'gateway' => 'authorizeNet',
				'userEditable' => 0,
				'priority' => 100,
				'reusable' => 1,
				})
			created_payment_method = BillForward::PaymentMethod::create(payment_method)


			# create a unit of measure
			unit_of_measure = BillForward::UnitOfMeasure.new({
				'name' => 'Devices',
				'displayedAs' => 'Devices',
				'roundingScheme' => 'UP',
				})
			created_uom = BillForward::UnitOfMeasure.create(unit_of_measure)


			
		end
		describe '::create' do
			it 'creates Subscription' do
			end
		end
	end
end