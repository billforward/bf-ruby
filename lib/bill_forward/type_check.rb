module BillForward
	class TypeCheck
		# ensure that the provided object extends the expected class
		def self.verifyObj(expectedClass, obj, argName)
			expectedClassName = expectedClass.name
			actualClassName = obj.class.name
			raise TypeError.new("Expected instance of '#{expectedClassName}' at argument '#{argName}'. "+
			"Instead received: '#{actualClassName}'") unless obj.kind_of?(expectedClass) || (defined?(RSpec) && obj.kind_of?(RSpec::Mocks::Double))
		end
		# ensure that the provided class extends the expected class
		def self.verifyClass(expectedClass, actualClass, argName)
			expectedClassName = expectedClass.name
			actualClassName = actualClass.name
			raise TypeError.new("Expected instance of '#{expectedClassName}' at argument '#{argName}'. "+
			"Instead received: '#{actualClassName}'") unless actualClass<=expectedClass || (defined?(RSpec) && actualClass<=RSpec::Mocks::Double)
		end
	end

	class AbstractInstantiateError < StandardError
	end
end