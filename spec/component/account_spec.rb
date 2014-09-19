require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward::Account do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
  before :each do
    # skip OAuth request
    allow_any_instance_of(BillForward::Client).to receive(:get_token).and_return('fake token')
  end
	describe '::get_by_id' do
		context 'where account does not exist' do
			let(:RestClient)      { double :RestClient }
			it "gets empty list" do
				response = double
		    allow(response).to receive(:to_str).and_return(canned_noresults)
		    allow(RestClient::Request).to receive(:execute).and_return(response)

				expect{BillForward::Account.get_by_id 'anything'}.to raise_error(IndexError)
			end
  	end
		context 'where account exists' do
			it "gets the account" do
        account_id = '74DA7D63-EAEB-431B-9745-76F9109FD842'

				response = double
		    allow(response).to receive(:to_str).and_return(canned_account_get)
		    allow(RestClient::Request).to receive(:execute).and_return(response)

		    account = BillForward::Account.get_by_id account_id

				expect(account.id).to eq(account_id)
			end
		end
	end
  describe '::create' do
    context 'upon creating minimal account' do
      let(:RestClient)      { double :RestClient }
      it "can get property" do
        response = double
        allow(response).to receive(:to_str).and_return(canned_account_create_minimal)
        allow(RestClient::Request).to receive(:execute).and_return(response)

        created_account = BillForward::Account.create
        expect(created_account['@type']).to eq(BillForward::Account.resource_path.entity_name)
      end
    end
    context 'upon creating account with profile' do
      let(:RestClient)      { double :RestClient }
      email = 'always@testing.is.moe'
      before :each do
        profile = BillForward::Profile.new({
          'email' => email,
            'firstName' => 'Test',
          })
        account = BillForward::Account.new({
          'profile' => profile
          })
        response = double
        allow(response).to receive(:to_str).and_return(canned_account_create_with_profile)
        allow(RestClient::Request).to receive(:execute).and_return(response)

        @created_account = BillForward::Account.create account
      end
      subject (:account) { @created_account }
      it "can get property" do
        expect(account['@type']).to eq(BillForward::Account.resource_path.entity_name)
      end
      it "has profile" do
        profile = account.get_profile
        expect(profile.email).to eq(email)
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

def canned_account_create_with_profile
'{
  "results": [
    {
      "profile": {
        "accountID": "5037E4EF-9DD1-4BC3-8920-425D9159C41A",
        "updated": "2014-09-18T22:29:15.079Z",
        "email": "always@testing.is.moe",
        "organizationID": "F60667D7-583A-4A01-B4DC-F74CC45ACAE3",
        "id": "C7A63931-709D-4F1A-B8F9-B5EC0E6C2D29",
        "created": "2014-09-18T22:29:15.079Z",
        "addresses": [

        ],
        "firstName": "Test",
        "changedBy": "7872F2F4-ED96-4038-BC82-39F7DDFECE60"
      },
      "updated": "2014-09-18T22:29:14.783Z",
      "deleted": false,
      "organizationID": "F60667D7-583A-4A01-B4DC-F74CC45ACAE3",
      "id": "5037E4EF-9DD1-4BC3-8920-425D9159C41A",
      "crmID": null,
      "created": "2014-09-18T22:29:14.783Z",
      "roles": [

      ],
      "paymentMethods": [

      ],
      "successfulSubscriptions": 0,
      "changedBy": "7872F2F4-ED96-4038-BC82-39F7DDFECE60",
      "@type": "account"
    }
  ],
  "executionTime": 647946
}'
end

def canned_account_create_minimal
'{
  "results": [
    {
      "updated": "2014-09-18T18:27:22.258Z",
      "changedBy": "7872F2F4-ED96-4038-BC82-39F7DDFECE60",
      "id": "904DAE81-B63C-4F25-86C5-E1A1CDCEEB88",
      "@type": "account",
      "deleted": false,
      "successfulSubscriptions": 0,
      "organizationID": "F60667D7-583A-4A01-B4DC-F74CC45ACAE3",
      "crmID": null,
      "paymentMethods": [

      ],
      "created": "2014-09-18T18:27:22.258Z",
      "roles": [

      ]
    }
  ],
  "executionTime": 492653
}'
end

def canned_account_get
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