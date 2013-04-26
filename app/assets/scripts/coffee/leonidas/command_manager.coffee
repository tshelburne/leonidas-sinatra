Command = require "leonidas/command"
CommandOrganizer = require "leonidas/command_organizer"
CommandProcessor = require "leonidas/command_processor"
CommandStabilizer = require "leonidas/command_stabilizer"
CommandSynchronizer = require "leonidas/command_synchronizer"

class CommandManager

	constructor: (@organizer, @processor, @stabilizer, @synchronizer)->
		@pushFrequency = 1
		@pullFrequency = 5

	@default: (commandSource, handlers, syncUrl)->
		organizer = new CommandOrganizer()
		processor = new CommandProcessor(handlers)
		stabilizer = new CommandStabilizer(commandSource, organizer, processor)
		synchronizer = new CommandSynchronizer(syncUrl, commandSource, organizer, stabilizer)

		new @(organizer, processor, stabilizer, synchronizer)

	startSync: ->
		@pushInterval = setInterval(@synchronizer.push, @pushFrequency)
		@pullInterval = setInterval(@synchronizer.pull, @pullFrequency)

	stopSync: ->
		clearInterval @pushInterval
		clearInterval @pullInterval

	addCommand: (name, data)->
		command = new Command(name, data)
		@organizer.addCommand command
		@processor.processCommand command

return CommandManager