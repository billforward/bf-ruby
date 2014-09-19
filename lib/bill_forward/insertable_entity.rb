module BillForward
	class InsertableEntity < BillingEntity
		class << self
			# Asks API to create a real instance of specified entity,
	 		# based on provided model.
		    # @param options=nil [self] the Entity to create
		    # 
		    # @return [self] The created Entity
			def create(entity = nil)
				entity = self.new if entity.nil?
				TypeCheck.verifyObj(self, entity, 'entity')

				serial = entity.to_hash
				client = entity._client

				route = entity.class.resource_path.path
				endpoint = ''
				url_full = "#{route}/#{endpoint}"

				response = client.post_first(url_full, serial)

				created_entity = self.new(response, client)
				created_entity
			end
		end
	end
end