Client = require "leonidas/client"
Commander = require "leonidas/commander"

LogHandler = require "handlers/log_handler"
IncrementHandler = require "handlers/increment_handler"

class App

	constructor: (clientId)->
		@client = new Client(clientId, { currentValue: 0 })
		@commander = @buildCommander(@client)

	buildCommander: (client)->
		handlers = [
			new LogHandler(),
			new IncrementHandler(client.activeState)
		]
		Commander.default(client, handlers, environment.url("sync"))

return App