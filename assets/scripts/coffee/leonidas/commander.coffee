Command = require "leonidas/commands/command"
Organizer = require "leonidas/commands/organizer"
Processor = require "leonidas/commands/processor"
Stabilizer = require "leonidas/commands/stabilizer"
Synchronizer = require "leonidas/commands/synchronizer"

class Commander

	constructor: (@organizer, @processor, @stabilizer, @synchronizer)->
		@pushFrequency = 1000
		@pullFrequency = 5000

	@default: (client, handlers, syncUrl)->
		organizer = new Organizer()
		processor = new Processor(handlers)
		stabilizer = new Stabilizer(client, organizer, processor)
		synchronizer = new Synchronizer(syncUrl, client, organizer, stabilizer)

		new @(organizer, processor, stabilizer, synchronizer)

	startSync: ->
		@pushInterval = setInterval(@synchronizer.push, @pushFrequency)
		@pullInterval = setInterval(@synchronizer.pull, @pullFrequency)

	stopSync: ->
		clearInterval @pushInterval
		clearInterval @pullInterval

	issueCommand: (name, data)->
		command = new Command(name, data)
		@organizer.addCommand command
		@processor.processCommand command

return Commander