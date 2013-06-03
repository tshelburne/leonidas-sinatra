module TestClasses

	class TestApp
		include ::Leonidas::App::App
		
		attr_reader :state

		def initialize(name="app-1")
			@name = name
			@persist_commands = false
			@state = { value: 0 } # not crazy about this, but ruby integers are 'pass-by-value' only, so a hash fakes it
		end

		def handlers
			[ 
				IncrementHandler.new(@state), 
				MultiplyHandler.new(@state) 
			]
		end

		def state=(val)
			@state[:value] = val
		end

	end

	class TestRepositoryContainer
		include ::Leonidas::App::AppRepository
	end

end