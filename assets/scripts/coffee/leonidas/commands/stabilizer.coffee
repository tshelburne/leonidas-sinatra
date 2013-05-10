class Stabilizer

	constructor: (@client, @organizer, @processor)->

	stabilize: (stableTimestamp)->
		stableCommands = (command for command in @organizer.activeCommands() when command.timestamp <= stableTimestamp)
		@client.revertState()
		@processor.runCommands(stableCommands)
		@client.lockState()
		@organizer.lockCommands(stableCommands)
		@processor.runCommands(@organizer.activeCommands())

return Stabilizer