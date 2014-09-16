module BillForward
	class TypeCheck
		def self.verify(expectedClass, value, argName)
			expectedClassName = expectedClass.name
			actualClassName = value.class.name
			raise "Expected instance of '#{expectedClassName}' at argument '#{argName}'. "+
			"Instead received: '#{actualClassName}'" unless value.kind_of?(expectedClass)
		end
	end
end