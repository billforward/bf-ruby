module BillForward
	class MutableEntity < InsertableEntity
		# Asks API to update existing instance of this entity,
 		# based on current model.
	    # 
	    # @return [self] The updated Entity
		def save()
			serial = serialize
			client = _client

			route = self.class.resource_path.path
			endpoint = ''
			url_full = "#{route}/#{endpoint}"

			response = client.put_first(url_full, serial)

			updated_entity = self.class.new(response, client)
			updated_entity
		end

		# Asks API to retire existing instance of this entity.
		# @note Many BillForward entities do not support RETIRE
		# @note As-yet untested
	    # 
	    # @return [self] The retired Entity
		def delete()
			serial = serialize
			client = _client

			id = serial.id

			route = self.class.resource_path.path
			endpoint = ''
			url_full = "#{route}/#{endpoint}#{id}"

			response = client.retire_first(url_full)

			retired_entity = self.class.new(response, client)
			retired_entity
		end
	end
end