module Commands

	class Command
		
		attr_accessor :name, :data, :timestamp, :source

		def initialize(name, data, timestamp, source)
			self.name = name
			self.data = data
			self.timestamp = timestamp
			self.source = source
		end

		def source=(val)
			raise TypeError, "Argument must be a Commands::CommandSource." unless val.is_a? Commands::CommandSource
			@source = val
		end

	end
	
end