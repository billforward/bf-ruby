module BillForward
	class PaymentMethod < MutableEntity
  		@resource_path = BillForward::ResourcePath.new("payment-methods", "paymentMethod")
	end
end