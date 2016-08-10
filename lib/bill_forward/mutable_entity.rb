module BillForward
	class MutableEntity < InsertableEntity
		def initialize(*args)
	      raise AbstractInstantiateError.new('This abstract class cannot be instantiated!') if self.class == MutableEntity
	      super
	    end

		# Asks API to update existing instance of this entity,
 		# based on current model.
	    # 
	    # @return [self] The updated Entity
		def save()
			self.class.request_first('put', '', self, nil, _client)
		end

		# Asks API to retire existing instance of this entity.
		# @note Many BillForward entities do not support RETIRE
		# @note As-yet untested
	    # 
	    # @return [self] The retired Entity
		def delete(query_params = {})
			self.class.request_first('delete', ERB::Util.url_encode(id), query_params, nil, _client)
		end

		alias_method :retire, :delete
	end
end
