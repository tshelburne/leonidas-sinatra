Client = require 'leonidas/client'
Processor = require 'leonidas/commands/processor'

describe "Processor", ->
	command1 = command2 = null
	processor = null
	client = null

	beforeEach ->
		command1 = buildCommand(new Date(4, 1, 2013), { number: 1 })
		command2 = buildCommand(new Date(4, 2, 2013), { number: 2 }, "multiply")
		client = buildClient()
		processor = new Processor([ new IncrementHandler(client.activeState), new MultiplyHandler(client.activeState)])

	describe "#runCommand", ->

		it "will run a command", ->
			processor.runCommand command1
			expect(client.activeState).toEqual { integer: 2 }

	describe "#runCommands", ->

		it "will run multiple commands", ->
			processor.runCommands [ command1, command2 ]
			expect(client.activeState).toEqual { integer: 4 }

	describe "#rollbackCommand", ->

		it "will rollback a command", ->
			processor.runCommand command1
			processor.rollbackCommand command1
			expect(client.activeState).toEqual { integer: 1 }

	describe "#rollbackCommands", ->

		it "will rollback multiple commands", ->
			processor.runCommands [ command1, command2 ]
			processor.rollbackCommands [ command2, command1 ]
			expect(client.activeState).toEqual { integer: 1 }