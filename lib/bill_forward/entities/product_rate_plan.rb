module BillForward
  # This entity exposes the following child entities via method_missing:
  # 
  # Product             .product
  # TaxationLink[]      .taxation
  # PricingComponent[]  .pricingComponents
  class ProductRatePlan < MutableEntity
    @resource_path = BillForward::ResourcePath.new("product-rate-plans", "productRatePlan")

    class << self
      def get_by_product_id(id, query_params = {}, custom_client = nil)
        raise ArgumentError.new("id cannot be nil") if id.nil?

        endpoint = sprintf('product/%s',
          ERB::Util.url_encode(id)
          )

        self.request_many('get', endpoint, query_params, custom_client)
      end

      def get_by_product_and_plan_id(product_id, plan_id, query_params = {}, custom_client = nil)
        raise ArgumentError.new("id cannot be nil") if product_id.nil?
        raise ArgumentError.new("id cannot be nil") if plan_id.nil?

        endpoint = sprintf('product/%s/rate-plan/%s',
          ERB::Util.url_encode(product_id),
          ERB::Util.url_encode(plan_id)
          )

        self.request_first('get', endpoint, query_params, custom_client)
      end
    end

  protected
    def unserialize_all(hash)
      super
      unserialize_entity('product', Product, hash)

      unserialize_array_of_entities('taxation', TaxationLink, hash)
      unserialize_array_of_entities('pricingComponents', PricingComponent, hash)
    end
  end
end
