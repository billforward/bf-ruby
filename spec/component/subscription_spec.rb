require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward::Subscription do
   before :all do
   	@client = BillForwardTest::TEST_CLIENT
   	BillForward::Client.default_client = @client
   end
   before :each do
      # skip OAuth request
      allow_any_instance_of(BillForward::Client).to receive(:get_token).and_return('fake token')
   end

	describe '::get_by_id' do
		context 'where subscription exists' do
			describe 'the unserialized subscription' do
				let(:response) { double :response }
				let(:subscription_id) { 'ACD66517-6F32-44CB-AF8C-3097F97E1E67' }
				let(:subscription) { BillForward::Subscription.get_by_id(subscription_id) }

				before do
					allow(response).to receive(:to_str).and_return(canned_subscription_get)
					allow(RestClient::Request).to receive(:execute).and_return(response)
					# mainly just confirm that unserialization is reasonably healthy.
					expect(subscription.id).to eq(subscription_id)
				end

				describe '.to_ordered_hash' do
					context 'using array access' do
						it "has @type at top" do
							# check that @type is the first key on subscription (we use ordered hashes)
							payload = subscription.to_ordered_hash
							payload_first_kvp = payload.first
							kvp_key  = payload_first_kvp.first
							expect(kvp_key).to eq('@type')

							# check that @type is the first key on nested entities (we use ordered hashes)
							a_pricing_component = payload['productRatePlan']['pricingComponents'].first
							pricing_component_first_kvp = a_pricing_component.first
							kvp_key  = pricing_component_first_kvp.first
							expect(kvp_key).to eq('@type')
						end
					end
					context 'using dot access' do
						it "has @type at top" do
				            # check that @type is the first key on subscription (we use ordered hashes)
				            payload = subscription.to_ordered_hash
				            payload_first_kvp = payload.first
				            kvp_key  = payload_first_kvp.first
							expect(kvp_key).to eq('@type')

							# check that @type is the first key on nested entities (we use ordered hashes)
							a_pricing_component = payload.productRatePlan.pricingComponents.first
							pricing_component_first_kvp = a_pricing_component.first
							kvp_key  = pricing_component_first_kvp.first
							expect(kvp_key).to eq('@type')
						end

						it 'has product_id at the top' do
							expect(subscription.product_id).to eq("0CE0A471-A8B1-4E33-B5F4-115947DE8C55")
						end
					end
				end
				# NOTE: ideally no anonymous entity would exist, because we would register all known nested entities.
				# they're sort of a 'last resort' for when the API has more fields than we realized (ie version change, or lack of parity).
				# this test will soon self-deprecate, because we aim to register all entities that we support anyway.
				# more it exists to confirm the world works at the time of writing -- but it shouldn't be used as a lasting regression test,
				# since that means leaving known nested anonymous entities in on purpose!
				describe 'nested anonymous entity' do
					context 'using dot access' do
						it "can be read" do
							a_pricing_component = subscription.productRatePlan.pricingComponents.first
							expect(a_pricing_component.name).to eq('Devices used, fixed')
						end
						it "can be changed" do
							a_pricing_component = subscription.productRatePlan.pricingComponents.first
							expect(a_pricing_component.name).to eq('Devices used, fixed')

							new_name = 'bob'
							a_pricing_component.name = new_name
							expect(a_pricing_component.name).to eq(new_name)
							expect(subscription.productRatePlan.pricingComponents.first.name).to eq(new_name)
						end
					end
					context 'using array access' do
						it "can be read" do
							a_pricing_component = subscription['productRatePlan']['pricingComponents'].first
							expect(a_pricing_component['name']).to eq('Devices used, fixed')
						end
						it "can be changed" do
							a_pricing_component = subscription['productRatePlan']['pricingComponents'].first
							expect(a_pricing_component['name']).to eq('Devices used, fixed')

							new_name = 'bob'
							a_pricing_component.name = new_name
							expect(a_pricing_component['name']).to eq(new_name)
							expect(subscription['productRatePlan']['pricingComponents'].first['name']).to eq(new_name)
						end
					end
				end
			end
		end
	end
end

