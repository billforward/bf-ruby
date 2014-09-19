module BillForward
	class MutableEntity < InsertableEntity
		# Asks API to update existing instance of this entity,
 		# based on current model.
	    # 
	    # @return [self] The updated Entity
		def save()
			serial = to_hash
			client = _client

			route = self.class.resource_path.path
			endpoint = ''
			url_full = "#{route}/#{endpoint}"

			response = client.put_first(url_full, serial)

			updated_entity = self.class.new(response, client)
			updated_entity
		end
	end
end