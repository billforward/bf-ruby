module BillForward
  # This entity exposes the following child entities via method_missing:
  # 
  # PricingComponentValueChange[]  .pricingComponentValueChanges
  class Subscription < MutableEntity
    @resource_path = BillForward::ResourcePath.new("subscriptions", "subscription")

    def self.get_by_account_id(id, query_params = {}, customClient = nil)
      client = customClient
      client = singleton_client if client.nil?

      raise ArgumentError.new("id cannot be nil") if id.nil?
      TypeCheck.verifyObj(Hash, query_params, 'query_params')

      route = resource_path.path
      endpoint = 'account'
      url_full = "#{route}/#{endpoint}/#{id}"

      response = client.get_first(url_full)

      self.new(response, client)
    end

    protected
      def unserialize_all(hash)
        super hash
        
        unserialize_array_of_entities('pricingComponentValues', PricingComponentValue, hash)
        unserialize_array_of_entities('pricingComponentValueChanges', PricingComponentValueChange, hash)
      end
  end
end
