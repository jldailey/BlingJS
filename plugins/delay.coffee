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
		delay: do ->
			# timeoutQueue is a private array that controls the order.
			timeoutQueue = $.extend [], do ->
				next = (a) -> -> a.shift()() if a.length
				add: (f, n) ->
					$.extend f,
						order: n + $.now
						timeout: setTimeout next(@), n
					for i in [0..@length] by 1
						if i is @length or @[i].order > f.order
							@splice i,0,f
							break
					@
				cancel: (f) ->
					if (i = @indexOf f) > -1
						@splice i, 1
						clearTimeout f.timeout
					else $.log "Warning: attempted to cancel a delay that wasn't waiting:", f
					@

			# Note that this reverses the order of _n_ and _f_
			# intentionally.  Throughout this library, the convention is
			# to put the simple things first, to improve code flow:
			# > `$.delay 5, ->` is better than `$.delay (->), 5`
			(n, f) ->
				if $.is 'object', n
					b = $($.delay(k,v) for k,v of n).select('cancel')
					cancel: -> b.call()
				else if $.is('function', f)
					timeoutQueue.add f, parseInt(n,10)
					cancel: -> timeoutQueue.cancel(f)
				else $.log "Warning: bad arguments to $.delay (expected: int,function given: #{$.type n},#{$.type f})"

		immediate: do ->
			return switch true
				when 'setImmediate' of $.global then $.global.setImmediate
				when process?.nextTick? then process.nextTick
				else (f) -> setTimeout(f, 0)
		interval: (n, f) ->
			paused = false
			ret = $.delay n, g = ->
				unless paused then do f
				$.delay n, g
			$.extend ret,
				pause: (p=true) -> paused = p
				resume: (p=true) -> paused = not p


	# Continue with _f_ after _n_ milliseconds.
	delay: (n, f) ->
		$.delay n, f
		@

