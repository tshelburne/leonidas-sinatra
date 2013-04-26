class CommandOrganizer

	constructor: ->
		@unsyncedCommands = [ ]
		@syncedCommands = [ ]
		@inactiveCommands = [ ]

	addCommand: (command, unsynced=true)-> if unsynced then @unsyncedCommands.push command else @syncedCommands.push command
		
	addCommands: (commands, unsynced=true)-> @addCommand(command, unsynced) for command in commands

	markAsSynced: (commands)->
		@syncedCommands.push(command) for command in commands when command not in @syncedCommands
		@unsyncedCommands = (command for command in @unsyncedCommands when command not in commands)

	markAsInactive: (commands)-> 
		@inactiveCommands.push(command) for command in commands
		@syncedCommands = (command for command in @syncedCommands when command not in commands)

	activeCommands: -> 
		activeCommands = @unsyncedCommands.concat @syncedCommands
		activeCommands.sort (a,b)-> if a.timestamp > b.timestamp then 1 else -1

return CommandOrganizer