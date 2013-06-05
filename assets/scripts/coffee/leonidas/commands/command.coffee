class Command

	constructor: (@name, @data, @clientId, timestamp=null, @id=null)->
		@timestamp = if timestamp? then timestamp else new Date()

	toHash: -> { id: @id, name: @name, data: @data, clientId: @clientId, timestamp: @timestamp.getTime() }

return Command