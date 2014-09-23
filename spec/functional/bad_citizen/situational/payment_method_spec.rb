require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "..", "spec_helper")

describe BillForward::PaymentMethod do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client

		# Authorize.Net credentials used to test tokenizing a card
		@authorize_net_customer_profile_id = BillForwardTest::AUTHORIZE_NET_CUSTOMER_PROFILE_ID
		@authorize_net_customer_payment_profile_id = BillForwardTest::AUTHORIZE_NET_CUSTOMER_PAYMENT_PROFILE_ID
		@authorize_net_card_last_4_digits = BillForwardTest::AUTHORIZE_NET_CARD_LAST_4_DIGITS
	end
	describe '::create' do
		context 'account exists' do
			context 'using Authorize.Net payment gateway' do
				before :all do
					@created_account = BillForward::Account.create
					authorize_net_token = BillForward::AuthorizeNetToken.new({
						'accountID' => @created_account.id,
						'customerProfileID' => @authorize_net_customer_profile_id,
						'customerPaymentProfileID' => @authorize_net_customer_payment_profile_id,
						'lastFourDigits' => @authorize_net_card_last_4_digits,
						})

					@created_token = BillForward::AuthorizeNetToken.create(authorize_net_token)
				end
				subject (:token) { @created_token }
				subject (:account) { @created_account }
				it 'creates a payment method' do
					payment_method = BillForward::PaymentMethod.new({
						'accountID' => account.id,
						'linkID' => token.id,
						'name' => 'Authorize.Net',
						'description' => 'Pay via Authorize.Net',
						'gateway' => 'authorizeNet',
						'userEditable' => 0,
						'priority' => 100,
						'reusable' => 1,
						})
					created_payment_method = BillForward::PaymentMethod::create(payment_method)

					expect(created_payment_method['@type']).to eq(BillForward::PaymentMethod.resource_path.entity_name)
				end
			end
		end
	end
end