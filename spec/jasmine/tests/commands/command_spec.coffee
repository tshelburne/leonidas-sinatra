Command = require 'leonidas/commands/command'

describe "Command", ->
	command = null

	beforeEach ->
		command = new Command("test", { testData: "test" }, "client id", new Date(2013, 4, 1), "command-id")

	describe "#toHash", ->

		it "will return the command serialized as a hash", ->
			expect(command.toHash()).toEqual { id: "command-id", name: "test", data: { testData: "test" }, clientId: "client id", timestamp: new Date(2013, 4, 1).getTime() }