CommandManager = require 'leonidas/command_manager'

describe "CommandManager", ->
	
	describe "::default", ->

		it "will return a default command manager using the built in classes", ->
			manager = CommandManager.default(mocks.commandSource, [ new PopCharHandler("tim") ], "http://mydomain.com/sync")
			expect(manager.startSync?).toBeTruthy()
			expect(manager.stopSync?).toBeTruthy()
			expect(manager.addCommand?).toBeTruthy()