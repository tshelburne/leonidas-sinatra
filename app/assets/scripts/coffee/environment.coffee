class Environment

	constructor: ->
		@urls = {}

	addUrl: (key, path)->
		@urls[key] = path

	url: (key)->
		@urls[key]

(exports ? this).environment = new Environment()