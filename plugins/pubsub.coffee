# Publish/Subscribe plugin
# -----------------
# Publish messages to a named channel, those messages invoke each
# function subscribed to that channel.
$.plugin
	depends: "core"
	provides: "pubsub"
, ->
	class Hub
		constructor: ->
			@listeners = {} # a mapping of channel name to a list of listeners
		publish: (channel, args...) ->
			f.apply null, args for f in (@listeners[channel] or= [])
			args
		publisher: (channel, func) -> # Use as a function decorator
			t = @
			-> t.publish channel, func.apply @, arguments
		subscribe: (channel, func) ->
			(@listeners[channel] or= []).push func
			func
		unsubscribe: (channel, func) ->
			if not func?
				@listeners[channel] = []
			else
				a = (@listeners[channel] or= [])
				if (i = a.indexOf func)  > -1
					a.splice(i,i)

	return {
		$: $.extend new Hub(),
			Hub: Hub
	}
