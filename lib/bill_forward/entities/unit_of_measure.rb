module BillForward
	class UnitOfMeasure < MutableEntity
  		@resource_path = BillForward::ResourcePath.new('units-of-measure', 'unitOfMeasure')
	end
end