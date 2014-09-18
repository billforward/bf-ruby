module BillForward
	class Profile < MutableEntity
  		@resource_path = BillForward::ResourcePath.new("profiles", "profile")
	end
end