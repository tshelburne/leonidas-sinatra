class CommandOrganizer

	constructor: ->
		@deactivatedCommands = [ ]
		@externalCommands = [ ]
		@localCommands = [ ]

	addCommand: (command, local=true)-> local ? @localCommands.push command : @externalCommands.push command
		
	addCommands: (commands, local=true)-> @addCommand(command, local) for command in commands

	deactivateCommands: (commands)-> 
		@deactivatedCommands.push command for command in commands
		@externalCommands = @externalCommands.filter (command)-> command isnt in commands
		@localCommands = @localCommands.filter (command)-> command isnt in commands

	activeCommands: -> 
		activeCommands = @localCommands.concat @externalCommands
		activeCommands.sort (a,b)-> a.timestamp > b.timestamp ? 1 : -1

return CommandOrganizer