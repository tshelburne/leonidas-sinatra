class CommandOrganizer

	constructor: ->
		@deactivatedCommands = [ ]
		@syncedCommands = [ ]
		@unsyncedCommands = [ ]

	addCommand: (command, unsynced=true)-> unsynced ? @unsyncedCommands.push command : @syncedCommands.push command
		
	addCommands: (commands, unsynced=true)-> @addCommand(command, unsynced) for command in commands

	deactivateCommands: (commands)-> 
		@deactivatedCommands.push(command) for command in commands
		@syncedCommands = (command for command in @syncedCommands when command not in commands)
		@unsyncedCommands = (command for command in @unsyncedCommands when command not in commands)

	markAsSynced: (commands)->
		@syncedCommands.push(command) for command in commands when command not in @syncedCommands
		@unsyncedCommands = (command for command in @unsyncedCommands when command not in commands)

	activeCommands: -> 
		activeCommands = @unsyncedCommands.concat @syncedCommands
		activeCommands.sort (a,b)-> a.timestamp > b.timestamp ? 1 : -1

return CommandOrganizer