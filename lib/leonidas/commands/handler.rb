module Leonidas
	module Commands

		class Handler

			def handles?(command)
				command.name == @name
			end

			def run_wrapper(command)
				run(command)
				command.mark_as_run!
			end

			def persist_wrapper(command)
				persist(command)
				command.mark_as_persisted!
			end

			def rollback_wrapper(command)
				rollback(command)
				command.mark_as_not_run!
			end

			def rollback_persist_wrapper(command)
				rollback_persist(command)
				command.mark_as_not_persisted!
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