# Publish/Subscribe plugin
# -----------------
# Publish messages to a named channel, those messages invoke each
# function subscribed to that channel.
$.plugin
	provides: "pubsub"
, ->
	subscribers = {} # a mapping of channel name to a list of subscribers
	$:
		publish: (e, args...) ->
			f.apply null, args for f in (subscribers[e] or= [])
			args
		publisher: (e, func) ->
			(args...) ->
				$.publish e, func.apply @, args
		subscribe: (e, func) ->
			(subscribers[e] or= []).push func
			func
		unsubscribe: (e, func) ->
			if not func?
				subscribers[e] = []
			else
				a = (subscribers[e] or= [])
				if (i = a.indexOf func)  > -1
					a.splice(i,i)
