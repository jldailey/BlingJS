# Events plugin
# -------------
# Things like `.bind('click')`, `.trigger('keyup')`, etc.
$.plugin
	depends: "dom,function,core"
	provides: "event"
, ->
	EVENTSEP_RE = /,* +/
	# This is a list of (almost) all the event types, each one of
	# these will get a short-hand version like: `$("...").mouseup()`.
	# "click" is omitted on purpose, it is handled specially.
	events = ['mousemove','mousedown','mouseup','mouseover','mouseout','blur','focus',
		'load','unload','reset','submit','keyup','keydown','keypress','change',
		'abort','cut','copy','paste','selection','drag','drop','orientationchange',
		'touchstart','touchmove','touchend','touchcancel',
		'gesturestart','gestureend','gesturecancel',
		'hashchange'
	]

	binder = (e) -> (f) ->
		if $.is "function", f then @bind e, f
		else @trigger e, f

	_get = (self, keys...) ->
		return if keys.length is 0 then self
		else _get (self[keys[0]] or= Object.create null), keys.slice(1)...

	# Detect and fire the document's `ready` event.
	triggerReady = $.once ->
		$(document).trigger("ready").unbind("ready")
		document.removeEventListener?("DOMContentLoaded", triggerReady, false)
		$.global.removeEventListener?("load", triggerReady, false)
	document.addEventListener?("DOMContentLoaded", triggerReady, false)
	$.global.addEventListener?("load", triggerReady, false)

	_b = (funcName) -> (e, f) ->
		c = (e or "").split EVENTSEP_RE
		@each -> (@[funcName] i, f, true) for i in c

	ret = {
		# __.bind(e, f)__ adds handler f for event type e.
		# `$("...").bind('click', -> )`
		bind: _b "addEventListener"

		# __.unbind(e, [f])__ remove handler[s] for event _e_. If _f_ is
		# not passed, then remove all handlers.
		unbind: _b "removeEventListener"

		# __.trigger(e, [args])__ creates (and fires) a fake event on some DOM nodes.
		trigger: (evt, args = {}) ->
			args = $.extend
				bubbles: true
				cancelable: true
			, args

			for evt_i in (evt or "").split(EVENTSEP_RE)
				switch evt_i
					when "click", "mousemove", "mousedown", "mouseup", "mouseover", "mouseout" # mouse events
						e = document.createEvent "MouseEvents"
						args = $.extend
							detail: 1,
							screenX: 0,
							screenY: 0,
							clientX: 0,
							clientY: 0,
							ctrlKey: false,
							altKey: false,
							shiftKey: false,
							metaKey: false,
							button: 0,
							relatedTarget: null
						, args
						e.initMouseEvent evt_i, args.bubbles, args.cancelable, $.global, args.detail,
							args.screenX, args.screenY, args.clientX, args.clientY,
							args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.button, args.relatedTarget

					when "blur", "focus", "reset", "submit", "abort", "change", "load", "unload" # UI events
						e = document.createEvent "UIEvents"
						e.initUIEvent evt_i, args.bubbles, args.cancelable, $.global, 1

					when "touchstart", "touchmove", "touchend", "touchcancel" # touch events
						e = document.createEvent "TouchEvents"
						args = $.extend
							detail: 1,
							screenX: 0,
							screenY: 0,
							clientX: 0,
							clientY: 0,
							ctrlKey: false,
							altKey: false,
							shiftKey: false,
							metaKey: false,
							# touch values:
							touches: [],
							targetTouches: [],
							changedTouches: [],
							scale: 1.0,
							rotation: 0.0
						, args
						e.initTouchEvent evt_i, args.bubbles, args.cancelable, $.global, args.detail,
							args.screenX, args.screenY, args.clientX, args.clientY,
							args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.touches, args.targetTouches, args.changedTouches, args.scale, args.rotation

					when "gesturestart", "gestureend", "gesturecancel" # gesture events
						e = document.createEvent "GestureEvents"
						args = $.extend {
							detail: 1,
							screenX: 0,
							screenY: 0,
							clientX: 0,
							clientY: 0,
							ctrlKey: false,
							altKey: false,
							shiftKey: false,
							metaKey: false,
							# gesture values:
							target: null,
							scale: 1.0,
							rotation: 0.0
						}, args
						e.initGestureEvent evt_i, args.bubbles, args.cancelable, $.global,
							args.detail, args.screenX, args.screenY, args.clientX, args.clientY,
							args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.target, args.scale, args.rotation

					when  "keydown", "keypress", "keyup"
						e = document.createEvent "KeyboardEvents"
						args = $.extend {
							view: null,
							ctrlKey: false,
							altKey: false,
							shiftKey: false,
							metaKey: false,
							keyCode: 0,
							charCode: 0
						}, args
						e.initKeyboardEvent evt_i, args.bubbles, args.cancelable, $.global,
							args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.keyCode, args.charCode

					# iphone events that are not supported yet (dont know how to create yet, needs research)
					# iphone events that we cant properly emulate (because we cant create our own Clipboard objects)
					# iphone events that are just plain events
					# and general events
					# else if evt_i in ["drag", "drop", "selection", "cut", "copy", "paste", "orientationchange"]
					else
						e = document.createEvent "Events"
						e.initEvent evt_i, args.bubbles, args.cancelable
						e = $.extend e, args

				continue unless e
				@each ->
					try @dispatchEvent e
					catch err then $.log "dispatchEvent error:", err
			@

		# __.delegate(selector, e, f)__ bind _f_ to handle event _e_ for child nodes that will exist in the future
		delegate: (selector, e, f) ->
			h = (evt) => # Create the delegate handler
				t = $(evt.target)
				@find(selector)
					# See if the event would bubble up into a match.
					.intersect(t.parents().first().union t)
					# Then fire the real _f_ on the nodes that really matched.
					.each -> f.call evt.target = @, evt
			@bind(e, h) # Bind the delegate handler
				.each -> _get(@,'__alive__',selector,e)[f] = h # Save a reference for undelegate
		undelegate: (selector, e, f) ->
			context = @
			context.each ->
				c = _get(@,'__alive__',selector,e) # Find the saved reference to h
				try context.unbind e, c[f] # Unbind h from everything in the context
				finally delete c[f] # Remove the saved reference to f so we don't leak it.

		# __.click([f])__ triggers the 'click' event but also sets a
		# default clickable appearance.
		click: (f = {}) ->
			# Only if the current appearance has not been set.
			if @css("cursor") in ["auto",""]
				# Then make it look clickable.
				@css "cursor", "pointer"
			# Bind or trigger just like other events, e.g. "mouseup".
			if $.is "function", f then @bind 'click', f
			else @trigger 'click', f
			@

		ready: (f) ->
			return (f.call @) if triggerReady.exhausted
			@bind "ready", f
	}

	# add event binding/triggering shortcuts for the generic events
	events.forEach (x) -> ret[x] = binder x
	return ret

