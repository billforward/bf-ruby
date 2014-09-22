module BillForward
  class Product < MutableEntity
    @resource_path = BillForward::ResourcePath.new("products", "product")
  end
end
