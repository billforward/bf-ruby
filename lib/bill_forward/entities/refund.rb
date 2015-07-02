module BillForward
	class Refund < MutableEntity
		@resource_path = BillForward::ResourcePath.new("refunds", "refund")
	end
end