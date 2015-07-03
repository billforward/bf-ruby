require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "spec_helper")

describe BillForward::PaymentMethod do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	skip '::create' do
		context 'account exists' do
			context 'using credit' do
				before :all do
					@created_account = BillForward::Account.create
				end
				subject (:account) { @created_account }
				it 'creates a payment method' do
					payment_method = BillForward::PaymentMethod.new({
						'accountID' => account.id,
						'name' => 'Credit Notes',
						'description' => 'Pay using credit',
						# engines will link this to an invoice once paid, for the sake of refunds
						'linkID' => '',
						'gateway' => 'credit_note',
						'userEditable' => 0,
						'priority' => 100,
						'reusable' => 1
						})
					created_payment_method = BillForward::PaymentMethod::create(payment_method)

					expect(created_payment_method['@type']).to eq(BillForward::PaymentMethod.resource_path.entity_name)
				end
			end
		end
	end
end