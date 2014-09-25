module BillForward
	# Note: does not use indifferent access! Only entities themselves have indifferent access!
	class OrderedHashWithDotAccess < ActiveSupport::OrderedHash
		def method_missing(method_id, *arguments, &block)
			# no call to super; our criteria is all keys.
			#setter
			if /^(\w+)=$/ =~ method_id.to_s
				return self[$1] = arguments.first
			end
			#getter
			self[method_id.to_s]
		end
	end
end