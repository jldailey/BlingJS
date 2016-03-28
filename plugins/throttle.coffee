# Throttle Plugin
# ---------------
# `$.throttle` and `$.debounce` are two different ways to rate limit
# a function.  Both are function decorators.
$.plugin
	provides: "throttle"
	depends: "core"
, ->

	defer = (f, ctx, args, ms, to) ->
		clearTimeout to
		to = setTimeout (=>
			f.apply ctx, args
		), ms
		return to

	throttle = (f, ctx, args, ms, last) ->
		if (dt = $.now - last) > ms
			last += dt
			f.apply ctx, args
		return last

	$:
		throttle: (ms, f) ->
			# f will be callable once every _ms_ milliseconds.
			last = 0
			->
				last = throttle f, @, arguments, ms, last
				null

		debounce: (ms, f) ->
			timeout = null
			->
				a = arguments
				timeout = defer f, @, arguments, ms, timeout
				null

		rate_limit: (ms, f) ->
			"""
			rate_limit is a combination of throttle and debounce.
			 what we want from a stream throttle is to fire at most every _ms_ and
			 then fire one last time after a gap of _ms_ at the end.
			"""
			last = 0
			timeout = null
			->
				a = arguments
				timeout = defer f, @, arguments, ms, timeout
				last = throttle f, @, arguments, ms, last
				null

