module Leonidas
	module MemoryLayer

		class CommanderApp
			
			def initialize(state, id=nil)
				self.state = state
				self.id = id.nil? ? Time.now.to_i : id
			end

		end
		
	end
end