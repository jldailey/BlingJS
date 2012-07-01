(($) ->
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
		# "click" is handled specially.
		events = ['mousemove','mousedown','mouseup','mouseover','mouseout','blur','focus',
			'load','unload','reset','submit','keyup','keydown','change',
			'abort','cut','copy','paste','selection','drag','drop','orientationchange',
			'touchstart','touchmove','touchend','touchcancel',
			'gesturestart','gestureend','gesturecancel',
			'hashchange'
		]

		binder = (e) -> (f) -> @bind(e, f) if $.is "function", f else @trigger(e, f)

		register_live = (selector, context, evt, f, h) ->
			$(context).bind(evt, h)
				# set/create all of @__alive__[selector][evt][f]
				.each -> (((@__alive__ or= {})[selector] or= {})[evt] or= {})[f] = h

		unregister_live = (selector, context, e, f) ->
			$c = $(context)
			$c.each ->
				a = (@__alive__ or= {})
				b = (a[selector] or= {})
				c = (b[e] or= {})
				$c.unbind(e, c[f])
				delete c[f]

		# Detect and fire the document's `ready` event.
		triggerReady = $.once ->
			$(document).trigger("ready").unbind("ready")
			document.removeEventListener?("DOMContentLoaded", triggerReady, false)
			window.removeEventListener?("load", triggerReady, false)
		bindReady = $.once ->
			document.addEventListener?("DOMContentLoaded", triggerReady, false)
			window.addEventListener?("load", triggerReady, false)
		bindReady()

		ret = {
			# __.bind(e, f)__ adds handler f for event type e.
			# `$("...").bind('click', -> )`
			bind: (e, f) ->
				c = (e or "").split(EVENTSEP_RE)
				h = (evt) ->
					ret = f.apply @, arguments
					if ret is false
						evt.preventAll()
					ret
				@each -> (@addEventListener i, h, false) for i in c

			# __.unbind(e, [f])__ remove handler[s] for event _e_. If _f_ is
			# not passed, then remove all handlers.
			unbind: (e, f) ->
				c = (e or "").split EVENTSEP_RE
				@each -> (@removeEventListener i, f, null) for i in c

			# __.trigger(e, [args])__ creates (and fires) a fake event on some DOM nodes.
			trigger: (evt, args = {}) ->
				args = $.extend
					bubbles: true
					cancelable: true
				, args

				for evt_i in (evt or "").split(EVENTSEP_RE)
					if evt_i in ["click", "mousemove", "mousedown", "mouseup", "mouseover", "mouseout"] # mouse events
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
						e.initMouseEvent evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
							args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.button, args.relatedTarget

					else if evt_i in ["blur", "focus", "reset", "submit", "abort", "change", "load", "unload"] # UI events
						e = document.createEvent "UIEvents"
						e.initUIEvent evt_i, args.bubbles, args.cancelable, window, 1

					else if evt_i in ["touchstart", "touchmove", "touchend", "touchcancel"] # touch events
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
						e.initTouchEvent(evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
							args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.touches, args.targetTouches, args.changedTouches, args.scale, args.rotation)

					else if evt_i in ["gesturestart", "gestureend", "gesturecancel"] # gesture events
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
						e.initGestureEvent evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
							args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.target, args.scale, args.rotation

					# iphone events that are not supported yet (dont know how to create yet, needs research)
					# iphone events that we cant properly emulate (because we cant create our own Clipboard objects)
					# iphone events that are just plain events
					# and general events
					# else if evt_i in ["drag", "drop", "selection", "cut", "copy", "paste", "orientationchange"]
					else
						e = document.createEvent "Events"
						e.initEvent evt_i, args.bubbles, args.cancelable
						try
							e = $.extend e, args
						catch err

					if not e
						continue
					else
						try
							@each -> @dispatchEvent e
						catch err
							$.log "dispatchEvent error:", err
				@

			# __.live(e, f)__ bind _f_ to handle events for nodes that will exist in the future.
			live: (e, f) ->
				selector = @selector
				context = @context
				# Create a wrapper for _f_.
				handler = (evt) ->
					# The wrapper will:
					# Re-execute the selector in the original context.
					$(selector, context)
						# See if the event would bubble up into a match.
						.intersect($(evt.target).parents().first().union($(evt.target)))
						# Then fire the real _f_ on the nodes that really matched.
						.each -> f.call(evt.target = @, evt)
				# Register _f_ and it's wrapper, so we can find it later if we need to `die`.
				register_live selector, context, e, f, handler
				@

			# __.die(e, [f])__ remove _f_ [or all handlers] that are living
			# for event _e_.
			die: (e, f) ->
				$(@context).unbind e, unregister_live(@selector, @context, e, f)
				@

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
		events.forEach (x) -> ret[x] = binder(x)
		return ret
)(Bling)

