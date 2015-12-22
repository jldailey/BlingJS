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
	provides: "delay,immediate,interval"
	depends: "is,select,extend,bound"
, ->
	$:
		delay: do ->
			# timeoutQueue is a private array that controls the order.
			timeoutQueue = $.extend [], do ->
				next = (a) -> -> (do a.shift()) if a.length; null
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
					@

			# Note that this reverses the order of _n_ and _f_
			# intentionally.  Throughout this library, the convention is
			# to put the simple things first, to improve code flow:
			# > `$.delay 5, ->` is better than `$.delay (->), 5`
			(n, f) -> switch
				when $.is 'object', n
					b = $($.delay(k,v) for k,v of n)
					{
						cancel: -> b.select('cancel').call()
						unref: -> b.select('unref').call()
						ref: -> b.select('ref').call()
					}
				when $.is "function", f
					timeoutQueue.add f, parseInt(n,10)
					{
						cancel: -> timeoutQueue.cancel(f)
						unref: (f) -> f.timeout?.unref()
						ref: (f) -> f.timeout?.ref()
					}
				else throw new Error "Bad arguments to $.delay (expected: int,function given: #{$.type n},#{$.type f})"

		immediate: do -> switch
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
		$.delay n, $.bound @, f
		@
