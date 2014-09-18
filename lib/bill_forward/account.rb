module BillForward
  class Account < MutableEntity
  	# provide access to self statics
  	class << self
  		# resource_path provides the endpoint name for this entity's controller
  		attr_accessor :resource_path
  	end
  	@resource_path = BillForward::ResourcePath.new("accounts", "account")

  	# move this to base class (when it exists); every entity will have their own self static resource_path
  	def resource_path
  		self.class.resource_path
  	end

    def get_roles
      roles
    end
  protected
    def unserialize_all(hash)
      super hash

      unserialize_array_entities('roles', Role, hash)
    end
  end
end