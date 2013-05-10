Handler = require 'leonidas/commands/handler'

globalize class IncrementHandler extends Handler

	constructor: (@state)->
		@name = "increment"

	run: (command)-> @state.integer += command.data.number

	rollback: (command)-> @state.integer -= command.data.number


globalize class MultiplyHandler extends Handler

	constructor: (@state)->
		@name = "multiply"

	run: (command)-> @state.integer *= command.data.number

	rollback: (command)-> @state.integer /= command.data.number