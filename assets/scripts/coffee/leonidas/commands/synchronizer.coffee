require 'lib/reqwest'

Command = require "leonidas/commands/command"

class Synchronizer

	constructor: (@syncUrl, @client, @organizer, @processor)->
		@stableTimestamp = 0
		@externalClients = { }
		@lastPushAttempt = 0

	pull: =>
		reqwest(
			url: "#{@syncUrl}"
			type: "json"
			method: "get"
			data:
				appName: @client.appName
				appType: @client.appType
				clientId: @client.id
				externalClients: @externalClients
			error: => console.log "pull error"
			success: (response)=>
				if response.success
					newCommands = (new Command(command.name, command.data, command.connection, new Date(command.timestamp), command.id) for command in response.data.commands)
					@processor.rollbackCommands @organizer.commandsSince(@stableTimestamp)
					@organizer.external.addCommands newCommands
					@processor.runCommands @organizer.commandsSince(@stableTimestamp)
					@externalClients = response.data.externalClients
					@stableTimestamp = response.data.stableTimestamp
				else
					@reconcileTimeout = setTimeout(@reconcile, 1000) if response.message is "reconcile required" and not @reconcileTimeout?
		)

	push: =>
		unsyncedCommands = (command for command in @organizer.local.commandsSince(@client.lastUpdate))
		unless unsyncedCommands.length is 0
			@lastPushAttempt = new Date().valueOf()
			reqwest(
				url: "#{@syncUrl}"
				type: "json"
				method: "post"
				data: 
					appName: @client.appName
					appType: @client.appType
					clientId: @client.id
					pushedAt: @lastPushAttempt
					commands: (command.toHash() for command in unsyncedCommands)
				error: => console.log "push error"
				success: (response)=>
					if response.success
						@client.lastUpdate = @lastPushAttempt
					else
						@reconcileTimeout = setTimeout(@reconcile, 1000) if response.message is "reconcile required" and not @reconcileTimeout?
			)

	reconcile: =>
		commandList = { }
		commandList[@client.id] = (command.toHash() for command in @organizer.local.commands)
		for externalClient in @externalClients
			commands = @organizer.commandsFor(externalClient.id) 
			commandList["#{externalClient.id}"] = (command.toHash() for command in commands)

		reqwest(
			url: "#{@syncUrl}/reconcile"
			type: "json"
			method: "post"
			data:
				appName: @client.appName
				appType: @client.appType
				clientId: @client.id
				externalClients: @externalClients
				commandList: commandList
				stableTimestamp: @stableTimestamp
			error: => console.log "reconcile error"
			success: (response)=>
				if response.success
					clearInterval @reconcileTimeout
					@reconcileTimeout = null
				else
					@reconcileTimeout = setTimeout(@reconcile, 1000) if response.message is "reconcile required"
		)

return Synchronizer