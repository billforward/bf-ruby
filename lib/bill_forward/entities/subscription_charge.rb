module BillForward
  # This entity exposes the following child entities via method_missing:
  # 
  # Invoice         .invoice
  class SubscriptionCharge < MutableEntity
  	@resource_path = BillForward::ResourcePath.new('charges', 'subscriptionCharge')

  protected
    def unserialize_all(hash)
      super
      unserialize_entity('invoice', Invoice, hash)
    end
  end
end