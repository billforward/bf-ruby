module BillForward
  class TaxationLink < MutableEntity
    @resource_path = BillForward::ResourcePath.new("taxation-links", "TaxationLink")
  end
end
