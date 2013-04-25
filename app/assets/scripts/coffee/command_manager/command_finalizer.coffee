class CommandFinalizer

	constructor: (@commandSource, @commandOrganizer, @commandProcessor)->

	finalizeCommands: (stableTimestamp)->
		stableCommands = command in @commandOrganizer.activeCommands() when command.timestamp < stableTimestamp
		@commandSource.revertState()
		@commandProcessor.process(stableCommands)
		@commandSource.finalizeState()
		@commandOrganizer.deactivateCommands(stableCommands)

return CommandFinalizer