require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "spec_helper")
# we want unique numbers to test updates with
require 'SecureRandom'

describe BillForward::Subscription do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::get_by_account_id' do
		context 'an account exists' do
			before :all do
				created_account = BillForward::Account.create


				# create references for tests to use
				@created_account = created_account
			end
			context 'all entities required for a subscription exist' do
				before :all do
					# create a unit of measure
					unit_of_measure = BillForward::UnitOfMeasure.new({
						'name' => 'Devices',
						'displayedAs' => 'Devices',
						'roundingScheme' => 'UP',
						})
					created_uom = BillForward::UnitOfMeasure.create(unit_of_measure)


					# create a product
					product = BillForward::Product.new({
						'productType' => 'non-recurring',
						'state' => 'prod',
						'name' => 'Month of Paracetamoxyfrusebendroneomycin',
						'description' => 'It can cure the common cold and being struck by lightning',
						'durationPeriod' => 'minutes',
						'duration' => 1,
						})
					created_product = BillForward::Product::create(product)


					# make product rate plan..
					# requires:
					# - product,
					# - pricing components..
					# .. - which require pricing component tiers

					# create tiers..
					# for a flat pricing component:
					tiers_for_flat_component_1 = Array.new()
					tiers_for_flat_component_1.push(
						BillForward::PricingComponentTier.new({
							'lowerThreshold' => 1,
							'upperThreshold' => 1,
							'pricingType' => 'fixed',
							'price' => 1,
						}))

					# for a tiered pricing component:
					tiers_for_tiered_component_1 = Array.new()
					tiers_for_tiered_component_1.push(
						BillForward::PricingComponentTier.new({
							'lowerThreshold' => 1,
							'upperThreshold' => 1,
							'pricingType' => 'fixed',
							'price' => 10,
						}),
						BillForward::PricingComponentTier.new({
							'lowerThreshold' => 2,
							'upperThreshold' => 10,
							'pricingType' => 'unit',
							'price' => 5
						}),
						BillForward::PricingComponentTier.new({
							'lowerThreshold' => 11,
							'upperThreshold' => 100,
							'pricingType' => 'unit',
							'price' => 2
						}))


					# create pricing components, based on these tiers
					pricing_components = Array.new()
					pricing_components.push(
						BillForward::PricingComponent.new({
							'@type' => 'flatPricingComponent',
							'chargeModel' => 'flat',
							'name' => 'Devices used, fixed',
							'description' => 'How many devices you use, I guess',
							'unitOfMeasureID' => created_uom.id,
							'chargeType' => 'subscription',
							'upgradeMode' => 'immediate',
							'downgradeMode' => 'immediate',
							'defaultQuantity' => 1,
							'tiers' => tiers_for_flat_component_1
						}),
						BillForward::PricingComponent.new({
							'@type' => 'tieredPricingComponent',
							'chargeModel' => 'tiered',
							'name' => 'Devices used, tiered',
							'description' => 'How many devices you use, but with a tiering system',
							'unitOfMeasureID' => created_uom.id,
							'chargeType' => 'usage',
							'upgradeMode' => 'immediate',
							'downgradeMode' => 'immediate',
							'defaultQuantity' => 10,
							'tiers' => tiers_for_tiered_component_1
						}))


					# create product rate plan, using pricing components and product
					prp = BillForward::ProductRatePlan.new({
						'currency' => 'USD',
						'name' => 'A sound plan',
						'pricingComponents' => pricing_components,
						'productID' => created_product.id,
						})
					created_prp = BillForward::ProductRatePlan.create(prp)


					# create references for tests to use
					@created_prp = created_prp
				end
				context 'a subscription exists for the account' do
					before :all do
						# make subscription..
						# requires:
						# - account [we have this already]
						# - product rate plan [we have this already]
						# - pricing component value instances (for every pricing component on the PRP)


						pricing_components = @created_prp.pricingComponents
						# get references to each pricing component we made
						flat_pricing_component_1 = pricing_components[0]
						tiered_pricing_component_1 = pricing_components[1]

						# create PricingComponentValue instances for every PricingComponent on the PRP
						pricing_component_values = Array.new
						pricing_component_values.push(
							BillForward::PricingComponentValue.new({
								'pricingComponentID' => flat_pricing_component_1.id,
								'value' => 1,
							}),
							BillForward::PricingComponentValue.new({
								'pricingComponentID' => tiered_pricing_component_1.id,
								'value' => 5,
							}))


						# create subscription
						subscription = BillForward::Subscription.new({
							'type' =>                           'Subscription',
							'productRatePlanID' =>              @created_prp.id,
							'accountID' =>                      @created_account.id,
							'name' =>                           'Memorable Subscription',
							'description' =>                    'Memorable Subscription Description',
							'pricingComponentValues' =>         pricing_component_values
							})
						created_sub = BillForward::Subscription.create(subscription)


						# create references for tests to use
						@created_sub = created_sub
					end
					subject (:account) { @created_account }
					subject (:subscription) { @created_sub }
					describe 'the subscription' do
						it 'can be gotten' do
							subscriptions = BillForward::Subscription.get_by_account_id(account.id)
							expect(subscriptions.first.id).to eq(subscription.id)
						end
					end
				end
			end
		end
	end
end