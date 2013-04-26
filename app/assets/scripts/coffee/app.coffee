CommandSource = require "leonidas/command_source"
CommandManager = require "leonidas/command_manager"

LogHandler = require "handlers/log_handler"
IncrementHandler = require "handlers/increment_handler"

class App

	constructor: (sourceId)->
		@commandSource = new CommandSource(sourceId, { currentValue: 0 })
		@commandManager = @buildCommandManager(@commandSource)

	buildCommandManager: (commandSource)->
		handlers = [
			new LogHandler(),
			new IncrementHandler(commandSource.currentState.currentValue)
		]
		CommandManager.default(commandSource, handlers, environment.url("sync"))

return App