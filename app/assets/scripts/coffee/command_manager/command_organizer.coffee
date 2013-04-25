class CommandOrganizer

	constructor: ->
		@deactivatedCommands = [ ]
		@syncedCommands = [ ]
		@unsyncedCommands = [ ]

	addCommand: (command, unsynced=true)-> unsynced ? @unsyncedCommands.push command : @syncedCommands.push command
		
	addCommands: (commands, unsynced=true)-> @addCommand(command, unsynced) for command in commands

	deactivateCommands: (commands)-> 
		@deactivatedCommands.push command for command in commands
		@syncedCommands = @syncedCommands.filter (command)-> command isnt in commands
		@unsyncedCommands = @unsyncedCommands.filter (command)-> command isnt in commands

	markAsSynced: (commands)->
		@syncedCommands.push command for command in commands when command isnt in @syncedCommands
		@unsyncedCommands = @unsyncedCommands.filter (command)-> command isnt in commands

	activeCommands: -> 
		activeCommands = @unsyncedCommands.concat @syncedCommands
		activeCommands.sort (a,b)-> a.timestamp > b.timestamp ? 1 : -1

return CommandOrganizer