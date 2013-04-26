CommandSource = require 'leonidas/command_source'
CommandProcessor = require 'leonidas/command_processor'

describe "CommandProcessor", ->
	processor = null
	source = null

	beforeEach ->
		source = buildSource()
		processor = new CommandProcessor([ new IncrementHandler(source.activeState), new PopCharHandler(source.activeState)])

	describe "#processCommand", ->

		it "will run a command", ->
			processor.processCommand buildCommand(1)
			expect(source.activeState).toEqual { integer: 2, string: "test" }

	describe "#processCommands", ->

		it "will run multiple commands", ->
			processor.processCommands [ buildCommand(1), buildCommand(2, "pop-char") ]
			expect(source.activeState).toEqual { integer: 2, string: "tes" }