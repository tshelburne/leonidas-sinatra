CommandSource = require "leonidas/command_source"
CommandManager = require "leonidas/command_manager"

LogHandler = require "handlers/log_handler"
IncrementHandler = require "handlers/increment_handler"

class App

	constructor: (sourceId)->
		@source = new CommandSource(sourceId, { currentValue: 0 })
		@commander = @buildCommandManager(@source)

	buildCommandManager: (source)->
		handlers = [
			new LogHandler(),
			new IncrementHandler(source.activeState)
		]
		CommandManager.default(source, handlers, environment.url("sync"))

return App