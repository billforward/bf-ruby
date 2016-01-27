module BillForward
  class CreditNote < MutableEntity
  	@resource_path = BillForward::ResourcePath.new('credit-notes', 'creditNote')

  	class << self
	  	def get_all(query_params = {}, customClient = nil)
	  		raise DenyMethod.new 'Get All support is denied for this entity; '+
			 'at the time of writing, no API endpoint exists to support it.'+
			 'The entity can be GETted by ID only.'
	  	end
	  	
		def get_remaining_credit_on_account(id, query_params = {}, custom_client = nil)
			credit_notes = get_by_account_id(id, query_params, custom_client)

			self.count_remaining_credit credit_notes
		end
	  	
		def get_remaining_credit_on_subscription(id, query_params = {}, custom_client = nil)
			credit_notes = get_by_subscription_id(id, query_params, custom_client)

			self.count_remaining_credit credit_notes
		end

		def get_by_account_id(id, query_params = {}, custom_client = nil)
			raise ArgumentError.new("id cannot be nil") if id.nil?

			endpoint = sprintf('account/%s',
				ERB::Util.url_encode(id)
			)

			self.request_many('get', endpoint, query_params, custom_client)
		end
	  	
		def get_by_subscription_id(id, query_params = {}, custom_client = nil)
			raise ArgumentError.new("id cannot be nil") if id.nil?

			endpoint = sprintf('subscription/%s',
				ERB::Util.url_encode(id)
			)

			self.request_many('get', endpoint, query_params, custom_client)
		end
	protected
		def count_remaining_credit(credit_notes)
			credit_notes.map(&:remainingValue).inject(0, :+)
		end
	end
  end
end