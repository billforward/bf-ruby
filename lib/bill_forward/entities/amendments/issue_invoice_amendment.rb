module BillForward
	class IssueInvoiceAmendment < Amendment
		@resource_path = BillForward::ResourcePath.new("amendments", "amendment")
		
		def initialize(*args)
			super
			set_state_param('@type', 'IssueInvoiceAmendment')
		end
	end
end