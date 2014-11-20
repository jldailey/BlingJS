# A very simple middleware pattern, abstracted.
# each middleware is a function (args..., next)

$.plugin
	provides: 'middleware',
	depends: 'type'
, ->

	$.type.register 'middleware', is: (o) ->
		try return $.are 'function', o.use, o.use, o.invoke
		catch err then return false

	$: middleware: (s = []) ->
		use:    (f)    -> s.push f                                  ; @
		unuse:  (f)    -> s.splice i, 1 while (i = s.indexOf f) > -1; @
		invoke: (a...) -> i = -1; do n = (-> try s[++i] a..., n)    ; @
