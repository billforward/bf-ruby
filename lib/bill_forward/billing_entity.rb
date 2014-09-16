module BillForward
	class BillingEntity
		attr_accessor :client
		def initialize(client = nil)
			TypeCheck.verify(Client, client, 'client')
			@client = client
		end
	end
end