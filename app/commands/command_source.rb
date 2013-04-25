module Commands

	class CommandSource
		
		attr_accessor :id, :last_update

		def initialize(id)
			self.id = id
		end

	end
	
end