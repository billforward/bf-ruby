require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward::BillingEntity do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	before :each do
  		# skip OAuth request
		allow_any_instance_of(BillForward::Client).to receive(:get_token).and_return('fake token')
	end
	context 'upon getting entity' do
		before :each do
			response = double
		    allow(response).to receive(:to_str).and_return(canned_entity)
		    allow(RestClient::Request).to receive(:execute).and_return(response)

		    @entity = BillForward::Account.get_by_id 'anything'
		end
		subject (:entity) { @entity }
		context 'using dot syntax' do
			it "can get property" do
				expect(entity.id).to eq('74DA7D63-EAEB-431B-9745-76F9109FD842')
			end
			it "can change property" do
				newid = 'whatever'
				entity.id = newid
				expect(entity.id).to eq(newid)
			end
			it "can add property" do
				value = 'whatever'
				entity.fun = value
				expect(entity.fun).to eq(value)
			end
			describe 'nested array of entities' do
				context 'once unserialized' do
					subject :roles do
						roles = entity.roles
					end
					subject :role do
						roles.first
					end
					it 'is an array' do
						expect(roles.class).to eq(Array)
					end
					describe 'some element' do
						it 'is an entity' do
							expect(role.class).to eq(BillForward::Role)
						end
						it 'has expected properties' do
							expect(role.role).to eq('user')
						end
						it 'has mutable properties' do
							expect(role.role).to eq('user')
							new_role = 'abuser'
							role.role = new_role
							expect(role.role).to eq(new_role)
						end
					end
				end
			end
			describe 'nested entity' do
				context 'once unserialized' do
					subject :profile do
						profile = entity.profile
					end
					it 'is an entity' do
						expect(profile.class).to eq(BillForward::Profile)
					end
					it 'has expected properties' do
						expect(profile.firstName).to eq('Test')
					end
					it 'has mutable properties' do
						expect(profile.firstName).to eq('Test')
						new_name = 'Best'
						profile.firstName = new_name
						expect(profile.firstName).to eq(new_name)
					end
				end
			end
		end
		context 'using array access syntax' do
			it "can get property" do
				expect(entity['@type']).to eq('account')
			end
			it "can change property" do
				newid = 'notever'
				entity['id'] = newid
				expect(entity['id']).to eq(newid)
			end
		end

		describe '#_dump' do
			it 'uses to_json to dump the entity' do
				expect(entity._dump(1)).to eq(entity.to_json)
			end
		end

		describe '._load' do
			it 'successfully loads the dumped data' do
				expect(described_class._load(entity._dump(1)).to_json).to eq(entity.to_json)
			end
		end
	end
end

def canned_entity
'{
  "executionTime": 1070093,
  "results": [
    {
      "successfulSubscriptions": 0,
      "@type": "account",
      "roles": [
      	{
	      "id": "B4E623C2-2CE0-11E3-894A-FA163E717A7F",
	      "accountID": "74DA7D63-EAEB-431B-9745-76F9109FD842",
	      "role": "user",
	      "created": "2014-09-04T17:43:44Z",
	      "changedBy": "7872F2F4-ED96-4038-BC82-39F7DDFECE60"
	    }
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
