Organizer = require "leonidas/commands/organizer"
Processor = require "leonidas/commands/processor"
Synchronizer = require "leonidas/commands/synchronizer"
Commander = require 'leonidas/commander'

describe "Commander", ->
	state = null
	commander = null
	client = null
	organizer = null
	synchronizer = null

	beforeEach ->
		state = { value: 1 }
		client = buildClient()
		organizer = new Organizer()
		processor = new Processor([ new MultiplyHandler(state) ])
		synchronizer = new Synchronizer("http://mydomain.com/sync", client, organizer, processor)
		commander = new Commander(client, organizer, processor, synchronizer)

	describe "::create", ->

		it "will create a Commander instance using the included classes", ->
			commander = Commander.create(client, [ new MultiplyHandler(state) ], "http://mydomain.com/sync")
			expect(commander.constructor).toEqual Commander

	describe "#startSync", ->

		beforeEach -> 
			jasmine.log synchronizer
			jasmine.Clock.useMock()
			spyOn(synchronizer, "push")
			spyOn(synchronizer, "pull")

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
			spyOn(synchronizer, "push")
			spyOn(synchronizer, "pull")

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

	describe "#forceSync", ->

		beforeEach ->
			spyOn(synchronizer, "push")
			spyOn(synchronizer, "pull")

		it "will immediately push any updates", ->
			commander.forceSync()
			expect(synchronizer.push).toHaveBeenCalled()

		it "will immediately pull any updates", ->
			commander.forceSync()
			expect(synchronizer.pull).toHaveBeenCalled()

	describe "#issueCommand", ->

		it "will generate a local command", ->
			commander.issueCommand "multiply", { number: 3 }
			expect(organizer.local.commands.length).toEqual 1

		it "will run the command to update the local client state", ->
			commander.issueCommand "multiply", { number: 3 }
			expect(state.value).toEqual 3

	describe "#isOnline", ->

		it "will return true when the synchronizer is able to communicate with the server", ->
			spyOn(window, 'reqwest').andCallFake( (params)-> params.success(mocks.reconcileRequiredResponse))
			commander.forceSync()
			expect(commander.isOnline()).toBeTruthy()

		it "will return false when the synchronizer isn't able to communicate with the server", ->
			spyOn(window, 'reqwest').andCallFake( (params)-> params.error())
			commander.forceSync()
			expect(commander.isOnline()).toBeFalsy()
