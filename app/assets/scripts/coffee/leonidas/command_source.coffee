class CommandSource

  constructor: (@id, state)->
    @lockedState = state
    @activeState = state

  revertState: -> @activeState = @lockedState

  lockState: -> @lockedState = @activeState

return CommandSource