(($) ->
	# Delay Plugin
	# ------------
	# **Q**: Since JS uses a single event loop, what happens if multiple
	# setTimeout/Intervals are scheduled at a time when the event loop is busy?

	# **A**: All the due functions are called in no particular order; even if
	# they were clearly scheduled in a sequence like:
	# `setTimeout(f,1); setTimeout(g,2)`.  These will execute in
	# random order when using setTimeout directly.  This isn't
	# necessarily about timer (in)accuracy, it's about how it
	# stores and dequeues handlers.
	$.plugin
		provides: "delay"
		depends: "function"
	, ->
		$:
			delay: (->
				# timeoutQueue is a private array that controls the order.
				timeoutQueue = $.extend [], (->
					next = (a) -> -> a.shift()() if a.length
					add: (f, n) ->
						f.order = n + $.now
						for i in [0..@length] by 1
							if i is @length or @[i].order > f.order
								@splice i,0,f
								break
						setTimeout next(@), n
						@
					cancel: (f) ->
						for i in [0...@length] by 1
							if @[i] == f
								@splice i, 1
								break
						@
				)()

				# Note that this reverses the order of _n_ and _f_
				# intentionally.  Throughout this library, the convention is
				# to put the simple things first, to improve code flow:
				# > `$.delay 5, () ->` is better than `$.delay (() -> ), 5`
				(n, f) ->
					if $.is("function",f) then timeoutQueue.add(f, n)
					cancel: -> timeoutQueue.cancel(f)

			)()

		# Continue with _f_ after _n_ milliseconds.
		delay: (n, f, c=@) ->
			$.delay n, $.bound(c, f)
			@

)(Bling)
