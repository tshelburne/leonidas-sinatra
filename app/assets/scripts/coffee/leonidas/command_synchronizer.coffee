require "lib/jquery"

Command = require "leonidas/command"

class CommandSynchronizer

	constructor: (@syncUrl, @source, @organizer, @stabilizer)->
		@externalSources = [ ]

	push: =>
		unsyncedCommands = (command for command in @organizer.unsyncedCommands)
		$.ajax(
			url: "#{@syncUrl}"
			method: "POST"
			data: 
				sourceId: @source.id
				commands: (command.toHash() for command in unsyncedCommands)
			error: => console.log "push error"
			success: (response)=>
				@organizer.markAsSynced unsyncedCommands
		)

	pull: =>
		$.ajax(
			url: "#{@syncUrl}"
			method: "GET"
			data:
				sourceId: @source.id
				sources: @externalSources
			error: => console.log "pull error"
			success: (response)=>
				@externalSources = response.data.currentSources
				commands = (new Command(command.name, command.data, command.timestamp) for command in response.data.commands)
				@organizer.addCommands commands, false
				@stabilizer.stabilize response.data.stableTimestamp
		)

return CommandSynchronizer