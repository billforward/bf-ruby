require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "spec_helper")

describe BillForward::ProductRatePlan do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::create' do
		context 'product and pricing components already exist' do
			before :all do
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

				@created_product = created_product
				@pricing_components = pricing_components
			end
			subject(:product) { @created_product }
			subject(:pricing_components) { @pricing_components }
			it 'creates a Rate Plan' do
				rate_plan_name = 'Sound Plan'
				created_prp = nil
				begin
					created_prp = BillForward::ProductRatePlan.get_by_product_and_plan_id product.name, rate_plan_name
				rescue IndexError=>e
					# create product rate plan, using pricing components and product
					prp = BillForward::ProductRatePlan.new({
						'currency' => 'USD',
						'name' => rate_plan_name,
						'pricingComponents' => pricing_components,
						'productID' => product.id,
					})
					created_prp = BillForward::ProductRatePlan.create(prp)
				end

				expect(created_prp['@type']).to eq(BillForward::ProductRatePlan.resource_path.entity_name)
			end
		end
	end
end