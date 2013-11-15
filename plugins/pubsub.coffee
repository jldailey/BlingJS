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
			caught = null
			for listener in @listeners[channel] or= []
				if @filter(listener, args...)
					try listener(args...)
					catch err
						caught ?= err
			if caught then throw caught
			switch args.length
				when 0 then null
				when 1 then args[0]
				else args
		filter: (listener, message) ->
			if 'patternObject' of listener
				return $.matches listener.patternObject, message
			return true
		publisher: (channel, func) -> # Use as a function decorator
			t = @ # dont use => because we need both t and @ in the new publisher
			-> t.publish channel, func.apply @, arguments
		subscribe: (channel, args...) ->
			func = args.pop()
			if args.length > 0
				func.patternObject = args.pop()
			(@listeners[channel] or= []).push func
			func
		unsubscribe: (channel, func) ->
			if not func?
				@listeners[channel] = []
			else
				a = (@listeners[channel] or= [])
				if (i = a.indexOf func)  > -1
					a.splice i,1
			func

	return {
		$: $.extend new Hub(), { Hub }
	}
