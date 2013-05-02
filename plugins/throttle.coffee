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
			# f will be called only on the last of a burst of attempts
			# the end of a burst is a gap of _ms_ duration
			timeout = null
			(a...) ->
				if timeout isnt null
					clearTimeout timeout
				timeout = setTimeout (=>
					if timeout isnt null
						clearTimeout timeout
						timeout = null
					f.apply @,a
				), ms
