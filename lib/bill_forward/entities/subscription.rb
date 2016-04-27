module BillForward
  # This entity exposes the following child entities via method_missing:
  # 
  # PricingComponentValue[]        .pricingComponentValues
  # PricingComponentValueChange[]  .pricingComponentValueChanges
  class Subscription < MutableEntity
    @resource_path = BillForward::ResourcePath.new("subscriptions", "subscription")

    class << self
      def get_by_account_id(id, query_params = {}, custom_client = nil)
        raise ArgumentError.new("id cannot be nil") if id.nil?

        endpoint = sprintf('account/%s',
          ERB::Util.url_encode(id)
          )

        self.request_many('get', endpoint, query_params, custom_client)
      end

      def get_by_version_id(id, query_params = {}, custom_client = nil)
        raise ArgumentError.new("id cannot be nil") if id.nil?

        endpoint = sprintf('version/%s',
          ERB::Util.url_encode(id)
          )

        self.request_first('get', endpoint, query_params, custom_client)
      end

      def create_charge(id, request_object = {}, custom_client = nil)
        raise ArgumentError.new("id cannot be nil") if id.nil?

        endpoint = sprintf('%s/charge',
                           ERB::Util.url_encode(id)
        )

        request_entity = BillForward::GenericEntity.new(
            request_object
        )

        self.request_many_heterotyped(BillForward::SubscriptionCharge, 'post', endpoint, request_entity, nil, custom_client)
      end
    end

    def create_charge(request_object = {}, custom_client = nil)
      self.class.create_charge(self.id, request_object, custom_client)
    end

    def productRatePlan
      if (super.nil?)
        self.productRatePlan = BillForward::ProductRatePlan::get_by_id self.productRatePlanID
      end
      super
    end

    def product
      if (super.nil?)
        self.product = BillForward::Product::get_by_id self.productID
      end
      super
    end

    def activate
      set_state_param('state', 'AwaitingPayment')
      response = save
      response
    end

    def add_payment_method(id)
      raise ArgumentError.new("id cannot be nil") if id.nil?

      endpoint = sprintf('%s/payment-methods',
          ERB::Util.url_encode(self.id)
          )

      request_entity = BillForward::GenericEntity.new({
        'id' => id
        })

      self.class.request_first('post', endpoint, request_entity, nil, custom_client)
    end

    def remove_payment_method(id)
      raise ArgumentError.new("id cannot be nil") if id.nil?

      endpoint = sprintf('%s/payment-methods/%s',
          ERB::Util.url_encode(self.id),
          ERB::Util.url_encode(id)
          )

      self.class.request_first('delete', endpoint, nil, custom_client)
    end

    def get_payment_methods(query_params = {}, custom_client = nil)
      endpoint = sprintf('%s/payment-methods',
          ERB::Util.url_encode(self.id)
          )

      self.class.request_many_heterotyped(BillForward::PaymentMethod, 'get', endpoint, query_params, custom_client)
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
