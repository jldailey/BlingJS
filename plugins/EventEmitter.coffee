$.plugin
	provides: "EventEmitter"
	depends: "type,hook"
, ->
	# EventEmitter Plugin
	# -------------------
	# The EventEmitter interface that NodeJS uses is much simpler (and
	# faster) than the DOM event model.  With this plugin, every new bling
	# becomes an EventEmitter automatically, you can extend a class from it:
	# `class Foo extends $.EventEmitter`, or you can mix it in to an instance:
	# `obj = $.EventEmitter(obj)`.
	$: EventEmitter: Bling.init.append (obj = {}) ->
		listeners = Object.create null
		list = (e) -> (listeners[e] or= [])
		$.inherit {
			emit:               (e, a...) -> (f.apply(@, a) for f in list(e)); @
			addListener:        (e, h) -> switch $.type e
				when 'object' then @addListener(k,v) for k,v of e
				when 'string' then list(e).push(h); @emit('newListener', e, h)
			on:                 (e, f) -> @addListener e, f
			removeListener:     (e, f) -> (l.splice i, 1) if (i = (l = list e).indexOf f) > -1
			removeAllListeners: (e) -> listeners[e] = []
			setMaxListeners:    (n) -> # who really needs this in the core API?
			listeners:          (e) -> list(e).slice 0
		}, obj
