class Command

	constructor: (@name, @data, @clientId, timestamp=null)->
		@timestamp = if timestamp? then timestamp else new Date()

	toHash: ->
		{ name: @name, data: @data, clientId: @clientId, timestamp: @timestamp.getTime() }

return Command