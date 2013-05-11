require 'lib/reqwest'

Command = require "leonidas/commands/command"

class Synchronizer

	constructor: (@syncUrl, @client, @organizer, @processor)->
		@stableTimestamp = new Date 0
		@externalClients = [ ]
		@syncedTimestamp = new Date 0

	push: =>
		unsyncedCommands = (command for command in @organizer.local.commandsAfter(@syncedTimestamp))
		reqwest(
			url: "#{@syncUrl}"
			type: "json"
			method: "post"
			data: 
				clientId: @client.id
				clients: @externalClients
				commands: (command.toHash() for command in unsyncedCommands)
			error: => console.log "push error"
			success: (response)=>
				@syncedTimestamp = unsyncedCommands[unsyncedCommands.length-1].timestamp
		)

	pull: =>
		reqwest(
			url: "#{@syncUrl}"
			type: "json"
			method: "get"
			data:
				clientId: @client.id
				clients: @externalClients
			error: => console.log "pull error"
			success: (response)=>
				newCommands = (new Command(command.name, command.data, command.connection, new Date(command.timestamp)) for command in response.data.commands)
				@processor.rollbackCommands @organizer.commandsAfter(@stableTimestamp).reverse()
				@organizer.external.addCommands newCommands
				@processor.runCommands @organizer.commandsAfter(@stableTimestamp)
				@externalClients = response.data.currentClients
				@stableTimestamp = response.data.stableTimestamp
		)

return Synchronizer