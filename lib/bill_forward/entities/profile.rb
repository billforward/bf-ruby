module BillForward
	# This entity exposes the following child entities via method_missing:
	# 
	# Address[]      .addresses
	class Profile < MutableEntity
		@resource_path = BillForward::ResourcePath.new("profiles", "profile")

	protected
	    def unserialize_all(hash)
	      super

	      unserialize_array_of_entities('addresses', Address, hash)
	    end
	end
end