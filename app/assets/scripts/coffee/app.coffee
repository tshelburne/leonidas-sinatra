CommandSource = require "command_manager/command_source"
CommandManager = require "command_manager/command_manager"
CommandOrganizer = require "command_manager/command_organizer"
CommandProcessor = require "command_manager/command_processor"
CommandSynchronizer = require "command_manager/command_synchronizer"
CommandFinalizer = require "command_manager/command_finalizer"

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
		commandProcessor = new CommandProcessor(handlers)
		
		commandOrganizer = new CommandOrganizer()

		new CommandManager(
			commandSource, 
			commandOrganizer, 
			commandProcessor,
			new CommandSynchronizer(),
			new CommandFinalizer(commandSource, commandOrganizer, commandProcessor)
		)

return App