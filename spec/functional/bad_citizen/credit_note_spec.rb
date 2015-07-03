require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "spec_helper")

describe BillForward::CreditNote do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::create' do
		context 'account exists' do
			context 'account has credit note payment method' do
				before :all do
					@created_account = BillForward::Account.create

					# account implicitly has these nowadays
					# payment_method = BillForward::PaymentMethod.new({
					# 	'accountID' => @created_account.id,
					# 	'name' => 'Credit Notes',
					# 	'description' => 'Pay using credit',
					# 	# engines will link this to an invoice once paid, for the sake of refunds
					# 	'linkID' => '',
					# 	'gateway' => 'credit_note',
					# 	'userEditable' => 0,
					# 	'priority' => 100,
					# 	'reusable' => 1
					# 	})
					# created_payment_method = BillForward::PaymentMethod::create(payment_method)
				end
				subject (:account) { @created_account }
				it 'issues credit' do
					credit_note = BillForward::CreditNote.new({
						"accountID" => account.id,
					    "value" => 15,
					    "currency" => "USD"
						})
					created_credit_note = BillForward::CreditNote.create(credit_note)

					expect(created_credit_note['@type']).to eq(BillForward::CreditNote.resource_path.entity_name)
				end
			end
		end
	end
end