class CommandSource

  constructor: (@id, state)->
    @lockedState = { }
    @activeState = { }
    @copyState(@lockedState, state)
    @copyState(@activeState, state)

  revertState: -> @copyState(@activeState, @lockedState)

  lockState: -> @copyState(@lockedState, @activeState)

  copyState: (to, from)-> 
    delete to[key] for key of to
    to[key] = value for key, value of from

return CommandSource