module BillForward
  class TaxLine < InsertableEntity
    class << self
  		def create(entity = nil)
	  		raise DenyMethod.new 'Create support is denied for this entity; '+
		 	'at the time of writing, no API endpoint exists to support it. '+
		 	'The entity can be created through cascade only (i.e. instantiated within another entity).'
	  	end

	  	def get_by_id(id, query_params = {}, customClient = nil)
	  		raise DenyMethod.new 'Get by ID support is denied for this entity; '+
			 'at the time of writing, no API endpoint exists to support it.'+
			 'The entity can be GETted through cascade only (i.e. GET a related entity).'
	  	end

	  	def get_all(query_params = {}, customClient = nil)
	  		raise DenyMethod.new 'Get All support is denied for this entity; '+
			 'at the time of writing, no API endpoint exists to support it.'+
			 'The entity can be GETted through cascade only (i.e. GET a related entity).'
	  	end
	end
  end
end