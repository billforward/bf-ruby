module BillForward
	class InvoiceRecalculationAmendment < Amendment
		@resource_path = BillForward::ResourcePath.new("amendments", "amendment")
		
		def initialize(*args)
			super
			set_state_param('@type', 'InvoiceRecalculationAmendment')
		end
	end
end