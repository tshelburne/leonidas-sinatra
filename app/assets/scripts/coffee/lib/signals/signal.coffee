#
# @author - Tim Shelburne <tim@musiconelive.com>
#
# a basic implementation of a signal dispatcher to mimic AS3-Signals
#
class Signal
  constructor: ->
    @isApplyingListeners = false
    @listeners = []
    @onceListeners = []
    @removeCache = []

  add: (listener)->
    @listeners.push listener

  addOnce: (listener)->
    @onceListeners.push listener
    @add(listener)

  remove: (listener)->
    if @isApplyingListeners
      @removeCache.push listener
    else
      @listeners.splice(@listeners.indexOf(listener), 1) unless @listeners.indexOf(listener) is -1

  removeAll: ->
    @listeners = []

  numListeners: ->
    @listeners.length

  dispatch: (rest...)=>
    @isApplyingListeners = true
    @applyListeners(rest)
    @removeOnceListeners()
    @isApplyingListeners = false
    @clearRemoveCache()
    
  applyListeners: (rest)->
    listener.apply(listener, rest) for listener in @listeners

  removeOnceListeners: ->
    @remove listener for listener in @onceListeners
    @onceListeners = []

  clearRemoveCache: ->
    @remove(listener) for listener in @removeCache
    @removeCache = []

return Signal