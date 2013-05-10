class Handler

	handles: (command)->
		command.name is @name

	run: (command)->
		throw new Error "Every CommandHandler should override #run."

	rollback: (command)->
		throw new Error "Every CommandHandler should override #rollback."

return Handler