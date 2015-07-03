module BillForward
	class StripeACHToken < MutableEntity
		# WARNING: resource paths for StripeACHTokens do not follow the usual pattern;
		# instead of posting to 'root' of a URL root reserved for AuthorizeNetTokens, 
		# this routing is a bit less standard; for example we can't GET from the same
		# place we POST to.
  		@resource_path = BillForward::ResourcePath.new('vaulted-gateways/stripe-ACH', 'stripe_ach_token')
	end
end