class IncrementHandler

	constructor: (@state)->

	handles: (command)->
		command.name is "increment"

	run: (command)->
		@state.currentValue++

return IncrementHandler