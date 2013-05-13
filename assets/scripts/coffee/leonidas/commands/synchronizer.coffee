require 'lib/reqwest'

Command = require "leonidas/commands/command"

class Synchronizer

	constructor: (@syncUrl, @client, @organizer, @processor)->
		@stableTimestamp = new Date 0
		@externalClients = [ ]

	push: =>
		unsyncedCommands = (command for command in @organizer.local.commandsSince(@client.lastUpdate))
		unless unsyncedCommands.length is 0
			reqwest(
				url: "#{@syncUrl}"
				type: "json"
				method: "post"
				data: 
					appName: @client.appName
					clientId: @client.id
					clients: @externalClients
					commands: (command.toHash() for command in unsyncedCommands)
				error: => console.log "push error"
				success: (response)=>
					seconds = Math.max.apply @, (command.timestamp for command in unsyncedCommands)
					@client.lastUpdate = new Date seconds
			)

	pull: =>
		reqwest(
			url: "#{@syncUrl}"
			type: "json"
			method: "get"
			data:
				appName: @client.appName
				clientId: @client.id
				clients: @externalClients
			error: => console.log "pull error"
			success: (response)=>
				newCommands = (new Command(command.name, command.data, command.connection, new Date(command.timestamp)) for command in response.data.commands)
				@processor.rollbackCommands @organizer.commandsSince(@stableTimestamp)
				@organizer.external.addCommands newCommands
				@processor.runCommands @organizer.commandsSince(@stableTimestamp)
				@externalClients = response.data.currentClients
				@stableTimestamp = response.data.stableTimestamp
		)

return Synchronizer