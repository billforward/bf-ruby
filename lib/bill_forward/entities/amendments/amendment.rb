module BillForward
  class Amendment < InsertableEntity
  	@resource_path = BillForward::ResourcePath.new("amendments", "amendment")

    # def initialize(*args)
    #   raise AbstractInstantiateError.new('This abstract class cannot be instantiated!') if self.class == Amendment
    #   super
    # end

  end
end