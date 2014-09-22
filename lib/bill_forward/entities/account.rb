module BillForward
  # This entity exposes the following child entities via method_missing:
  # 
  # Role[]           .roles
  # PaymentMethod[]  .paymentMethods
  # Profile          .profile
  class Account < MutableEntity
  	@resource_path = BillForward::ResourcePath.new("accounts", "account")

  protected
    def unserialize_all(hash)
      super hash
      unserialize_entity('profile', Profile, hash)

      unserialize_array_of_entities('roles', Role, hash)
      unserialize_array_of_entities('paymentMethods', PaymentMethod, hash)
    end
  end
end