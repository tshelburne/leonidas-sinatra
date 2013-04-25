CommandSource = require "command_manager/command_source"
CommandManager = require "command_manager/command_manager"

LogHandler = require "handlers/log_handler"
IncrementHandler = require "handlers/increment_handler"

class App

	constructor: (sourceId)->
		@commandSource = new CommandSource(sourceId, { currentValue: 0 })
		@commandManager = @buildCommandManager()

	buildCommandManager: (commandSource)->
		handlers = [
			new LogHandler(),
			new IncrementHandler(commandSource.currentState.currentValue)
		]
		CommandManager.default(commandSource, handlers, environment.url("sync"))

return App