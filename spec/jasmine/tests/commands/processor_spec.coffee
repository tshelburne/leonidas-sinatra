Processor = require 'leonidas/commands/processor'

describe "Processor", ->
	state = null
	command1 = command2 = null
	processor = null

	beforeEach ->
		state = { value: 1 }
		command1 = buildCommand(new Date(2013, 4, 1), { number: 1 })
		command2 = buildCommand(new Date(2013, 4, 2), { number: 2 }, "multiply")
		processor = new Processor([ new IncrementHandler(state), new MultiplyHandler(state)])

	describe "#runCommand", ->

		it "will run a command", ->
			processor.runCommand command1
			expect(state.value).toEqual 2

	describe "#runCommands", ->

		it "will run multiple commands", ->
			processor.runCommands [ command1, command2 ]
			expect(state.value).toEqual 4

	describe "#rollbackCommand", ->

		it "will rollback a command", ->
			processor.runCommand command1
			processor.rollbackCommand command1
			expect(state.value).toEqual 1

	describe "#rollbackCommands", ->

		it "will rollback multiple commands", ->
			processor.runCommands [ command1, command2 ]
			processor.rollbackCommands [ command2, command1 ]
			expect(state.value).toEqual 1