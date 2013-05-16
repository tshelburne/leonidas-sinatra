module Leonidas
	module Commands

		class Handler

			def handles?(command)
				command.name == @name
			end

			def run(command)
				raise NoMethodError, 'Class must implement a #run method'
			end

			def persist(command)
				raise NoMethodError, 'Class must implement a #persist method'
			end

			def rollback(command)
				raise NoMethodError, 'Class must implement a #rollback method'
			end

			def rollback_persist(command)
				raise NoMethodError, 'Class must implement a #rollback_persist method'
			end

		end
		
	end
end