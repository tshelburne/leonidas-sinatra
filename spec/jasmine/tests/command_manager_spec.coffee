CommandOrganizer = require "leonidas/command_organizer"
CommandProcessor = require "leonidas/command_processor"
CommandStabilizer = require "leonidas/command_stabilizer"
CommandSynchronizer = require "leonidas/command_synchronizer"
CommandManager = require 'leonidas/command_manager'

describe "CommandManager", ->
	manager = null
	source = null
	organizer = null

	beforeEach ->
		source = buildSource()
		organizer = new CommandOrganizer()
		processor = new CommandProcessor([ new PopCharHandler(source.activeState) ])
		stabilizer = new CommandStabilizer(source, organizer, processor)
		synchronizer = new CommandSynchronizer("http://mydomain.com/sync", source, organizer, stabilizer)

		manager = new CommandManager(organizer, processor, stabilizer, synchronizer)

	describe "::default", ->

		it "will return a default command manager using the built in classes", ->
			manager = CommandManager.default(source, [ new PopCharHandler("tim") ], "http://mydomain.com/sync")
			expect(manager.startSync?).toBeTruthy()
			expect(manager.stopSync?).toBeTruthy()
			expect(manager.addCommand?).toBeTruthy()
			# expect(manager::name).toEqual "CommandManager"

	describe "#startSync", ->

		it "will set the synchronizer to begin pushing updates", ->

		it "will set the synchronizer to begin pulling updates", ->

	describe "#stopSync", ->

		it "will stop the synchronizer from pushing updates", ->

		it "will stop the synchronizer from pulling updates", ->

	describe "#addCommand", ->

		it "will generate an unsynchronized command", ->
			manager.addCommand "pop-char", {}
			expect(organizer.unsyncedCommands.length).toEqual 1

		it "will run the command to update the local client state", ->
			manager.addCommand "pop-char", {}
			expect(source.activeState.string).toEqual "tes"