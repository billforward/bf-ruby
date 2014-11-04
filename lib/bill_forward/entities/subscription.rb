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

    #### MIGRATE PLAN VIA AMENDMENT



    # Migrates subscription to new plan, with PricingComponentValue values corresponding to named PricingComponents.
    # This works only for 'arrears' or 'in advance' pricing components.
    #
    # Note: pricing component mapping is not yet implemented, so currently the 'names_to_values' parameter is ignored.
    #
    # @param names_to_values [hash] The map of pricing component names to numerical values ('Bandwidth usage' => 102)
    # @param new_plan_id [string] ID of the plan to migrate to.
    # @param invoicing_type [ENUM{'Immediate', 'Aggregated'}] (Default: 'Aggregated') Subscription-charge invoicing type <Immediate>: Generate invoice straight away with this charge applied, <Aggregated>: Add this charge to next invoice
    # @param new_plan [ProductRatePlan] (Alternative parameter to avoid extra API request) The plan to migrate to.
    # 
    # @return [self] The created Entity
    def migrate_plan(names_to_values = Hash.new, new_plan_id = nil, invoicing_type = 'Aggregated', new_plan = nil)
      # Until pricing component mapping is implemented, we don't to fetch the full plan
      # if new_plan.nil? do
      #   new_plan = BillForward::ProductRatePlan::get_by_id(new_plan_id)
      # end

      migrate_plan_simple(new_plan_id, invoicing_type)
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

      # Migrates subscription to new plan, with PricingComponentValue values corresponding to named PricingComponents.
      #
      # Note: this simple invocation will be deprecated when full support for mapping component values is introduced. The public 'migrate_plan' interface is not expected to change though.
      #
      # @param new_plan_id [string] ID of the plan to migrate to.
      # @param invoicing_type [ENUM{'Immediate', 'Aggregated'}] (Default: 'Aggregated') Subscription-charge invoicing type <Immediate>: Generate invoice straight away with this charge applied, <Aggregated>: Add this charge to next invoice
      # 
      # @return [self] The created Entity
      def migrate_plan_simple(new_plan_id, invoicing_type)
        amendment = BillForward::ProductRatePlanMigrationAmendment.new({
          'subscriptionID' => id,
          'productRatePlanID' => new_plan_id,
          'mappings' => Array.new,
          'invoicingType' => invoicing_type
          });

        created_amendment = BillForward::ProductRatePlanMigrationAmendment.create(amendment)
        created_amendment
      end
  end
end
