require "lib/jquery"

Command = require "leonidas/command"

class CommandSynchronizer

	constructor: (@syncUrl, @client, @organizer, @stabilizer)->
		@externalClients = [ ]

	push: =>
		unsyncedCommands = (command for command in @organizer.unsyncedCommands)
		$.ajax(
			url: "#{@syncUrl}"
			method: "POST"
			data: 
				clientId: @client.id
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
				clientId: @client.id
				clients: @externalClients
			error: => console.log "pull error"
			success: (response)=>
				@externalClients = response.data.currentClients
				commands = (new Command(command.name, command.data, command.timestamp) for command in response.data.commands)
				@organizer.addCommands commands, false
				@stabilizer.stabilize response.data.stableTimestamp
		)

return CommandSynchronizer