class IncrementHandler

	constructor: (@value)->

	handles: (command)->
		command.name is "increment"

	run: (command)->
		@value++

return IncrementHandler