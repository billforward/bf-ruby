module BillForward
	class BillingEntity
		attr_accessor :client

		def initialize(client = nil)
			client = singleton_client if client.blank?

			TypeCheck.verify(Client, client, 'client')
			@client = client
		end

		def singleton_client()
			Client.default_client
		end
	end
end