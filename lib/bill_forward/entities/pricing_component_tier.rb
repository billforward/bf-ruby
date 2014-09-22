module BillForward
  class PricingComponentTier < MutableEntity
    @resource_path = BillForward::ResourcePath.new("pricing-component-tiers", "pricingComponentTier")
  end
end
