do ($ = Bling) ->
	$.plugin
		provides: "EventEmitter"
		depends: "type,pipe"
	, ->
		# EventEmitter Plugin
		# -------------------
		# The EventEmitter interface that NodeJS uses is much simpler (and
		# faster) than the DOM event model.  With this plugin, every new
		# bling becomes an EventEmitter automatically, or you can mix it in
		# to any object: `$.EventEmitter(obj)`.
		$: EventEmitter: $.pipe("bling-init").append (obj) ->
			listeners = {}
			list = (e) -> (listeners[e] or= [])
			$.inherit {
				emit:               (e, a...) -> (f.apply(@, a) for f in list(e)); @
				addListener:        (e, h) -> list(e).push(h); @emit('newListener', e, h)
				on:                 (e, h) -> @addListener e, h
				removeListener:     (e, h) -> (list(e).splice i, 1) if (i = list(e).indexOf h) > -1
				removeAllListeners: (e) -> listeners[e] = []
				setMaxListeners:    (n) -> # who really needs this in the core API?
				listeners:          (e) -> list(e).slice 0
			}, obj
