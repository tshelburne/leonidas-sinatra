require "lib/jquery"

Signal = require "lib/signals/signal"

Command = require "command_manager/command"

class CommandSynchronizer

	constructor: ->
		@pushed = new Signal()
		@pulled = new Signal()

	push: (commands)=>
		$.ajax(
			url: "/#{eventId}/sync"
			method: "POST"
			data: 
				sourceId: source.id
				commands: command.asHash() for command in commands
			error: @handlePushError
			success: @handlePushSuccess
		)

	handlePushError: =>
		console.log "push error"

	handlePushSuccess: (response)=>
		@pushed.dispatch(response.data.inactiveTimestamp)

	pull: =>
		$.ajax(
			url: "/#{eventId}/sync"
			method: "GET"
			error: @handlePullError
			success: @handlePullSuccess
		)

	handlePullError: =>
		console.log "pull error"

	handlePullSuccess: (response)=>
		commands = new Command(command.name, command.data, command.timestamp)) for command in response.data.commands
		@pulled.dispatch(commands, response.data.inactiveTimestamp)

return CommandSynchronizer