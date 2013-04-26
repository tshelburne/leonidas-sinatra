class CommandStabilizer

	constructor: (@source, @organizer, @processor)->

	stabilize: (stableTimestamp)->
		stableCommands = (command for command in @organizer.activeCommands() when command.timestamp <= stableTimestamp)
		@source.revertState()
		@processor.processCommands(stableCommands)
		@source.lockState()
		@organizer.deactivateCommands(stableCommands)
		@processor.processCommands(@organizer.activeCommands())

return CommandStabilizer