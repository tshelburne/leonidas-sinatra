module Leonidas
	module MemoryLayer

		class App
			
			attr_reader :id, :state, :sources

			def initialize(id, state)
				@locked_state = state.dup
				@active_state = state.dup
				@id = id
				@sources = [ ]
			end

			def revert_state!
				@active_state = @locked_state.dup
			end

			def lock_state!
				@locked_state = @active_state.dup
			end

			def add_source!(source)
				raise TypeError, "Argument must be a Leonidas::Commands::CommandSource" unless source.is_a? Leonidas::Commands::CommandSource
				@sources << source
			end

			def remove_source!(source)
				raise TypeError, "Argument must be a Leonidas::Commands::CommandSource" unless source.is_a? Leonidas::Commands::CommandSource
				@sources << source
			end

			def source(id)
				@sources.select {|source| source.id == id}.first
			end

			def sources
				@sources
			end

		end
		
	end
end