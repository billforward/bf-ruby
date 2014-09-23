module BillForward
  # This entity exposes the following child entities via method_missing:
  # 
  # Role[]           .roles
  # PaymentMethod[]  .paymentMethods
  # Profile          .profile
  class Amendment < InsertableEntity
  	@resource_path = BillForward::ResourcePath.new("accounts", "account")

    def initialize(*args)
      raise AbstractInstantiateError.new('This abstract class cannot be instantiated!') if self.class == Amendment
      super
    end

  protected
    def unserialize_all(hash)
      super
      unserialize_entity('profile', Profile, hash)

      unserialize_array_of_entities('roles', Role, hash)
      unserialize_array_of_entities('paymentMethods', PaymentMethod, hash)
    end
  end
end