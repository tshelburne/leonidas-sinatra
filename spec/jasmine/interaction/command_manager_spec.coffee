CommandSource = require 'leonidas/command_source'
CommandOrganizer = require "leonidas/command_organizer"
CommandProcessor = require "leonidas/command_processor"
CommandStabilizer = require "leonidas/command_stabilizer"
CommandSynchronizer = require "leonidas/command_synchronizer"
CommandManager = require 'leonidas/command_manager'

describe "CommandManager", ->
	manager = null
	commandSource = null
	commandOrganizer = null

	beforeEach ->
		commandSource = new CommandSource("1234", { string: "value" })
		commandOrganizer = new CommandOrganizer()
		commandProcessor = new CommandProcessor([ new PopCharHandler(commandSource.activeState) ])
		commandStabilizer = new CommandStabilizer(commandSource, commandOrganizer, commandProcessor)
		commandSynchronizer = new CommandSynchronizer("http://mydomain.com/sync", commandOrganizer, commandStabilizer)

		manager = new CommandManager(commandOrganizer, commandProcessor, commandStabilizer, commandSynchronizer)

	describe "#startSync", ->

		it "will set the synchronizer to begin pushing updates", ->

		it "will set the synchronizer to begin pulling updates", ->

	describe "#stopSync", ->

		it "will stop the synchronizer from pushing updates", ->

		it "will stop the synchronizer from pulling updates", ->

	describe "#addCommand", ->

		it "will generate an unsynchronized command", ->

		it "will run the command to update the local client state", ->
			manager.addCommand "pop-char", {}
			expect(commandSource.activeState.string).toEqual "valu"