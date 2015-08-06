module BillForward
  class GenericEntity < MutableEntity
  	class << self
  		def create(entity = nil)
	  		raise DenyMethod.new 'Create support is denied for this entity; '+
		 	'it is just a payload wrapper, and is thus not a real entity in BillForward.'
	  	end

	  	def get_by_id(id, query_params = {}, customClient = nil)
	  		raise DenyMethod.new 'Get by ID support is denied for this entity; '+
			 'it is just a payload wrapper, and is thus not a real entity in BillForward.'
	  	end

	  	def get_all(query_params = {}, customClient = nil)
	  		raise DenyMethod.new 'Get All support is denied for this entity; '+
			 'it is just a payload wrapper, and is thus not a real entity in BillForward.'
	  	end
	end

  	def save()
  		raise DenyMethod.new 'Save support is denied for this entity; '+
		 'it is just a payload wrapper, and is thus not a real entity in BillForward.'
  	end
  end
end