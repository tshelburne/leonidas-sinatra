class Organizer

	constructor: ->
		@localCommands = [ ]
		@externalCommands = [ ]

	addCommand: (command, local=true)->
		if local 
			command.id = @localCommands.length
			@localCommands.push command
		else 
			@externalCommands.push command
		
	addCommands: (commands, local=true)-> @addCommand(command, local) for command in commands

	commandsUntil: (timestamp, local=true)-> 
		commands = if local then sortCommands(@localCommands) else @allCommands()
		(command for command in commands when command.timestamp <= timestamp)

	commandsAfter: (timestamp, local=true)-> 
		commands = if local then sortCommands(@localCommands) else @allCommands()
		(command for command in commands when command.timestamp > timestamp)

	allCommands: -> sortCommands(@localCommands.concat @externalCommands)

	# private

	sortCommands = (commands)-> commands.sort (a,b)-> if a.timestamp > b.timestamp then 1 else -1

return Organizer


