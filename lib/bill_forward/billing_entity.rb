module BillForward
	class BillingEntity
		# legacy Ruby gives us this 'id' chuff. we kinda need it back.
		undef id
		attr_accessor :_client
		attr_accessor :_state_params

		def initialize(state_params = nil, client = nil)
			client = self.class.singleton_client if client.nil?
			state_params = {} if state_params.nil?

			TypeCheck.verify(Client, client, 'client')
			TypeCheck.verify(Hash, state_params, 'state_params')

			@_client = client
			# initiate with empty state params
			# use indifferent hash so 'id' and :id are the same
			@_state_params = HashWithIndifferentAccess.new
			# legacy Ruby gives us this 'id' chuff. we kinda need it back.	
			@_state_params.instance_eval { undef :id }
			# populate state params now
			unserialize_all state_params
		end

		class << self
			def get_by_id(id, customClient = nil)
				client = customClient
				client = singleton_client if client.nil?

				raise ArgumentError.new("id cannot be nil") if id.nil?

				self.new(client.get_first("accounts/#{id}"), client)
			end

			def singleton_client
				Client.default_client
			end
		end

		def method_missing(method_id, *arguments, &block)
		  # no call to super; our criteria is all keys.
		  @_state_params[method_id]
		end

	protected
		def unserialize_all(hash)
			hash.each do |key, value|
			  unserialize_one key, value
			end
		end

		def unserialize_one(key, value)
			@_state_params[key] = value
		end
	end
end