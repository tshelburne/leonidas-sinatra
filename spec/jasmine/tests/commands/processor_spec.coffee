Client = require 'leonidas/client'
Processor = require 'leonidas/commands/processor'

describe "Processor", ->
	processor = null
	client = null

	beforeEach ->
		client = buildClient()
		processor = new Processor([ new IncrementHandler(client.activeState), new PopCharHandler(client.activeState)])

	describe "#processCommand", ->

		it "will run a command", ->
			processor.processCommand buildCommand(1)
			expect(client.activeState).toEqual { integer: 2, string: "test" }

	describe "#processCommands", ->

		it "will run multiple commands", ->
			processor.processCommands [ buildCommand(1), buildCommand(2, "pop-char") ]
			expect(client.activeState).toEqual { integer: 2, string: "tes" }