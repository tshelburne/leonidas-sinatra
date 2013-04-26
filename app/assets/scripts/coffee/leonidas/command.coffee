class Command

	constructor: (@name, @data, timestamp=null)->
		@timestamp = if timestamp? then timestamp else new Date().getTime()

	asHash: ->
		{ name: @name, data: @data, timestamp: @timestamp }

return Command