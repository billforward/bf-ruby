module BillForward
  # This entity exposes the following child entities via method_missing:
  # 
  # Role[]           .roles
  # PaymentMethod[]  .paymentMethods
  # Profile          .profile
  class Account < MutableEntity
  	@resource_path = BillForward::ResourcePath.new("accounts", "account")

    class << self
      def credit(id, query_object = {}, custom_client = nil)
        raise ArgumentError.new("id cannot be nil") if id.nil?

        endpoint = sprintf('%s/credit',
                           ERB::Util.url_encode(id)
        )

        request_entity = BillForward::GenericEntity.new(
            query_object
        )

        self.request_first('post', endpoint, request_entity, nil, custom_client)
      end
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