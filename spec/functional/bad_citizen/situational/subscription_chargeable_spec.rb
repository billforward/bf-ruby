require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "..", "spec_helper")

describe BillForward::Subscription do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client

		# Authorize.Net credentials used to test adding a payment gateway
		@authorize_net_login_id = BillForwardTest::AUTHORIZE_NET_LOGIN_ID
		@authorize_net_transaction_key = BillForwardTest::AUTHORIZE_NET_TRANSACTION_KEY

		# Authorize.Net credentials used to test adding a payment gateway
		@authorize_net_customer_profile_id = BillForwardTest::AUTHORIZE_NET_CUSTOMER_PROFILE_ID
		@authorize_net_customer_payment_profile_id = BillForwardTest::AUTHORIZE_NET_CUSTOMER_PAYMENT_PROFILE_ID
		@authorize_net_card_last_4_digits = BillForwardTest::AUTHORIZE_NET_CARD_LAST_4_DIGITS
	end
	context 'upon creating required entities for chargeable Subscription' do
		before :all do
			# get our organisation
			organisations = BillForward::Organisation.get_mine
			first_org = organisations.first


			# # remove from our organisation all existing AuthorizeNetConfigurations (if any)
			# filtered = first_org.apiConfigurations.reject do |config|
			# 	config['@type'] == 'AuthorizeNetConfiguration'
			# end
			# first_org.apiConfigurations = filtered


			# # add to our organisation: a new AuthorizeNetConfiguration
			# first_org.apiConfigurations.push BillForward::APIConfiguration.new({
			# 	 "@type" =>          "AuthorizeNetConfiguration",
			#      "APILoginID" =>     @authorize_net_login_id,
			#      "transactionKey" => @authorize_net_transaction_key,
			#      "environment" =>    "Sandbox"
			# 	})
			# updated_org = first_org.save


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
				'firstName' => 'Test',
				'addresses' => addresses
				})
			account = BillForward::Account.new({
				'profile' => profile
				})
			created_account = BillForward::Account.create account


			# create for our account: a tokenized card from Authorize.Net
			authorize_net_token = BillForward::AuthorizeNetToken.new({
				'accountID' => created_account.id,
				'customerProfileID' => @authorize_net_customer_profile_id,
				'customerPaymentProfileID' => @authorize_net_customer_payment_profile_id,
				'lastFourDigits' => @authorize_net_card_last_4_digits,
				'organizationID' => first_org.id
				})
			created_token = BillForward::AuthorizeNetToken.create(authorize_net_token)


			# create for our account: a new payment method, using Authorize.Net token
			payment_method = BillForward::PaymentMethod.new({
				'accountID' => created_account.id,
				'linkID' => created_token.id,
				'name' => 'Authorize.Net',
				'description' => 'Pay via Authorize.Net',
				'gateway' => 'authorizeNet',
				'userEditable' => 0,
				'priority' => 100,
				'reusable' => 1,
				})
			created_payment_method = BillForward::PaymentMethod::create(payment_method)


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
			@created_payment_method = created_payment_method
			@updated_org = first_org
		end
		subject(:account) { @created_account }
		subject(:prp) { @created_prp }
		subject(:payment_method) { @created_payment_method }
		subject(:organisation) { @updated_org }
		describe '::create' do
			it 'creates Subscription' do
				# make subscription..
				# requires:
				# - account [we have this already]
				# - product rate plan [we have this already]
				# - pricing component value instances (for every pricing component on the PRP)

				pricing_components = prp.pricingComponents
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
					'productRatePlanID' =>              prp.id,
					'accountID' =>                      account.id,
					'name' =>                           'Memorable Subscription',
					'description' =>                    "Customer acquired through 'Lazy Wednesdays' promotion",
					'pricingComponentValues' =>         pricing_component_values
					})
				created_sub = BillForward::Subscription.create(subscription)

				expect(created_sub['@type']).to eq(BillForward::Subscription.resource_path.entity_name)
			end
		end
	end
end