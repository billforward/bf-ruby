require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "spec_helper")

describe BillForward::ProductRatePlan do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::create' do
		context 'product and pricing components already exist' do
			before :all do
				unit_of_measure = BillForward::UnitOfMeasure.new({
					'name' => 'Devices',
					'displayedAs' => 'Devices',
					'roundingScheme' => 'UP',
					})
				created_uom = BillForward::UnitOfMeasure.create(unit_of_measure)


				product = BillForward::Product.new({
					'productType' => 'non-recurring',
					'state' => 'prod',
					'name' => 'Month of Paracetamoxyfrusebendroneomycin',
					'description' => 'It can cure the common cold and being struck by lightning',
					'durationPeriod' => 'days',
					'duration' => 28,
					})
				@created_product = BillForward::Product::create(product)


				tiers_for_flat_component_1 = Array.new()
				tiers_for_flat_component_1.push(
					BillForward::PricingComponentTier.new({
						'lowerThreshold' => 1,
						'upperThreshold' => 1,
						'pricingType' => 'fixed',
						'price' => 1,
					}))

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
						'chargeType' => 'subscription',
						'upgradeMode' => 'immediate',
						'downgradeMode' => 'immediate',
						'defaultQuantity' => 10,
						'tiers' => tiers_for_tiered_component_1
					}))

				@pricing_components = pricing_components
			end
			subject(:product) { @created_product }
			subject(:pricing_components) { @pricing_components }
			it 'creates a Product' do
				prp = BillForward::ProductRatePlan.new({
					'currency' => 'USD',
					'name' => 'A sound plan',
					'pricingComponents' => pricing_components,
					'productID' => product.id,
					})
				created_prp = BillForward::ProductRatePlan.create(prp)

				expect(created_prp['@type']).to eq(BillForward::ProductRatePlan.resource_path.entity_name)
			end
		end
	end
end