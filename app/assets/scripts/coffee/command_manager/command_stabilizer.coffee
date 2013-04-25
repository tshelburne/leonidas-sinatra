class CommandStabilizer

	constructor: (@commandSource, @commandOrganizer, @commandProcessor)->

	stabilize: (stableTimestamp)->
		stableCommands = command in @commandOrganizer.activeCommands() when command.timestamp < stableTimestamp
		@commandSource.revertState()
		@commandProcessor.process(stableCommands)
		@commandSource.finalizeState()
		@commandOrganizer.deactivateCommands(stableCommands)

return CommandStabilizer