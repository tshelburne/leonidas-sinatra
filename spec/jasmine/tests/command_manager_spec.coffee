CommandOrganizer = require "leonidas/command_organizer"
CommandProcessor = require "leonidas/command_processor"
CommandStabilizer = require "leonidas/command_stabilizer"
CommandSynchronizer = require "leonidas/command_synchronizer"
CommandManager = require 'leonidas/command_manager'

describe "CommandManager", ->
	manager = null
	source = null
	organizer = null
	synchronizer = null

	beforeEach ->
		source = buildSource()
		organizer = new CommandOrganizer()
		processor = new CommandProcessor([ new PopCharHandler(source.activeState) ])
		stabilizer = new CommandStabilizer(source, organizer, processor)
		synchronizer = new CommandSynchronizer("http://mydomain.com/sync", source, organizer, stabilizer)
		spyOn(synchronizer, "push")
		spyOn(synchronizer, "pull")
		manager = new CommandManager(organizer, processor, stabilizer, synchronizer)

	describe "::default", ->

		it "will return a default command manager using the built in classes", ->
			manager = CommandManager.default(source, [ new PopCharHandler("tim") ], "http://mydomain.com/sync")
			expect(manager.constructor.name).toEqual "CommandManager"

	describe "#startSync", ->

		beforeEach -> 
      jasmine.Clock.useMock()

		it "will set the synchronizer to begin pushing updates", ->
     	manager.startSync()
     	jasmine.Clock.tick(5500)
     	expect(synchronizer.push.calls.length).toEqual 5

		it "will set the synchronizer to begin pulling updates", ->
     	manager.startSync()
     	jasmine.Clock.tick(11000)
     	expect(synchronizer.pull.calls.length).toEqual 2

	describe "#stopSync", ->

		beforeEach -> 
      jasmine.Clock.useMock()

		it "will stop the synchronizer from pushing updates", ->
			manager.startSync()
			manager.stopSync()
			jasmine.Clock.tick(10000)
			expect(synchronizer.push).not.toHaveBeenCalled()

		it "will stop the synchronizer from pulling updates", ->
			manager.startSync()
			manager.stopSync()
			jasmine.Clock.tick(10000)
			expect(synchronizer.pull).not.toHaveBeenCalled()

	describe "#issueCommand", ->

		it "will generate an unsynchronized command", ->
			manager.issueCommand "pop-char", {}
			expect(organizer.unsyncedCommands.length).toEqual 1

		it "will run the command to update the local client state", ->
			manager.issueCommand "pop-char", {}
			expect(source.activeState.string).toEqual "tes"