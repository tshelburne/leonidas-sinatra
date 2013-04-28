Command = require 'leonidas/commands/command'

describe "Command", ->
	command = null

	beforeEach ->
		command = new Command("test", { testData: "test" }, 25)

	describe "#toHash", ->

		it "will return the command serialized as a hash", ->
			expect(command.toHash()).toEqual { name: "test", data: { testData: "test" }, timestamp: 25 }