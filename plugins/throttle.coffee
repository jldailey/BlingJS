# Throttle Plugin
# ---------------
# `$.throttle` and `$.debounce` are two different ways to rate limit
# a function.  Both are function decorators.
$.plugin
	provides: "throttle"
	depends: "core"
, ->
	$:
		throttle: (ms, f) ->
			# f will be callable once every _ms_ milliseconds.
			last = 0
			(a...) ->
				gap = $.now - last
				if gap > ms
					last += gap
					return f.apply @,a
				null
		debounce: (ms, f) ->
			timeout = null
			->
				a = arguments
				clearTimeout timeout
				timeout = setTimeout (=>
					f.apply @, a
				), ms

