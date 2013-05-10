Handler = require 'leonidas/commands/handler'

describe "Handler", ->
	handler = null

	beforeEach ->
		handler = new Handler()
		handler.name = "increment"

	describe "#handles", ->

		it "will return true when the submitted command has the same name value as the handler", ->
			expect(handler.handles buildCommand(new Date())).toBeTruthy()

		it "will return false when the submitted command has a different name value than the handler", ->
			expect(handler.handles buildCommand(new Date(), "multiply")).toBeFalsy()

	describe "#run", ->

		it "will always throw, because it should be overridden", ->
			expect(-> handler.run buildCommand(new Date())).toThrow()