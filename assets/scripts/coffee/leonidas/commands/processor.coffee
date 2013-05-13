class Processor
	
	constructor: (@handlers)->

	runCommand: (command)->
		for handler in @handlers
			handler.run command if handler.handles command

	runCommands: (commands)->
		commands.sort (a,b)-> if a.timestamp > b.timestamp then 1 else -1
		@runCommand command for command in commands

	rollbackCommand: (command)->
		for handler in @handlers
			handler.rollback command if handler.handles command

	rollbackCommands: (commands)->
		commands.sort (a,b)-> if a.timestamp < b.timestamp then 1 else -1
		@rollbackCommand command for command in commands

return Processor