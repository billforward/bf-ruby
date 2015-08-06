module BillForward
  class APIConfiguration < MutableEntity
  	@resource_path = BillForward::ResourcePath.new('configurations', 'APIConfiguration')

  	class << self
		def create(entity = nil)
	  		raise DenyMethod.new 'Create support is denied for this entity; '+
		 	'at the time of writing, no API endpoint exists to support it. '+
		 	'The entity can be created through cascade only (i.e. instantiated within another entity).'
	  	end

	  	def get_by_type(type, query_params = {}, custom_client = nil)
			raise ArgumentError.new("type cannot be nil") if type.nil?

			endpoint = sprintf('type/%s',
				ERB::Util.url_encode(type)
			)

			self.request_first('get', endpoint, query_params, custom_client)
		end
	end
  end
end