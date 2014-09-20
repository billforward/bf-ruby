module BillForward
  class APIConfiguration < MutableEntity
  	class << self
		def create(entity = nil)
	  		raise DenyMethod.new 'Create support is denied for this entity; '+
		 	'at the time of writing, no API endpoint exists to support it. '+
		 	'The entity can be created through cascade only (i.e. instantiated within another entity).'
	  	end
	end
  end
end