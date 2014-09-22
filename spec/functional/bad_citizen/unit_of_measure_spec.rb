require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "spec_helper")

describe BillForward::UnitOfMeasure do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::create' do
		it 'creates a UnitOfMeasure' do
			unit_of_measure = BillForward::UnitOfMeasure.new({
				'name' => 'Devices',
				'displayedAs' => 'Devices',
				'roundingScheme' => 'UP',
				})
			created_uom = BillForward::UnitOfMeasure.create(unit_of_measure)
			
			expect(created_uom['@type']).to eq(BillForward::UnitOfMeasure.resource_path.entity_name)
		end
	end
end