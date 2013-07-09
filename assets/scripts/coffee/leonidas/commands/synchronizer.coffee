require 'lib/reqwest'

Command = require "leonidas/commands/command"

class Synchronizer

	constructor: (@syncUrl, @client, @organizer, @processor)->
		@stableTimestamp = 0
		@externalClients = { }
		@lastPushAttempt = 0
		@connectionSuccessful = true

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
			error: => @connectionSuccessful = false
			success: (response)=>
				@connectionSuccessful = true
				if response.success
					if response.data.commands.length > 0
						newCommands = (new Command(command.name, command.data, command.clientId, new Date(command.timestamp), command.id) for command in response.data.commands)
						oldestNewTimestamp = Math.min.apply(Math, (command.timestamp for command in newCommands))
						@processor.rollbackCommands @organizer.commandsFrom(oldestNewTimestamp)
						@organizer.external.addCommands newCommands
						@processor.runCommands @organizer.commandsFrom(oldestNewTimestamp)
					@externalClients[client.id] = client.lastUpdate for client in response.data.externalClients
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
					commands: buildCommandsObject unsyncedCommands
				error: => @connectionSuccessful = false
				success: (response)=>
					@connectionSuccessful = true
					if response.success
						@client.lastUpdate = @lastPushAttempt
					else
						@reconcileTimeout = setTimeout(@reconcile, 1000) if response.message is "reconcile required" and not @reconcileTimeout?
			)

	reconcile: =>
		commandList = { }
		commandList[@client.id] = buildCommandsObject @organizer.local.commands
		for externalClientId of @externalClients
			commands = @organizer.commandsFor(externalClientId) 
			commandList[externalClientId] = buildCommandsObject commands

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
			error: => @connectionSuccessful = false
			success: (response)=>
				@connectionSuccessful = true
				if response.success
					clearInterval @reconcileTimeout
					@reconcileTimeout = null
				else
					@reconcileTimeout = setTimeout(@reconcile, 1000) if response.message is "reconcile required"
		)

	isOnline: -> @connectionSuccessful

	buildCommandsObject = (commands)->
		commandsObject = { }
		commandsObject[command.id] = command.toHash() for command in commands
		commandsObject

return Synchronizer