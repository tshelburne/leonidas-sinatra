Handler = require 'leonidas/commands/handler'

globalize class IncrementHandler extends Handler

	constructor: (@state)->
		@name = "increment"

	run: (command)-> @state.value += command.data.number

	rollback: (command)-> @state.value -= command.data.number


globalize class MultiplyHandler extends Handler

	constructor: (@state)->
		@name = "multiply"

	run: (command)-> @state.value *= command.data.number

	rollback: (command)-> @state.value /= command.data.number