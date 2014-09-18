module BillForward
  class Account < MutableEntity
  	@resource_path = BillForward::ResourcePath.new("accounts", "account")

    def get_roles
      roles
    end

    def get_profile
      profile
    end
  protected
    def unserialize_all(hash)
      super hash
      unserialize_entity('profile', Profile, hash)

      unserialize_array_of_entities('roles', Role, hash)
      unserialize_array_of_entities('paymentMethods', PaymentMethod, hash)
    end
  end
end