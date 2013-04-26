class LogHandler

	handles: (command)->
		command.name is "log"

	run: (command)->
		console.log "#{command.data.message} at #{command.timestamp}"

return LogHandler