require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "..", "spec_helper")

describe BillForward::InvoiceRecalculationAmendment do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client

		# Existing invoice supplied from test constants, as we cannot create invoices ourselves
		@invoice_id = BillForwardTest::USUAL_INVOICE_ID
	end
	describe '#new' do
		before :all do
			invoice = BillForward::Invoice.get_by_id @invoice_id
			@invoice = invoice
		end
		subject (:invoice) { @invoice }
		it "can be created" do
			amendment = BillForward::InvoiceRecalculationAmendment.new({
					'subscriptionID' => invoice.subscriptionID,
					'invoiceID' => invoice.id,
					'newInvoiceState' => 'Paid'
				})

			created_amendment = BillForward::InvoiceRecalculationAmendment.create(amendment)
		end
	end
end