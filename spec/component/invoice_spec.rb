require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward::Invoice do
   before :all do
   	@client = BillForwardTest::TEST_CLIENT
   	BillForward::Client.default_client = @client
   end
   before :each do
      # skip OAuth request
      allow_any_instance_of(BillForward::Client).to receive(:get_token).and_return('fake token')
   end
	describe '::get_by_id' do
		context 'where invoice exists' do
			it "gets the invoice" do
            invoice_id = 'BAE03D0F-68B6-46AA-B5D5-26BD83453C05'

            response = double
            allow(response).to receive(:to_str).and_return(canned_invoice_get)
            allow(RestClient::Request).to receive(:execute).and_return(response)

            invoice = BillForward::Invoice.get_by_id invoice_id

            expect(invoice.id).to eq(invoice_id)
			end
		end
	end
end

def canned_invoice_get
'{
   "nextPage" : "/invoices/BAE03D0F-68B6-46AA-B5D5-26BD83453C05?format=JSON&offset=10&records=10&include_retired=true&order_by=created&order=DESC",
   "totalPages" : 1,
   "currentPage" : 1,
   "currentOffset" : 0,
   "recordsRequested" : 10,
   "recordsReturned" : 1,
   "totalRecords" : 1,
   "executionTime" : 3729707,
   "results" : [ {
      "@type" : "invoice",
      "created" : "2014-09-23T16:36:32Z",
      "changedBy" : "System",
      "updated" : "2014-09-23T16:36:34Z",
      "versionID" : "BAE03D0F-68B6-46AA-B5D5-26BD83453C05",
      "id" : "BAE03D0F-68B6-46AA-B5D5-26BD83453C05",
      "subscriptionID" : "94956988-697E-4D06-8466-59F42255FECD",
      "accountID" : "C82E3F28-0831-4F37-BDA3-8BF3D924E54B",
      "organizationID" : "F60667D7-583A-4A01-B4DC-F74CC45ACAE3",
      "state" : "Paid",
      "periodStart" : "2014-09-23T16:36:28Z",
      "periodEnd" : "2014-10-21T16:36:28Z",
      "deleted" : false,
      "totalExecutionAttempts" : 1,
      "lastExecutionAttempt" : "2014-09-23T16:36:34Z",
      "nextExecutionAttempt" : "2014-09-23T16:36:28Z",
      "finalExecutionAttempt" : "2014-09-23T16:36:34Z",
      "paymentReceived" : "2014-09-23T16:36:34Z",
      "currency" : "USD",
      "costExcludingTax" : 31.00,
      "invoiceCost" : 31.00,
      "invoicePaid" : 0.00,
      "discountAmount" : 0.00,
      "invoiceRefunded" : 0.00,
      "type" : "Subscription",
      "managedBy" : "BillForward",
      "initialInvoice" : true,
      "versionNumber" : 1,
      "invoiceLines" : [ {
         "created" : "2014-09-23T16:36:32Z",
         "changedBy" : "System",
         "updated" : "2014-09-23T16:36:32Z",
         "id" : "0E0DC183-11BA-493C-86E1-E245726184A2",
         "invoiceID" : "BAE03D0F-68B6-46AA-B5D5-26BD83453C05",
         "unitOfMeasureID" : "FC015845-E829-4100-949F-44F3F2C63587",
         "unitOfMeasure" : {
            "created" : "2014-09-23T16:36:02Z",
            "changedBy" : "7872F2F4-ED96-4038-BC82-39F7DDFECE60",
            "updated" : "2014-09-23T16:36:02Z",
            "id" : "FC015845-E829-4100-949F-44F3F2C63587",
            "name" : "Devices",
            "organizationID" : "F60667D7-583A-4A01-B4DC-F74CC45ACAE3",
            "displayedAs" : "Devices",
            "roundingScheme" : "UP",
            "deleted" : false
         },
         "organizationID" : "F60667D7-583A-4A01-B4DC-F74CC45ACAE3",
         "name" : "Devices used, tiered",
         "description" : "How many devices you use, but with a tiering system",
         "calculation" : "1 items at flat cost 10.00000\t4 items at 5.00000 each, cost 20.00000\t",
         "cost" : 30.00,
         "tax" : 0.00,
         "componentValue" : 5
      }, {
         "created" : "2014-09-23T16:36:32Z",
         "changedBy" : "System",
         "updated" : "2014-09-23T16:36:32Z",
         "id" : "D0349A38-067F-49CA-A756-A4C545A443EB",
         "invoiceID" : "BAE03D0F-68B6-46AA-B5D5-26BD83453C05",
         "unitOfMeasureID" : "FC015845-E829-4100-949F-44F3F2C63587",
         "unitOfMeasure" : {
            "created" : "2014-09-23T16:36:02Z",
            "changedBy" : "7872F2F4-ED96-4038-BC82-39F7DDFECE60",
            "updated" : "2014-09-23T16:36:02Z",
            "id" : "FC015845-E829-4100-949F-44F3F2C63587",
            "name" : "Devices",
            "organizationID" : "F60667D7-583A-4A01-B4DC-F74CC45ACAE3",
            "displayedAs" : "Devices",
            "roundingScheme" : "UP",
            "deleted" : false
         },
         "organizationID" : "F60667D7-583A-4A01-B4DC-F74CC45ACAE3",
         "name" : "Devices used, fixed",
         "description" : "How many devices you use, I guess",
         "calculation" : "Items at flat cost 1.00000\t",
         "cost" : 1.00,
         "tax" : 0.00,
         "componentValue" : 1
      } ],
      "taxLines" : [ ],
      "invoicePayments" : [ {
         "created" : "2014-09-23T16:36:34Z",
         "changedBy" : "System",
         "updated" : "2014-09-23T16:36:34Z",
         "id" : "FCB1FF2C-84FC-417D-A9DB-77D899842C7E",
         "paymentID" : "AD677566-5D58-4E1D-9D56-03C83F2BB987",
         "invoiceID" : "BAE03D0F-68B6-46AA-B5D5-26BD83453C05",
         "organizationID" : "F60667D7-583A-4A01-B4DC-F74CC45ACAE3",
         "currency" : "USD",
         "nominalAmount" : 31.00,
         "actualAmount" : 0.00,
         "refundedAmount" : 0.00,
         "payment" : {
            "@type" : "creditNotePayment",
            "created" : "2014-09-23T16:36:34Z",
            "changedBy" : "System",
            "updated" : "2014-09-23T16:36:34Z",
            "id" : "AD677566-5D58-4E1D-9D56-03C83F2BB987",
            "paymentMethodID" : "A1F0B567-1E63-4A22-9B6C-0C81A7E7F709",
            "invoiceID" : "BAE03D0F-68B6-46AA-B5D5-26BD83453C05",
            "organizationID" : "F60667D7-583A-4A01-B4DC-F74CC45ACAE3",
            "gateway" : "credit_note",
            "currency" : "USD",
            "nominalValue" : 31.00,
            "actualValue" : 0.00,
            "remainingNominalValue" : 0.00,
            "paymentReceived" : "2014-09-23T16:36:34Z",
            "refundedValue" : 0.00,
            "type" : "debit"
         }
      } ],
      "invoiceRefunds" : [ ],
      "invoiceCreditNotes" : [ ]
   } ]
}'
end