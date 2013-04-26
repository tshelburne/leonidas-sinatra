globalize class IncrementHandler

	constructor: (@value)->

	handles: (command)->
		command.name is "increment"

	run: (command)->
		@value++


globalize class PopCharHandler

	constructor: (@value)->

	handles: (command)->
		command.name is "pop-char"

	run: (command)->
		@value = @value.slice(0,-1)