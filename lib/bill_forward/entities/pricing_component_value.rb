module BillForward
  class PricingComponentValue < MutableEntity
    @resource_path = BillForward::ResourcePath.new("pricing-component-values", "PricingComponentValue")
  end
end
