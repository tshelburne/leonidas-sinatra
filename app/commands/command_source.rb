module Commands

	class CommandSource
		
		attr_accessor :id, :last_update

		def initialize(id)
			self.id = id
			self.last_update = Time.now.to_i
		end

	end
	
end