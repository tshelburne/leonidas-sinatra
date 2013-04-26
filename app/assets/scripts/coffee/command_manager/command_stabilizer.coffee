class CommandStabilizer

	constructor: (@commandSource, @commandOrganizer, @commandProcessor)->

	stabilize: (stableTimestamp)->
		stableCommands = (command for command in @commandOrganizer.activeCommands() when command.timestamp < stableTimestamp)
		@commandSource.revertState()
		@commandProcessor.process(stableCommands)
		@commandSource.finalizeState()
		@commandOrganizer.deactivateCommands(stableCommands)
		@commandProcessor.process(@commandOrganizer.activeCommands())

return CommandStabilizer