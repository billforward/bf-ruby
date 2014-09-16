module BillForward
  class ResourcePath
  	attr_reader :path
  	attr_reader :entity_name

  	def initialize(path, entity_name)
  		@path = path
  		@entity_name = entity_name
  	end
  end
end