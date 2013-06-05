Command = require 'leonidas/commands/command'

describe "Command", ->
	command = null

	beforeEach ->
		command = new Command("test", { testData: "test" }, "client id", new Date(2013, 4, 1), "command-id")

	describe "#hasRun", ->

		it "will default to false", ->
			expect(command.hasRun()).toBeFalsy()

		it "will return true when the command has been run", ->
			command.markAsRun()
			expect(command.hasRun()).toBeTruthy()

		it "will return false when the command hasn't been run", ->
			command.markAsRun()
			command.markAsNotRun()
			expect(command.hasRun()).toBeFalsy()

	describe "#markAsRun", ->

		it "will mark the command as having been run", ->
			command.markAsRun()
			expect(command.hasRun()).toBeTruthy()

	describe "#markAsNotRun", ->

		it "will mark the command as not having been run", ->
			command.markAsRun()
			command.markAsNotRun()
			expect(command.hasRun()).toBeFalsy()

	describe "#toHash", ->

		it "will return the command serialized as a hash", ->
			expect(command.toHash()).toEqual { id: "command-id", name: "test", data: { testData: "test" }, clientId: "client id", timestamp: new Date(2013, 4, 1).getTime() }