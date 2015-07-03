require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "spec_helper")

describe BillForward::Subscription do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	context 'upon creating required entities for chargeable Subscription' do
		before :all do
			# get our organisation
			# organisations = BillForward::Organisation.get_mine
			# first_org = organisations.first


			# create an account
			# requires (optionally):
			# - profile
			# - - addresses
			addresses = Array.new()
			addresses.push(
				BillForward::Address.new({
				'addressLine1' => 'address line 1',
			    'addressLine2' => 'address line 2',
			    'addressLine3' => 'address line 3',
			    'city' => 'London',
			    'province' => 'London',
			    'country' => 'United Kingdom',
			    'postcode' => 'SW1 1AS',
			    'landline' => '02000000000',
			    'primaryAddress' => true
				}))
			profile = BillForward::Profile.new({
				'email' => 'always@testing.is.moe',
				'firstName' => 'Ruby',
				'lastName' => 'Red',
				'addresses' => addresses
				})
			account = BillForward::Account.new({
				'profile' => profile
				})
			created_account = BillForward::Account.create account

			## Credit note payment method exists implicitly nowadays
			# create for our account: a new payment method, using credit notes
			# payment_method = BillForward::PaymentMethod.new({
			# 	'accountID' => created_account.id,
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


			# issue $100 credit to our account
			credit_note = BillForward::CreditNote.new({
				"accountID" => created_account.id,
			    "value" => 1000,
			    "currency" => "USD"
				})
			created_credit_note = BillForward::CreditNote.create(credit_note)

			uom_1_name = 'CPU'
			created_uom_1 = nil
			begin
				created_uom_1 = BillForward::UnitOfMeasure.get_by_id uom_1_name
			rescue IndexError=>e
				# create a unit of measure
				unit_of_measure_1 = BillForward::UnitOfMeasure.new({
					'name' => uom_1_name,
					'displayedAs' => 'Cycles',
					'roundingScheme' => 'UP',
					})
				created_uom_1 = BillForward::UnitOfMeasure.create(unit_of_measure_1)
			end

			uom_2_name = 'Bandwidth'
			created_uom_2 = nil
			begin
				created_uom_2 = BillForward::UnitOfMeasure.get_by_id uom_2_name
			rescue IndexError=>e
				# create another unit of measure
				unit_of_measure_2 = BillForward::UnitOfMeasure.new({
					'name' => uom_2_name,
					'displayedAs' => 'Mbps',
					'roundingScheme' => 'UP',
					})
				created_uom_2 = BillForward::UnitOfMeasure.create(unit_of_measure_2)
			end

			product_name = 'Monthly recurring'
			created_product = nil
			begin
				created_product = BillForward::Product.get_by_id product_name
			rescue IndexError=>e
				# create a product
				product = BillForward::Product.new({
					'productType' => 'recurring',
					'state' => 'prod',
					'name' => product_name,
					'description' => 'Purchaseables to which customer has a non-renewing, monthly entitlement',
					'durationPeriod' => 'months',
					'duration' => 1,
					})
				created_product = BillForward::Product::create(product)
			end


			# make product rate plan..
			# requires:
			# - product,
			# - pricing components..
			# .. - which require pricing component tiers

			# for a tiered pricing component:
			tiers_for_tiered_component_1 = Array.new()
			tiers_for_tiered_component_1.push(
				BillForward::PricingComponentTier.new({
					'lowerThreshold' => 0,
					'upperThreshold' => 0,
					'pricingType' => 'unit',
					'price' => 0,
				}),
				BillForward::PricingComponentTier.new({
					'lowerThreshold' => 1,
					'upperThreshold' => 10,
					'pricingType' => 'unit',
					'price' => 1,
				}),
				BillForward::PricingComponentTier.new({
					'lowerThreshold' => 11,
					'upperThreshold' => 1000,
					'pricingType' => 'unit',
					'price' => 0.50
				}))

			# for another tiered pricing component:
			tiers_for_tiered_component_2 = Array.new()
			tiers_for_tiered_component_2.push(
				BillForward::PricingComponentTier.new({
					'lowerThreshold' => 0,
					'upperThreshold' => 0,
					'pricingType' => 'unit',
					'price' => 0,
				}),
				BillForward::PricingComponentTier.new({
					'lowerThreshold' => 1,
					'upperThreshold' => 10,
					'pricingType' => 'unit',
					'price' => 0.10,
				}),
				BillForward::PricingComponentTier.new({
					'lowerThreshold' => 11,
					'upperThreshold' => 1000,
					'pricingType' => 'unit',
					'price' => 0.05
				}))


			# create 'in advance' ('subscription') pricing components, based on these tiers
			pricing_components = Array.new()
			pricing_components.push(
				BillForward::PricingComponent.new({
					'@type' => 'tieredPricingComponent',
					'chargeModel' => 'tiered',
					'name' => 'CPU',
					'description' => 'CPU consumed',
					'unitOfMeasureID' => created_uom_1.id,
					'chargeType' => 'subscription',
					'upgradeMode' => 'immediate',
					'downgradeMode' => 'immediate',
					'defaultQuantity' => 1,
					'tiers' => tiers_for_tiered_component_1
				}),
				BillForward::PricingComponent.new({
					'@type' => 'tieredPricingComponent',
					'chargeModel' => 'tiered',
					'name' => 'Bandwidth',
					'description' => 'Bandwidth consumed',
					'unitOfMeasureID' => created_uom_2.id,
					'chargeType' => 'subscription',
					'upgradeMode' => 'immediate',
					'downgradeMode' => 'immediate',
					'defaultQuantity' => 10,
					'tiers' => tiers_for_tiered_component_2
				}))

			rate_plan_name = 'Sound Plan'
			created_prp = nil
			begin
				created_prp = BillForward::ProductRatePlan.get_by_product_and_plan_id product_name, rate_plan_name
			rescue IndexError=>e
				# create product rate plan, using pricing components and product
				prp = BillForward::ProductRatePlan.new({
					'currency' => 'USD',
					'name' => rate_plan_name,
					'pricingComponents' => pricing_components,
					'productID' => created_product.id,
				})
				created_prp = BillForward::ProductRatePlan.create(prp)
			end


			# create references for tests to use
			@created_account = created_account
			@created_prp = created_prp
		end
		describe '::create' do
			describe 'the subscription' do
				before :all do
					# make subscription..
					# requires:
					# - account [we have this already]
					# - product rate plan [we have this already]
					# - pricing component value instances (for every pricing component on the PRP)

					pricing_components = @created_prp.pricingComponents
					# get references to each pricing component we made
					tiered_pricing_component_1 = pricing_components[0]
					tiered_pricing_component_2 = pricing_components[1]

					# create PricingComponentValue instances for every PricingComponent on the PRP
					pricing_component_values = Array.new
					pricing_component_values.push(
						BillForward::PricingComponentValue.new({
							'pricingComponentID' => tiered_pricing_component_1.id,
							'value' => 13,
						}),
						BillForward::PricingComponentValue.new({
							'pricingComponentID' => tiered_pricing_component_2.id,
							'value' => 13,
						}))


					# create subscription
					subscription = BillForward::Subscription.new({
						'type' =>                           'Subscription',
						'productRatePlanID' =>              @created_prp.id,
						'accountID' =>                      @created_account.id,
						'name' =>                           'Memorable Subscription',
						'description' =>                    "Customer acquired through 'Lazy Wednesdays' promotion",
						'pricingComponentValues' =>         pricing_component_values
						})
					created_sub = BillForward::Subscription.create(subscription)

					# create references for tests to use
					@created_sub = created_sub
				end
				subject(:subscription) { @created_sub }
				it 'is created' do
					expect(subscription['@type']).to eq(BillForward::Subscription.resource_path.entity_name)
				end
				it 'can be gotten' do
					gotten_subscription = BillForward::Subscription.get_by_id(subscription.id)
					expect(gotten_subscription['@type']).to eq(BillForward::Subscription.resource_path.entity_name)
				end
				it 'can be activated' do
					expect(subscription['state']).to eq('Provisioned')
					updated_subscription = subscription.activate

					expect(updated_subscription['state']).to satisfy{|s| ['AwaitingPayment', 'Paid'].include?(s)}
				end
			end
		end
	end
end