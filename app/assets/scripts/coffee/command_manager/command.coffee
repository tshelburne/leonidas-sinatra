class Command

	constructor: (@name, @data, timestamp=null)->
		@timestamp = timestamp? ? timestamp : new Date().getTime()

	asHash: ->
		{ name: @name, data: @data, timestamp: @timestamp }

return Command