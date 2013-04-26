CommandOrganizer = require 'leonidas/command_organizer'
CommandProcessor = require 'leonidas/command_processor'
CommandStabilizer = require 'leonidas/command_stabilizer'
CommandSynchronizer = require 'leonidas/command_synchronizer'

describe "CommandSynchronizer", ->
	command1 = command2 = command3 = command4 = null
	synchronizer = null

	beforeEach ->
		source = buildSource()
		organizer = new CommandOrganizer()
		command1 = buildCommand(1)
		command2 = buildCommand(2, "pop-char")
		command3 = buildCommand(3, "pop-char")
		command4 = buildCommand(4)
		processor = new CommandProcessor([ new IncrementHandler(source.activeState), new PopCharHandler(source.activeState)])
		stabilizer = new CommandStabilizer(source, organizer, processor)
		synchronizer = new CommandSynchronizer("http://mydomain.com/sync", source, organizer, stabilizer)

	describe "#push", ->

		it "will send a source id for reference to the client", ->

		it "will send a list of all currently unsynced commands", ->

		describe "when successful", ->

			it "will mark the commands pushed as synced", ->

			it "will not mark unsynced commands added since push was called as synced", ->

			it "will lock to a new stable state", ->

			it "will deactivate stable commands", ->

	describe "#pull", ->

		it "will send a list of sources and their current timestamp", ->

		describe "when successful", ->

			it "will add the list of received commands as synced commands", ->

			it "will lock to a new stable state", ->

			it "will deactivate stable commands", ->