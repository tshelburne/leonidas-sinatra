require "lib/jquery"

Command = require "leonidas/command"

class CommandSynchronizer

	constructor: (@syncUrl, @source, @organizer, @stabilizer)->

	push: =>
		unsyncedCommands = @organizer.unsyncedCommands
		$.ajax(
			url: "#{@syncUrl}"
			method: "POST"
			data: 
				sourceId: @source.id
				commands: (command.asHash() for command in unsyncedCommands)
			error: => console.log "push error"
			success: (response)=>
				@organizer.markAsSynced unsyncedCommands
		)

	pull: =>
		$.ajax(
			url: "#{@syncUrl}"
			method: "GET"
			error: => console.log "pull error"
			success: (response)=>
				commands = (new Command(command.name, command.data, command.timestamp) for command in response.data.commands)
				@organizer.addCommands commands, false
				@stabilizer.stabilize response.data.stableTimestamp
		)

return CommandSynchronizer