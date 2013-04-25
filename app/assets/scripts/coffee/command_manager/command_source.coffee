class CommandSource

  constructor: (@id, state)->
    @originalState = state
    @currentState = state

  revertState: -> @currentState = @originalState

  finalizeState: -> @originalState = @currentState

return CommandSource