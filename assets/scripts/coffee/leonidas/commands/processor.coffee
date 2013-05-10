class Processor
	
	constructor: (@handlers)->

	runCommand: (command)->
		for handler in @handlers
			handler.run command if handler.handles command

	runCommands: (commands)->
		for command in commands
			@runCommand command

	rollbackCommand: (command)->
		for handler in @handlers
			handler.rollback command if handler.handles command

	rollbackCommands: (commands)->
		for command in commands
			@rollbackCommand command

return Processor