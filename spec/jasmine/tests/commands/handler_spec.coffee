Handler = require 'leonidas/commands/handler'

describe "Handler", ->
	incrementCommand = multiplyCommand = null
	handler = null

	beforeEach ->
		incrementCommand = buildCommand new Date(), { number: 1 }
		multiplyCommand  = buildCommand new Date(), { number: 2 }, "multiply"
		handler = new Handler()
		handler.name = "increment"

	describe "#handles", ->

		it "will return true when the submitted command has the same name value as the handler", ->
			expect(handler.handles incrementCommand).toBeTruthy()

		it "will return false when the submitted command has a different name value than the handler", ->
			expect(handler.handles multiplyCommand).toBeFalsy()

	describe "#run", ->

		it "will always throw, because it should be overridden", ->
			expect(-> handler.run incrementCommand).toThrow()

	describe "#rollback", ->

		it "will always throw, because it should be overridden", ->
			expect(-> handler.rollback incrementCommand).toThrow()