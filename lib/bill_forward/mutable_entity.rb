module BillForward
	class MutableEntity < InsertableEntity
		def initialize(*args)
	      raise AbstractInstantiateError.new('This abstract class cannot be instantiated!') if self.class == MutableEntity
	      super
	    end
	end
end