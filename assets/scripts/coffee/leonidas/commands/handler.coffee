class Handler

	handles: (command)->
		command.name is @name

	run: (command)->
		throw new Error "Every CommandHandler should override to process a command #run."

return Handler