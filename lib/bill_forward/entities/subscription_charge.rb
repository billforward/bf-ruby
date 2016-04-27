module BillForward
  # This entity exposes the following child entities via method_missing:
  # 
  # Invoice         .invoice
  class SubscriptionCharge < MutableEntity
  	@resource_path = BillForward::ResourcePath.new('charges', 'subscriptionCharge')

    class << self
      def create(entity = nil)
        raise DenyMethod.new 'Create support is denied for this entity; '+
                                 'Please use Invoice.create_charge or Subscription.create_charge instead.'
      end

      def recalculate(id, request_object = {}, custom_client = nil)
        raise ArgumentError.new("id cannot be nil") if id.nil?

        endpoint = sprintf('%s/recalculate',
                           ERB::Util.url_encode(id)
        )

        request_entity = BillForward::GenericEntity.new(
            request_object
        )

        self.request_first('post', endpoint, request_entity, nil, custom_client)
      end

      def batch_recalculate(id, request_object = {}, custom_client = nil)
        raise ArgumentError.new("id cannot be nil") if id.nil?

        endpoint = sprintf('recalculate',
                           ERB::Util.url_encode(id)
        )

        request_entity = BillForward::GenericEntity.new(
            request_object
        )

        self.request_first('post', endpoint, request_entity, nil, custom_client)
      end
    end

  protected
    def unserialize_all(hash)
      super
      unserialize_entity('invoice', Invoice, hash)
    end
  end
end