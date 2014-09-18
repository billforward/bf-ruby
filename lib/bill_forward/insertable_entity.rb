module BillForward
	class InsertableEntity < BillingEntity
		class << self
			def create(entity = nil)
				entity = self.new if entity.nil?
				TypeCheck.verifyObj(self, entity, 'entity')

				serial = entity.to_hash
				client = entity._client

				route = entity.class.resource_path.path
				endpoint = ''
				url_full = "#{route}/#{endpoint}"

				response = client.post_first(url_full, serial)

				self.new(response, client)
			end
		end
	end
end