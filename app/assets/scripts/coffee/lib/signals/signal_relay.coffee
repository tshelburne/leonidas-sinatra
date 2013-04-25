Signal = require "lib/signals/signal"

#
# @author - Tim Shelburne <tim@musiconelive.com>
#
# relays a dispatched signal
#
class SignalRelay extends Signal
  constructor: (signal)->
    super()
    signal.add(@dispatch)

  applyListeners: (rest)->
    listener.apply(listener, rest) for listener in @listeners

return SignalRelay