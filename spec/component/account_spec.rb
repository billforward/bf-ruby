require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward::Account do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::get_by_id' do
		before :each do
			allow_any_instance_of(BillForward::Client).to receive(:get_token).and_return('fake token')
		end
		context 'account does not exist' do
			let(:RestClient)      { double :RestClient }
			it "should get empty list" do
  				account_id = "74DA7D63-EAEB-431B-9745-76F9109FD842"

  				response = double
			    allow(response).to receive(:to_str).and_return(canned_noresults)
			    allow(RestClient).to receive(:get).and_return(response)

  				expect{BillForward::Account.get_by_id account_id}.to raise_error(IndexError)
  			end
  		end
  		context 'account exists' do
  			it "should get the account" do
  				account_id = "74DA7D63-EAEB-431B-9745-76F9109FD842"

  				response = double
			    allow(response).to receive(:to_str).and_return(canned_account)
			    allow(RestClient).to receive(:get).and_return(response)

			    account = BillForward::Account.get_by_id account_id

  				expect(account['id']).to eq('74DA7D63-EAEB-431B-9745-76F9109FD842')
  			end
		end
	end
end

def canned_noresults
'{
  "executionTime": 1070093,
  "results": []
}'
end

def canned_account
'{
  "executionTime": 1070093,
  "results": [
    {
      "successfulSubscriptions": 0,
      "@type": "account",
      "roles": [

      ],
      "profile": {
        "firstName": "Test",
        "addresses": [
          {
            "landline": "02000000000",
            "addressLine3": "address line 3",
            "addressLine2": "address line 2",
            "addressLine1": "address line 1",
            "country": "United Kingdom",
            "deleted": false,
            "city": "London",
            "profileID": "1B07A310-8B0F-4CFA-B2CF-48D206DC79C3",
            "id": "34B5A980-A133-4B5F-9045-F1A41F20F2D6",
            "primaryAddress": true,
            "province": "London",
            "created": "2014-09-04T17:43:44Z",
            "postcode": "SW1 1AS",
            "changedBy": "7872F2F4-ED96-4038-BC82-39F7DDFECE60",
            "organizationID": "F60667D7-583A-4A01-B4DC-F74CC45ACAE3"
          }
        ],
        "id": "1B07A310-8B0F-4CFA-B2CF-48D206DC79C3",
        "updated": "2014-09-04T17:43:44Z",
        "email": "always@testing.is.moe",
        "created": "2014-09-04T17:43:44Z",
        "changedBy": "7872F2F4-ED96-4038-BC82-39F7DDFECE60",
        "organizationID": "F60667D7-583A-4A01-B4DC-F74CC45ACAE3",
        "accountID": "74DA7D63-EAEB-431B-9745-76F9109FD842"
      },
      "deleted": false,
      "crmID": null,
      "id": "74DA7D63-EAEB-431B-9745-76F9109FD842",
      "updated": "2014-09-04T17:43:43Z",
      "created": "2014-09-04T17:43:43Z",
      "paymentMethods": [

      ],
      "changedBy": "7872F2F4-ED96-4038-BC82-39F7DDFECE60",
      "organizationID": "F60667D7-583A-4A01-B4DC-F74CC45ACAE3"
    }
  ]
}'
end