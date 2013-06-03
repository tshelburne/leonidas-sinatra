class Client

  constructor: (@id, @appName, @appType="", lastUpdate=null)->
  	throw new Error "Client Id is required" unless @id?
  	throw new Error "App Name is required" unless @appName?
  	@lastUpdate = if lastUpdate? then lastUpdate else 0

return Client