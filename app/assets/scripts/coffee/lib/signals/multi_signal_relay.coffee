Signal = require "lib/signals/signal"

#
# @author - Tim Shelburne <tim@musiconelive.com>
#
# can relay messages coming from multiple signals
#
class MultiSignalRelay extends Signal
  constructor: (signals)->
    super()
    for signal in signals
      signal.add(@dispatch)

  applyListeners: (rest)->
    listener.apply(listener, rest) for listener in @listeners

return MultiSignalRelay