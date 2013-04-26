class Command

	constructor: (@name, @data, timestamp=null)->
		@timestamp = if timestamp? then timestamp else new Date().getTime()

	toHash: ->
		{ name: @name, data: @data, timestamp: @timestamp }

return Command