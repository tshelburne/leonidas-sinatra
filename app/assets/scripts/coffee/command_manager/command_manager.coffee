class CommandManager

	constructor: (@commandSource, @commandOrganizer, @commandProcessor, @commandSynchronizer, @commandFinalizer)->
		@pushFrequency = 1
		@pullFrequency = 5
		@commandSynchronizer.pushed.add(@commandsPushed)
		@commandSynchronizer.pulled.add(@commandsPulled)
		@commandOrganizer.commandsDeactivated.add(@finalizeCommands)

	startSync: ->
		@pushInterval = setInterval(=> @commandSynchronizer.push(@commands), @pushFrequency)
		@pullInterval = setInterval(@commandSynchronizer.pull, @pullFrequency)

	stopSync: ->
		clearInterval @pushInterval
		clearInterval @pullInterval

	addCommand: (command)->
		@commandOrganizer.addCommand command
		@commandProcessor.processCommand command

	commandsPushed: (stableTimestamp)=>
		@commandFinalizer.finalizeCommands stableTimestamp

	commandsPulled: (commands, stableTimestamp)->
		@commandOrganizer.addCommands commands, false
		@commandFinalizer.finalizeCommands stableTimestamp

return CommandManager