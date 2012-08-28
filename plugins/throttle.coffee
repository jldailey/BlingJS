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
			# must be a silence of _ms_ (where f is not even attempted)
			# before f will be callable again.
			last = 0
			(a...) ->
				last += (gap = $.now - last)
				return f.apply @,a if gap > ms else null
