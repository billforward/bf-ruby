module BillForward
  # This entity exposes the following child entities via method_missing:
  # 
  # PricingComponentTier[]  .tiers
  class PricingComponent < MutableEntity
    @resource_path = BillForward::ResourcePath.new("pricing-components", "PricingComponent")

    def self.get_all(options=nil, customClient=nil)
      raise ArgumentError.new('Get All support is denied for this entity;
        at the time of writing, no working API endpoint exists to support it.
        The entity can be GETted through cascade (i.e. GET a related entity), or by ID only.'
      )
    end

    protected
      def unserialize_all(hash)
        super hash
        unserialize_array_of_entities('tiers', PricingComponentTier, hash)
      end
  end
end
