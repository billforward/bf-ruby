module BillForward
  # This entity exposes the following child entities via method_missing:
  # 
  # Product             .product
  # TaxationLink[]      .taxation
  # PricingComponent[]  .pricingComponents
  class ProductRatePlan < MutableEntity
    @resource_path = BillForward::ResourcePath.new("product-rate-plans", "productRatePlan")

    protected
      def unserialize_all(hash)
        super
        unserialize_entity('product', Product, hash)

        unserialize_array_of_entities('taxation', TaxationLink, hash)
        unserialize_array_of_entities('pricingComponents', PricingComponent, hash)
      end
  end
end
