require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "..", "spec_helper")

describe BillForward::Invoice do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client

		# Existing invoice supplied from test constants, as we cannot create invoices ourselves
		@invoice_id = BillForwardTest::USUAL_INVOICE_ID
	end
	subject (:invoice_id) { @invoice_id }
	describe '::get_by_id' do
		context 'where invoice exists' do
			it "gets the invoice" do
	            invoice = BillForward::Invoice.get_by_id invoice_id

	            expect(invoice.id).to eq(invoice_id)
	            expect(invoice['@type']).to eq(BillForward::Invoice.resource_path.entity_name)
			end
		end
	end
end