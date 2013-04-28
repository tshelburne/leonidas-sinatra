module TestMocks

	class MockApp

		def initialize
			@state = { value: 0 }
		end

		def current_state
			@state
		end

	end
	
end