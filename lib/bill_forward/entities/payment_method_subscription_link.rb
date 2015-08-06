module BillForward
  class PaymentMethodSubscriptionLink < MutableEntity
    @resource_path = BillForward::ResourcePath.new("payment-method-subscription-links", "PaymentMethodSubscriptionLink")
  end
end
