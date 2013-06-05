class Command

	constructor: (@name, @data, @clientId, timestamp=null, @id=null)->
		@timestamp = if timestamp? then timestamp else new Date()
		@hasBeenRun = false

	hasRun: -> @hasBeenRun

	markAsRun: -> @hasBeenRun = true

	markAsNotRun: -> @hasBeenRun = false

	toHash: -> { id: @id, name: @name, data: @data, clientId: @clientId, timestamp: @timestamp.getTime() }

return Command