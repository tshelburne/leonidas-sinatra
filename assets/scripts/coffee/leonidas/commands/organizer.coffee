CommandList = require "leonidas/commands/command_list"

class Organizer

	constructor: ->
		# calling addCommand(s) on the command lists below is the only way to add commands to the organizer
		@local    = new CommandList()
		@external = new CommandList()

	commandsThrough: (timestamp)-> (command for command in @allCommands() when command.timestamp <= timestamp)

	commandsSince: (timestamp)-> (command for command in @allCommands() when command.timestamp > timestamp)

	allCommands: -> 
		allCommands = (command for command in @local.commands)
		allCommands.push command for command in @external.commands
		allCommands

	commandsFor: (clientId, timestamp=null)->
		timestamp = new Date(0) unless timestamp?
		(command for command in @commandsSince(timestamp) when command.clientId is clientId)

return Organizer