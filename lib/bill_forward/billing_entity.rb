module BillForward
	class BillingEntity
		attr_accessor :client

		def initialize(client = nil)
			client = self.class.singleton_client if client.blank?

			TypeCheck.verify(Client, client, 'client')
			@client = client
		end

		class << self
			def get_by_id(id, customClient = nil)
				client = customClient
				client = singleton_client if client.blank?

				raise ArgumentError.new("id cannot be blank") if id.blank?

				client.get_first "accounts/#{id}"
			end

			def singleton_client
				Client.default_client
			end
		end
	end
end