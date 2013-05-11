CommandList = require "leonidas/commands/command_list"

class Organizer

	constructor: ->
		# calling addCommand(s) on the command lists below is the only way to add commands to the organizer
		@local    = new CommandList()
		@external = new CommandList()

	commandsUntil: (timestamp)-> (command for command in @allCommands() when command.timestamp <= timestamp)

	commandsAfter: (timestamp)-> (command for command in @allCommands() when command.timestamp > timestamp)

	allCommands: -> 
		allCommands = (command for command in @local.commands)
		allCommands.push command for command in @external.commands
		sortCommands(allCommands)

	# private

	sortCommands = (commands)-> commands.sort (a,b)-> if a.timestamp > b.timestamp then 1 else -1

return Organizer