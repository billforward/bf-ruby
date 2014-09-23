module BillForward
  # This entity exposes the following child entities via method_missing:
  # 
  # APIConfiguration[]  .apiConfigurations
  class Organisation < MutableEntity
  	@resource_path = BillForward::ResourcePath.new("organizations", "organization")

  	class << self
  		def get_mine(options = {}, customClient = nil)
			client = customClient
			client = singleton_client if client.nil?

  			route = resource_path.path
			endpoint = 'mine'
			url_full = "#{route}/#{endpoint}"

			response = client.get(url_full)
			results = response["results"]
			
			# maybe use build_entity_array here for consistency
			entity_array = Array.new
			# maybe it's an empty array, but that's okay too.
			results.each do |value|
				entity = self.new(value, client)
				entity_array.push(entity)
			end
			entity_array
  		end
  	end

  protected
    def unserialize_all(hash)
      super
      unserialize_array_of_entities('apiConfigurations', APIConfiguration, hash)
    end
  end
end