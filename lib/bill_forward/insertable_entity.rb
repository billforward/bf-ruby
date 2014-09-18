module BillForward
	class InsertableEntity < BillingEntity
		class << self
			def create(entity = nil)
				entity = self.new if entity.nil?
				TypeCheck.verifyObj(InsertableEntity, entity, 'entity')

				serial = entity.to_hash
				client = entity._client

				route = entity.class.resource_path.path
				endpoint = ''
				url_full = "#{route}/#{endpoint}"

				response = client.post_first(url_full, serial)

				self.new(response, client)
			end
		protected
			def make_entity_from_response_static

			end
		end
	end
end