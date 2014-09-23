require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "spec_helper")

describe BillForward::Product do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::create' do
		it 'creates a Product' do
			product = BillForward::Product.new({
				'productType' => 'non-recurring',
				'state' => 'prod',
				'name' => 'Month of Paracetamoxyfrusebendroneomycin',
				'description' => 'It can cure the common cold and being struck by lightning',
				'durationPeriod' => 'days',
				'duration' => 28,
				})
			created_product = BillForward::Product::create(product)
			expect(created_product['@type']).to eq(BillForward::Product.resource_path.entity_name)
		end
	end
end