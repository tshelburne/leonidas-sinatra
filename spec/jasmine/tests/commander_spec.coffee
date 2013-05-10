Organizer = require "leonidas/commands/organizer"
Processor = require "leonidas/commands/processor"
Stabilizer = require "leonidas/commands/stabilizer"
Synchronizer = require "leonidas/commands/synchronizer"
Commander = require 'leonidas/commander'

describe "Commander", ->
	commander = null
	client = null
	organizer = null
	synchronizer = null

	beforeEach ->
		client = buildClient()
		organizer = new Organizer()
		processor = new Processor([ new PopCharHandler(client.activeState) ])
		stabilizer = new Stabilizer(client, organizer, processor)
		synchronizer = new Synchronizer("http://mydomain.com/sync", client, organizer, stabilizer)
		spyOn(synchronizer, "push")
		spyOn(synchronizer, "pull")
		commander = new Commander(client, organizer, processor, stabilizer, synchronizer)

	describe "::create", ->

		it "will create a Commander instance using the included classes", ->
			commander = Commander.create(client, [ new PopCharHandler("tim") ], "http://mydomain.com/sync")
			expect(commander.constructor).toEqual Commander

	describe "#startSync", ->

		beforeEach -> 
      jasmine.Clock.useMock()

		it "will set the synchronizer to begin pushing updates", ->
     	commander.startSync()
     	jasmine.Clock.tick(5500)
     	expect(synchronizer.push.calls.length).toEqual 5

		it "will set the synchronizer to begin pulling updates", ->
     	commander.startSync()
     	jasmine.Clock.tick(11000)
     	expect(synchronizer.pull.calls.length).toEqual 2

	describe "#stopSync", ->

		beforeEach -> 
      jasmine.Clock.useMock()

		it "will stop the synchronizer from pushing updates", ->
			commander.startSync()
			commander.stopSync()
			jasmine.Clock.tick(10000)
			expect(synchronizer.push).not.toHaveBeenCalled()

		it "will stop the synchronizer from pulling updates", ->
			commander.startSync()
			commander.stopSync()
			jasmine.Clock.tick(10000)
			expect(synchronizer.pull).not.toHaveBeenCalled()

	describe "#issueCommand", ->

		it "will generate an unsynchronized command", ->
			commander.issueCommand "pop-char", {}
			expect(organizer.unsyncedCommands.length).toEqual 1

		it "will run the command to update the local client state", ->
			commander.issueCommand "pop-char", {}
			expect(client.activeState.string).toEqual "tes"