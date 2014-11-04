module BillForward
	# This entity exposes the following child entities via method_missing:
	# 
	# PricingComponentValueMigrationAmendmentMapping[]           .mappings
	class ProductRatePlanMigrationAmendment < Amendment
		@resource_path = BillForward::ResourcePath.new("amendments", "amendment")
		
		def initialize(*args)
			super
			set_state_param('@type', 'ProductRatePlanMigrationAmendment')
		end
	protected
		def unserialize_all(hash)
			super
			unserialize_array_of_entities('mappings', PricingComponentValueMigrationAmendmentMapping, hash)
		end
	end
end