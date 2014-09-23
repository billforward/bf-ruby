module BillForward
  class CreditNote < MutableEntity
  	@resource_path = BillForward::ResourcePath.new('credit-notes', 'creditNote')

  	class << self
	  	def get_all(query_params = {}, customClient = nil)
	  		raise DenyMethod.new 'Get All support is denied for this entity; '+
			 'at the time of writing, no API endpoint exists to support it.'+
			 'The entity can be GETted by ID only.'
	  	end
	end
  end
end