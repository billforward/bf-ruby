require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "spec_helper")

describe BillForward::UnitOfMeasure do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::create' do
		it 'creates a UnitOfMeasure' do
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
			
			expect(created_uom_1['@type']).to eq(BillForward::UnitOfMeasure.resource_path.entity_name)
		end
	end
end