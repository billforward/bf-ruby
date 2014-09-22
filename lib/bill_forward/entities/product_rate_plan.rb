module BillForward
  class ProductRatePlan < MutableEntity
    @resource_path = BillForward::ResourcePath.new("product-rate-plans", "productRatePlan")

    def get_product
      product
    end

    def get_taxation_links
      taxation
    end

    def get_pricing_components
      pricingComponents
    end

    protected
      def unserialize_all(hash)
        super hash
        unserialize_entity('product', Product, hash)

        unserialize_array_of_entities('taxation', TaxationLink, hash)
        unserialize_array_of_entities('pricingComponents', PricingComponent, hash)
      end
  end
end
