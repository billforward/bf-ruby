require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "spec_helper")

describe BillForward::Product do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::create' do
		it 'creates a Product' do
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
			expect(created_product['@type']).to eq(BillForward::Product.resource_path.entity_name)
		end
	end
end