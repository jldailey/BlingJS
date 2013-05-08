$.plugin
	provides: "core"
	depends: "string"
, ->
	# Core Plugin
	# -----------
	# The functional basis for all other modules.  Provides all the
	# basic stuff that you are familiar with from jQuery: 'each', 'map',
	# etc.

	# $.now: the current timestamp
	$.defineProperty $, "now",
		get: -> +new Date

	# Negative indices should work the same everywhere.
	index = (i, o) ->
		i += o.length while i < 0
		Math.min i, o.length

	baseTime = $.now
	return {
		$:
			log: $.extend((a...) ->
				prefix = "+#{$.padLeft String($.now - baseTime), $.log.prefixSize, '0'}:"
				if prefix.length > $.log.prefixSize + 2
					prefix = "#{baseTime = $.now}:"
				if a.length and $.is "string", a[0]
					a[0] = "#{prefix} #{a[0]}"
				else
					a.unshift prefix
				console.log a...
				return a[a.length-1] if a.length
			, prefixSize: 5)
			assert: (c, m="") -> if not c then throw new Error("assertion failed: #{m}")
			coalesce: (a...) -> $(a).coalesce()
			keysOf: (o) -> $(k for k of o)
			valuesOf: (o) -> $.keysOf(o).map (k)->
				return try o[k] catch err then err

		# Get a new set containing only the i-th element of _this_.
		eq: (i) -> $([@[index i, @]])

		# Call a function on every item in _this_.
		each: (f) -> (f.call(t,t) for t in @); @

		# Get a new set with the results of calling a function of every
		# item in _this_.
		map: (f) -> # CS comprehensions generate too much extra code for such a critical bottle-neck
			b = $()
			i = 0
			(b[i++] = f.call t,t) for t in @
			return b

		filterMap: (f) ->
			b = $()
			for t in @
				v = f.call t,t
				if v?
					b.push v
			b
		
		# Chainable way to apply some arbitrary function
		tap: (f) -> f.call @, @

		replaceWith: (array) ->
			for i in [0...array.length] by 1
				@[i] = array[i]

		# Reduce _this_ to a single value, accumulating in _a_.
		# Example: `(a,x) -> a+x` == `(a) -> a+@`.
		reduce: (f, a) ->
			i = 0; n = @length
			# Init the accumulation.
			a = @[i++] if not a?
			# Run the reducer function across all items.
			(a = f.call @[x], a, @[x]) for x in [i...n] by 1
			# Return the accumulation.
			return a
		# Get a new set with every item from _this_ and from _other_. `strict` refers to whether
		# to use == or === for comparison.
		union: (other, strict = true) ->
			ret = $()
			ret.push(x) for x in @ when not ret.contains(x, strict)
			ret.push(x) for x in other when not ret.contains(x, strict)
			ret
		# Get a new set without duplicates.
		distinct: (strict = true) -> @union @, strict
		# Get a new set whose items are all in _this_ and _other.
		intersect: (other) -> $(x for x in @ when x in other) # another very beatiful expression
		# True if item is in _this_ set.
		contains: (item, strict = true) -> ((strict and t is item) or (not strict and `t == item`) for t in @).reduce ((a,x) -> a or x), false
		# Get an integer count of items in _this_.
		count: (item, strict = true) -> $(1 for t in @ when (item is undefined) or (strict and t is item) or (not strict and `t == item`)).sum()
		# Get the first non-null item in _this_.
		coalesce: ->
			for i in @
				if $.is('array',i) or $.is('bling',i) then i = $(i).coalesce()
				if i? then return i
			null
		# Swap item i with item j, in-place.
		swap: (i,j) ->
			i = index i, @
			j = index j, @
			if i isnt j
				[@[i],@[j]] = [@[j],@[i]]
			@
		# Randomly shuffle every item, in-place.
		shuffle: ->
			i = @length-1
			while i >= 0
				@swap --i, Math.floor(Math.random() * i)
			@

		# Get a new set of properties from every item in _this_.
		select: do ->
			# First, a private helper that will read property `prop` from some object later.
			getter = (prop) -> -> if $.is("function",v = @[prop]) then $.bound(@,v) else v
			# Recursively split `p` on `.` and map the getter helper
			# to read a set of complex `p` values from an object.
			# > `$([x]).select("name") == [ x.name ]`
			# > `$([x]).select("childNodes.1.nodeName") == [ x.childNodes[1].nodeName ]`
			selectOne = (p) ->
				switch type = $.type p
					when 'regexp' then selectMany.call @, p
					when 'string'
						if (i = p.indexOf '.') > -1 then @select(p.substr 0,i).select(p.substr i+1)
						else @map(getter p)
					else $()
			selectMany = (a...) ->
				n = @length
				lists = Object.create(null)
				for p in a
					if $.is 'regexp', p
						for match in $.keysOf(@first()).filter(p)
							lists[match] = @select(match)
					else lists[p] = @select(p)
				i = 0
				@map ->
					obj = Object.create(null)
					for p of lists
						obj[$(p.split '.').last()] = lists[p][i]
					i++
					obj
			return ->
				switch arguments.length
					when 1 then selectOne.apply @, arguments
					when 2 then selectMany.apply @, arguments

		# Replace any false-ish items in _this_ with _x_.
		# > `$("<a>").select('parentNode').or(document)`
		or: (x) -> @[i] or= x for i in [0...@length]; @

		# Assign the value _v_ to property _b_ on every
		# item in _this_.
		zap: (p, v) ->
			# `zap` supports the same dot-delimited property name scheme
			# that `select` uses. It does this by using `select`
			# internally.

			# Optionally, accepts .zap({ width: 10, height: 20 });
			if ($.is 'object', p) and not v?
				@zap(k,v) for k,v of p
				return @

			# Find the last "." in `p` so we can split into a head (to
			# send to `select`) and a tail (a simple value to assign to).
			i = p.lastIndexOf "."

			if i > 0
				# Use `select` to fetch the head portion, the tail will be
				# a single property with no dots, which we recurse on (into
				# a lower branch next time).
				head = p.substr 0,i
				tail = p.substr i+1
				@select(head).zap tail, v
				return @

			switch $.type(v)
				# If _v_ is a sequence of values, they are striped across each
				# item in _this_.
				when "array","bling" then @each -> @[p] = v[++i % v.length]
				# If _v_ is a function, map and set each item's property,
				# akin to: `x[p] = v(x[p])`.
				when "function" then @zap p, @select(p).map(v)
				# Anything else, scalars, objects, null, anything, get
				# assigned directly to each item in this.
				else @each -> @[p] = v
			@

		# Remove a property from each item.
		clean: (prop) -> @each -> delete @[prop]

		# Get a new set with only the first _n_ items from _this_.
		take: (n = 1) ->
			end = Math.min n, @length
			$( @[i] for i in [0...end] by 1 )

		# Get a new set with every item except the first _n_ items.
		skip: (n = 0) ->
			start = Math.max 0, n|0
			$( @[i] for i in [start...@length] by 1 )

		# Get the first item(s).
		first: (n = 1) -> if n is 1 then @[0] else @take(n)

		# Get the last item(s).
		last: (n = 1) -> if n is 1 then @[@length - 1] else @skip(@length - n)

		# Get a subset of _this_ including [/i/../j/-1]
		slice: (start=0, end=@length) ->
			start = index start, @
			end = index end, @
			$( @[i] for i in [start...end] )

		# Append the items in _b_ into _this_. Modifies _this_ in-place.
		extend: (b) -> @.push(i) for i in b; @

		# Appends a single item to _this_; unlike a native Array, it
		# returns a reference to _this_ for chaining.
		push: (b) -> Array::push.call(@, b); @

		# Get a new set containing only items that match _f_. _f_ can be
		# any of:
		filter: (f, limit, positive) ->
			if $.is "bool", limit
				[positive, limit] = [limit, positive]
			if $.is "number", positive
				[limit, positive] = [positive, limit]
			limit ?= @length
			positive ?= true
			# The argument _f_ can be any of:
			g = switch $.type f
				# * selector string: `.filter("td.selected")`
				when "string" then (x) -> x.matchesSelector(f)
				# * RegExp object: `.filter(/^prefix-/)`
				when "regexp" then (x) -> f.test(x)
				# * function: `.filter (x) -> (x%2) is 1`
				when "function" then f
				else throw new Error "unsupported argument to filter: #{$.type f}"
			a = $()
			for it in @
				if (!! g.call it,it) is positive
					if --limit < 0
						break
					a.push it
			a

		# Get a new set of booleans, true if the node from _this_
		# matched the CSS expression.
		matches: (expr) ->
			switch $.type expr
				when "string" then @select('matchesSelector').call(expr)
				when "regexp" then @map (x) -> expr.test x
				else throw new Error "unsupported argument to matches: #{$.type expr}"

		# Each node in _this_ contributes all children matching the
		# CSS expression to a new set.
		querySelectorAll: (expr) ->
			@filter("*")
			.reduce (a, i) ->
				a.extend i.querySelectorAll expr
			, $()

		# Get a new set with items interleaved from the items in _a_ and
		# _b_. The result is:
		# > `$([ b[i], this[i], ... ])`
		weave: (b) ->
			c = $()
			# First spread out _this_, from back to front.
			for i in [@length-1..0] by -1
				c[(i*2)+1] = @[i]
			# Then interleave items from _b_, from front to back
			for i in [0...b.length] by 1
				c[i*2] = b[i]
			c
		# Notes about `weave`:
		# * the items of b come first.
		# * the result always has 2 * max(length) items.
		# * if b and this are different lengths, the shorter will yield
		# `undefined`(s) into the result.

		# Get a new set with _c_ = `f(a,b)`. Will always return a set
		# with half as many items as _this_.
		fold: (f) ->
			n = @length
			b = $( f.call @, @[i], @[i+1] for i in [0...n-1] by 2 )
			# If there is an odd man out, make one last call
			if (n%2) is 1
				b.push( f.call @, @[n-1], undefined )
			b
		# Tip: use `fold` as a companion to `weave`; weave two blings together,
		# then fold them back to the original size.

		# Get a new set with all items from subsets in one set.
		flatten: ->
			b = $()
			(b.push(j) for j in i) for i in @
			b

		# Call every function in _this_ with the same arguments.
		call: -> @apply(null, arguments)

		# Apply every function in _this_ to _context_ with _args_.
		apply: (context, args) ->
			@filterMap ->
				if $.is 'function', @ then @apply(context, args)
				else null

		# Log one line for each item in _this_.
		log: (label) ->
			if label
				$.log(label, @toString(), @length + " items")
			else
				$.log(@toString(), @length + " items")
			@

		# Convert this to an array.
		toArray: ->
			@__proto__ = Array::
			@ # no copies, yay?

		# Remove all items
		clear: -> @splice 0, @length

	}
