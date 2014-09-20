module BillForward
	class Profile < MutableEntity
  		@resource_path = BillForward::ResourcePath.new("profiles", "profile")

		def get_addresses
	      addresses
	    end

	protected
	    def unserialize_all(hash)
	      super hash

	      unserialize_array_of_entities('addresses', Address, hash)
	    end
	end
end