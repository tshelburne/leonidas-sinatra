CommandManager = require 'command_manager/command_manager'

describe "CommandManager", ->
	manager = null

	beforeEach ->
		manager = new CommandManager()

	describe "::default", ->

		it "will return a default command manager using the built in classes", ->
			manager = CommandManager.default(mocks.commandSource, [ new PopCharHandler("tim") ], "http://mydomain.com/sync")
			expect(manager.prototype).toEqual CommandManager

  describe "#startSync", ->

  	it "will set the synchronizer to begin pushing updates", ->

  	it "will set the synchronizer to begin pulling updates", ->

  describe "#stopSync", ->

  	it "will stop the synchronizer from pushing updates", ->

  	it "will stop the synchronizer from pulling updates", ->

  describe "#addCommand", ->

  	it "will generate and unsynchronized command", ->

  	it "will run the command to update the local client state", ->