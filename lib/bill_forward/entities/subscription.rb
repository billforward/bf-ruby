module BillForward
  # This entity exposes the following child entities via method_missing:
  # 
  # PricingComponentValue[]        .pricingComponentValues
  # PricingComponentValueChange[]  .pricingComponentValueChanges
  class Subscription < MutableEntity
    @resource_path = BillForward::ResourcePath.new("subscriptions", "subscription")

    class << self
      def get_by_account_id(id, query_params = {}, customClient = nil)
        client = customClient
        client = singleton_client if client.nil?

        raise ArgumentError.new("id cannot be nil") if id.nil?
        TypeCheck.verifyObj(Hash, query_params, 'query_params')

        route = resource_path.path
        endpoint = 'account'
        url_full = "#{route}/#{endpoint}/#{id}"

        response = client.get(url_full, query_params)
        results = response["results"]

        # maybe use build_entity_array here for consistency
        entity_array = Array.new
        # maybe it's an empty array, but that's okay too.
        results.each do |value|
          entity = self.new(value, client)
          entity_array.push(entity)
        end
        entity_array
      end
    end

    def activate
      set_state_param('state', 'AwaitingPayment')
      response = save
      response
    end

    protected
      def unserialize_all(hash)
        super
        # always has these:
        unserialize_array_of_entities('pricingComponentValues', PricingComponentValue, hash)
        unserialize_array_of_entities('pricingComponentValueChanges', PricingComponentValueChange, hash)


        # think about the other entities later..
        # unserialize_array_of_entities('paymentMethodSubscriptionLinks', PaymentMethodSubscriptionLink, hash)
      end
  end
end
