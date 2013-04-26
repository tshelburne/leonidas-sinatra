require "lib/jquery"

Command = require "leonidas/command"

class CommandSynchronizer

	constructor: (@syncUrl, @commandSource, @commandOrganizer, @commandStabilizer)->

	push: =>
		unsyncedCommands = @commandOrganizer.unsyncedCommands
		$.ajax(
			url: "#{@syncUrl}"
			method: "POST"
			data: 
				sourceId: @commandSource.id
				commands: (command.asHash() for command in unsyncedCommands)
			error: => console.log "push error"
			success: (response)=>
				@commandOrganizer.markAsSynced unsyncedCommands
				@commandStabilizer.stabilize response.data.stableTimestamp
		)

	pull: =>
		$.ajax(
			url: "#{@syncUrl}"
			method: "GET"
			error: => console.log "pull error"
			success: (response)=>
				commands = (new Command(command.name, command.data, command.timestamp) for command in response.data.commands)
				@commandOrganizer.addCommands commands, false
				@commandStabilizer.stabilize response.data.stableTimestamp
		)

return CommandSynchronizer