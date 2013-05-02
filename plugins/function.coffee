# Function Plugin
# ---------------
# These are little function factories, for making new functions out of other functions.
$.plugin
	provides: "function"
	depends: "hash"
, ->
	$:
		# __$.identity(x)__ returns x.
		identity: (o) -> o
		# __$.not(f)__ returns a new function that returns `not f(...)`.
		not: (f) -> -> not f.apply @, arguments
		# __$.compose(f,g)__ composes _f_ and _g_ to `f(g(...))`.
		compose: (f,g) -> (x) -> f.call(y, (y = g.call(x,x)))
		# __$.and(f,g)__ returns a new function that returns f(x) && g(x).
		and: (f,g) -> (x) -> g.call(@,x) and f.call(@,x)
		# __$.once(f)__ returns a new function that will only call
		# _f_ **once**, or _n_ times if you pass the optional argument.
		once: (f, n=1) ->
			$.defineProperty (-> (f.apply @,arguments) if n-- > 0),
				"exhausted",
					get: -> n <= 0
		# __.cycle(f...)__ returns a new function that cycles through
		# other functions.
		cycle: (f...) ->
			i = -1
			-> f[i = ++i % f.length].apply @, arguments
		# __$.bound(context,f,[args])__ returns a new function that
		# assures `this === context` when called.
		bound: (t, f, args = []) ->
			return $.identity unless f?
			if $.is "function", f.bind
				args.splice 0, 0, t
				r = f.bind.apply f, args
			else
				r = (a...) -> f.apply t, (args if args.length else a)
			$.extend r, { toString: -> "bound-method of #{t}.#{f.name}" }
		# __$.partial(f, args...)__ returns a new function that
		# has a subset of the arguments already specified.
		partial: (f, a...) -> (b...) -> f a..., b...
	partial: (a...) -> @map (f) -> $.partial f, a...