def canned_subscription_get
'{
   "executionTime" : 702594685,
   "results" : [ {
      "@type" : "subscription",
      "created" : "2014-09-24T17:21:02Z",
      "changedBy" : "System",
      "updated" : "2014-09-24T17:22:04Z",
      "id" : "ACD66517-6F32-44CB-AF8C-3097F97E1E67",
      "accountID" : "14384081-3A24-460A-AE67-40E0488B267A",
      "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
      "productID" : "0CE0A471-A8B1-4E33-B5F4-115947DE8C55",
      "productRatePlanID" : "BFE95484-D1D0-4296-ABB8-C2A3D4CE95EF",
      "name" : "Memorable Subscription",
      "description" : "Memorable Subscription Description",
      "type" : "Subscription",
      "state" : "Expired",
      "currentPeriodStart" : "2014-09-24T17:21:02Z",
      "currentPeriodEnd" : "2014-09-24T17:22:02Z",
      "subscriptionEnd" : "2014-09-24T17:22:02Z",
      "initialPeriodStart" : "2014-09-24T17:21:02Z",
      "successfulPeriods" : 1,
      "managedBy" : "BillForward",
      "productRatePlan" : {
         "created" : "2014-09-24T17:21:00Z",
         "changedBy" : "614E626E-72BF-4B69-B40E-0B72A1BB7CF4",
         "updated" : "2014-09-24T17:21:00Z",
         "id" : "BFE95484-D1D0-4296-ABB8-C2A3D4CE95EF",
         "productID" : "0CE0A471-A8B1-4E33-B5F4-115947DE8C55",
         "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
         "currency" : "USD",
         "taxStatus" : "inclusive",
         "proRataMode" : "WithCoupon",
         "name" : "A sound plan",
         "validFrom" : "2014-09-24T17:21:00Z",
         "taxation" : [ ],
         "fixedTermDefinitions" : [ ],
         "product" : {
            "created" : "2014-09-24T17:20:59Z",
            "changedBy" : "614E626E-72BF-4B69-B40E-0B72A1BB7CF4",
            "updated" : "2014-09-24T17:20:59Z",
            "id" : "0CE0A471-A8B1-4E33-B5F4-115947DE8C55",
            "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
            "name" : "Month of Paracetamoxyfrusebendroneomycin",
            "description" : "It can cure the common cold and being struck by lightning",
            "duration" : 1,
            "durationPeriod" : "minutes",
            "trial" : 0,
            "trialPeriod" : "none",
            "productType" : "non-recurring",
            "deleted" : false,
            "state" : "prod"
         },
         "pricingComponents" : [ {
            "@type" : "flatPricingComponent",
            "created" : "2014-09-24T17:21:01Z",
            "changedBy" : "614E626E-72BF-4B69-B40E-0B72A1BB7CF4",
            "updated" : "2014-09-24T17:21:01Z",
            "versionID" : "71753C8E-E477-4DF6-8C32-20FACA3E5B20",
            "id" : "71753C8E-E477-4DF6-8C32-20FACA3E5B20",
            "productRatePlanID" : "BFE95484-D1D0-4296-ABB8-C2A3D4CE95EF",
            "unitOfMeasureID" : "6EB5B013-AFD3-4FC6-BDED-73FC681F23EE",
            "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
            "name" : "Devices used, fixed",
            "description" : "How many devices you use, I guess",
            "chargeType" : "subscription",
            "chargeModel" : "flat",
            "upgradeMode" : "immediate",
            "downgradeMode" : "immediate",
            "defaultQuantity" : 1,
            "minQuantity" : 0,
            "validFrom" : "2014-09-24T17:21:00Z",
            "tiers" : [ {
               "created" : "2014-09-24T17:21:01Z",
               "changedBy" : "614E626E-72BF-4B69-B40E-0B72A1BB7CF4",
               "id" : "EA6A046F-B436-4D5F-A4CE-14638E2A574C",
               "pricingComponentVersionID" : "71753C8E-E477-4DF6-8C32-20FACA3E5B20",
               "pricingComponentID" : "71753C8E-E477-4DF6-8C32-20FACA3E5B20",
               "productRatePlanID" : "BFE95484-D1D0-4296-ABB8-C2A3D4CE95EF",
               "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
               "lowerThreshold" : 1,
               "upperThreshold" : 1,
               "pricingType" : "fixed",
               "price" : 1.00000
            } ],
            "unitOfMeasure" : {
               "created" : "2014-09-24T17:20:58Z",
               "changedBy" : "614E626E-72BF-4B69-B40E-0B72A1BB7CF4",
               "updated" : "2014-09-24T17:20:58Z",
               "id" : "6EB5B013-AFD3-4FC6-BDED-73FC681F23EE",
               "name" : "Devices",
               "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
               "displayedAs" : "Devices",
               "roundingScheme" : "UP",
               "deleted" : false
            }
         }, {
            "@type" : "tieredPricingComponent",
            "created" : "2014-09-24T17:21:01Z",
            "changedBy" : "614E626E-72BF-4B69-B40E-0B72A1BB7CF4",
            "updated" : "2014-09-24T17:21:01Z",
            "versionID" : "C37D16B1-5E39-4B75-BEC0-03AB4085941E",
            "id" : "C37D16B1-5E39-4B75-BEC0-03AB4085941E",
            "productRatePlanID" : "BFE95484-D1D0-4296-ABB8-C2A3D4CE95EF",
            "unitOfMeasureID" : "6EB5B013-AFD3-4FC6-BDED-73FC681F23EE",
            "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
            "name" : "Devices used, tiered",
            "description" : "How many devices you use, but with a tiering system",
            "chargeType" : "usage",
            "chargeModel" : "tiered",
            "upgradeMode" : "immediate",
            "downgradeMode" : "immediate",
            "defaultQuantity" : 10,
            "minQuantity" : 0,
            "validFrom" : "2014-09-24T17:21:00Z",
            "tiers" : [ {
               "created" : "2014-09-24T17:21:01Z",
               "changedBy" : "614E626E-72BF-4B69-B40E-0B72A1BB7CF4",
               "id" : "7B86D8A6-CFB1-4CD9-B438-617F4E060C3A",
               "pricingComponentVersionID" : "C37D16B1-5E39-4B75-BEC0-03AB4085941E",
               "pricingComponentID" : "C37D16B1-5E39-4B75-BEC0-03AB4085941E",
               "productRatePlanID" : "BFE95484-D1D0-4296-ABB8-C2A3D4CE95EF",
               "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
               "lowerThreshold" : 2,
               "upperThreshold" : 10,
               "pricingType" : "unit",
               "price" : 5.00000
            }, {
               "created" : "2014-09-24T17:21:01Z",
               "changedBy" : "614E626E-72BF-4B69-B40E-0B72A1BB7CF4",
               "id" : "B3E8C950-A71E-434D-8988-1F964430768B",
               "pricingComponentVersionID" : "C37D16B1-5E39-4B75-BEC0-03AB4085941E",
               "pricingComponentID" : "C37D16B1-5E39-4B75-BEC0-03AB4085941E",
               "productRatePlanID" : "BFE95484-D1D0-4296-ABB8-C2A3D4CE95EF",
               "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
               "lowerThreshold" : 1,
               "upperThreshold" : 1,
               "pricingType" : "fixed",
               "price" : 10.00000
            }, {
               "created" : "2014-09-24T17:21:01Z",
               "changedBy" : "614E626E-72BF-4B69-B40E-0B72A1BB7CF4",
               "id" : "D05839BB-8E35-48FD-AB66-F1CDF0E59D9C",
               "pricingComponentVersionID" : "C37D16B1-5E39-4B75-BEC0-03AB4085941E",
               "pricingComponentID" : "C37D16B1-5E39-4B75-BEC0-03AB4085941E",
               "productRatePlanID" : "BFE95484-D1D0-4296-ABB8-C2A3D4CE95EF",
               "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
               "lowerThreshold" : 11,
               "upperThreshold" : 100,
               "pricingType" : "unit",
               "price" : 2.00000
            } ],
            "unitOfMeasure" : {
               "created" : "2014-09-24T17:20:58Z",
               "changedBy" : "614E626E-72BF-4B69-B40E-0B72A1BB7CF4",
               "updated" : "2014-09-24T17:20:58Z",
               "id" : "6EB5B013-AFD3-4FC6-BDED-73FC681F23EE",
               "name" : "Devices",
               "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
               "displayedAs" : "Devices",
               "roundingScheme" : "UP",
               "deleted" : false
            }
         } ]
      },
      "pricingComponentValueChanges" : [ ],
      "pricingComponentValues" : [ {
         "created" : "2014-09-24T17:21:02Z",
         "changedBy" : "614E626E-72BF-4B69-B40E-0B72A1BB7CF4",
         "updated" : "2014-09-24T17:21:02Z",
         "id" : "29F353B6-BE3E-4E31-8E26-84F70F3FB0F3",
         "pricingComponentID" : "71753C8E-E477-4DF6-8C32-20FACA3E5B20",
         "subscriptionID" : "ACD66517-6F32-44CB-AF8C-3097F97E1E67",
         "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
         "value" : 1
      }, {
         "created" : "2014-09-24T17:21:02Z",
         "changedBy" : "614E626E-72BF-4B69-B40E-0B72A1BB7CF4",
         "updated" : "2014-09-24T17:21:02Z",
         "id" : "8597315B-A9F7-45C4-B145-DF6584528B02",
         "pricingComponentID" : "C37D16B1-5E39-4B75-BEC0-03AB4085941E",
         "subscriptionID" : "ACD66517-6F32-44CB-AF8C-3097F97E1E67",
         "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
         "value" : 5
      } ],
      "paymentMethodSubscriptionLinks" : [ {
         "created" : "2014-09-24T17:21:02Z",
         "changedBy" : "614E626E-72BF-4B69-B40E-0B72A1BB7CF4",
         "updated" : "2014-09-24T17:21:02Z",
         "id" : "1A89116E-D17D-4610-B139-6E4559CC85FD",
         "subscriptionID" : "ACD66517-6F32-44CB-AF8C-3097F97E1E67",
         "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
         "paymentMethodID" : "612D5A60-4F6A-455D-9C03-685A6D96A8D4",
         "deleted" : false,
         "paymentMethod" : {
            "created" : "2014-09-24T17:20:56Z",
            "changedBy" : "614E626E-72BF-4B69-B40E-0B72A1BB7CF4",
            "updated" : "2014-09-24T17:20:56Z",
            "id" : "612D5A60-4F6A-455D-9C03-685A6D96A8D4",
            "accountID" : "14384081-3A24-460A-AE67-40E0488B267A",
            "organizationID" : "7F3D3A3C-BAA4-4698-9645-EC33F853B3D8",
            "name" : "Credit Notes",
            "description" : "Pay using credit",
            "linkID" : "",
            "gateway" : "credit_note",
            "priority" : 100,
            "userEditable" : false,
            "reusable" : true,
            "deleted" : false
         }
      } ],
      "fixedTerms" : [ ]
   } ]
}'
end
