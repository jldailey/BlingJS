# A very simple middleware pattern, abstracted.
# each middleware is a function (args..., next)

$.plugin
	provides: 'middleware',
	depends: 'type'
, ->

	$.type.register 'middleware', is: (o) ->
		try return $.are 'function', o.use, o.unuse, o.invoke
		catch err then return false
	


	$: middleware: (s = []) -> # start with a stack of middleware functions
		e = $() # error handlers
		use:    (f)    -> s.push f                                  ; @
		unuse:  (f)    -> s.splice i, 1 while (i = s.indexOf f) > -1; @
		invoke: (a...) -> # kick off the sequence of calls to middleware
			i = -1
			# each call to `next` calls the next middleware in order
			# because it is passed to the middleware as last argument
			# the middleware decides whether to continue the chain or not
			do next = (=> try (s[++i] a..., next) catch _e then e.call _e)
			@
		catch:   (f)   -> e.push f
