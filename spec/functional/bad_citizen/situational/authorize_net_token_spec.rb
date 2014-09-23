require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "..", "spec_helper")

describe BillForward::AuthorizeNetToken do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client

		# Authorize.Net credentials used to test adding a tokenized card
		@authorize_net_customer_profile_id = BillForwardTest::AUTHORIZE_NET_CUSTOMER_PROFILE_ID
		@authorize_net_customer_payment_profile_id = BillForwardTest::AUTHORIZE_NET_CUSTOMER_PAYMENT_PROFILE_ID
		@authorize_net_card_last_4_digits = BillForwardTest::AUTHORIZE_NET_CARD_LAST_4_DIGITS
	end
	describe '::create' do
		it 'creates a token' do
			created_account = BillForward::Account.create

			authorize_net_token = BillForward::AuthorizeNetToken.new({
				'accountID' => created_account.id,
				'customerProfileID' => @authorize_net_customer_profile_id,
				'customerPaymentProfileID' => @authorize_net_customer_payment_profile_id,
				'lastFourDigits' => @authorize_net_card_last_4_digits,
				})

			created_token = BillForward::AuthorizeNetToken.create(authorize_net_token)
		end
	end
end