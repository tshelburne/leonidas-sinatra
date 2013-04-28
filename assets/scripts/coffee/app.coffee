Client = require "leonidas/client"
CommandManager = require "leonidas/command_manager"

LogHandler = require "handlers/log_handler"
IncrementHandler = require "handlers/increment_handler"

class App

	constructor: (clientId)->
		@client = new Client(clientId, { currentValue: 0 })
		@commander = @buildCommandManager(@client)

	buildCommandManager: (client)->
		handlers = [
			new LogHandler(),
			new IncrementHandler(client.activeState)
		]
		CommandManager.default(client, handlers, environment.url("sync"))

return App