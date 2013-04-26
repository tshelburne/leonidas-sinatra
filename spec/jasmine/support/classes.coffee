globalize class IncrementHandler

	constructor: (@state)->

	handles: (command)-> command.name is "increment"

	run: (command)-> @state.integer++


globalize class PopCharHandler

	constructor: (@state)->

	handles: (command)-> command.name is "pop-char"

	run: (command)-> @state.string = @state.string.slice(0,-1)