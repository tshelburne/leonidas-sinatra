class Processor
	
	constructor: (@handlers)->

	processCommand: (command)->
		for handler in @handlers
			handler.run command if handler.handles command

	processCommands: (commands)->
		for command in commands
			@processCommand command

return Processor