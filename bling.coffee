###

Named after the bling symbol ($) to which it is bound by default.
Blame: Jesse Dailey <jesse.dailey@gmail.com>
(Copyright) 2011
(License) released under the MIT License
http://creativecommons.org/licenses/MIT/

###

# local shortcuts
log = (a...) ->
	try return console.log?.apply console, a
	alert a.join(", ")

Object.defineProperty Object, 'global',
	get: () -> window ? global

# constants
OBJECT_RE = /\[object (\w+)\]/
ORD_A = "A".charCodeAt(0)
ORD_Z = "Z".charCodeAt(0)
ORD_a = "a".charCodeAt(0)

capital = (name) -> (name.split(" ").map (x) -> x[0].toUpperCase() + x.substring(1).toLowerCase()).join(" ")

Object.Keys ?= (o, inherited = false) -> (k for k of o when (inherited or o.hasOwnProperty(k)))

Object.Extend ?= (a, b, k) -> # Object.Extend(a, b, [whitelist]) - merge values from b into a
	if not Array.isArray(k)
		k = Object.Keys(b)
	for key in k
		v = b[key]
		if not v? then continue
		a[key] = v
	a

interfaces = {} # a private cache of defined interfaces

Object.Extend Object,
	Get: (o, key, def) ->
		dot = key.indexOf '.'
		switch true
			when dot isnt -1 then Object.Get(Object.Get(o, key.substring(0,dot)), key.substring(dot+1), def)
			when key of o then o[key]
			else def
	IsType: (T, o) -> # Object.IsType(o,T) - true if object o is of type T (directly or inherits)
		if not o? then T in [o,"null","undefined"]
		else if o.constructor is T then true
		else if typeof T is "string"
			o.constructor.name is T or Object::toString.apply(o).replace(OBJECT_RE, "$1") is T
		else # recurse through sub-classes
			Object.IsType T, o.__proto__
	Inherit: (c, o) -> # Object.Inherit(T, o) - similar to Extend, but hot-wires prototypes
		if typeof c is "string" and interfaces[c]?
			return Object.Inherit interfaces[c], o
		if typeof c is "function"
			o.constructor = c
			c = c.prototype
		o.__proto__ = c
		o
	Interface: (name, fields) -> interfaces[name] = fields # a simple interface system for duck-typing

Object.Interface 'Type',
	name: 'unknown'
	match: (o) -> true # is o an instance of this type

Object.Type = (()-> # this is a type classifier, and a way to group functionality around a type without stepping on any built-in prototypes
	order = [] # the order to check for matches
	cache = {} # data about registered types

	register = (name, data) ->
		Object["Is"+capital(name)] = (o) -> data.match.call o,o
		order.unshift name if not (name in order)
		cache[data.name = name] = Object.Inherit('Type', data)

	extend = (name, data) ->
		if not name?
			Object.Extend interfaces['Type'], data
		else if typeof name is "string"
			cache[name] = Object.Extend cache[name] ? register(name,{}), data
		else for k of name
			Object.Type.extend k, name[k]

	lookup = (obj) ->
		for name in order
			if cache[name]?.match.call obj, obj
				return cache[name]

	register "unknown",   match: -> true
	register "object",    match: -> typeof @ is "object"
	register "error",     match: -> Object.IsType 'Error', @
	register "regexp",    match: -> Object.IsType 'RegExp', @
	register "string",    match: -> typeof @ is "string" or Object.IsType String, @
	register "array",     match: -> Array.isArray?(@) or Object.IsType Array, @
	register "number",    match: -> Object.IsType Number, @
	register "bool",   match: -> typeof @ is "boolean" or String(@) in ["true","false"]
	register "function",  match: -> typeof @ is "function"
	register "global",    match: -> typeof @ is "object" and 'setInterval' of @
	register "undefined", match: (x) -> x is undefined
	register "null",      match: (x) -> x is null

	Object.Extend ((o) -> lookup(o).name),
		register: register
		lookup: lookup
		extend: extend
)()

Object.Extend Object,
	IsEmpty: (o) -> o in ["", null, undefined]
	IsSimple: (o) -> Object.Type(o) in ["string", "number", "bool"]
	String: (() ->
		Object.Type.extend null, toString: (o) -> o.toString?() ? String(o)
		Object.Type.extend
			null:
				toString: (o) -> "null"
			undefined:
				toString: (o) -> "undefined"
			string:
				toString: (o) -> o
			array:
				toString: (o) -> "[" + (Object.String(x) for x in o).join(",") + "]"
			number:
				toString: (o) -> switch true
					when o.precision? then o.toPrecision(o.precision)
					when o.fixed? then o.toFixed(o.fixed)
					else String(o)
		(x) -> Object.Type.lookup(x).toString(x)
	)()
	Hash: (() ->
		Object.Type.extend null, hash: (o) -> String.Checksum Object.String(o)
		Object.Type.extend
			object:
				hash: (o) -> (Object.Hash(o[k]) for k of o) + Object.Hash(Object.Keys(o))
			array:
				hash: (o) -> (Object.Hash(i) for i in x).reduce (a,x) -> a+x
			bool:
				hash: (o) -> parseInt(1 if o)
		(x) -> Object.Type.lookup(x).hash(x)
	)()
	Trace: (() ->
		Object.Type.extend null, trace: Function.Identity
		Object.Type.extend
			function:
				trace: (f, label, tracer) ->
					r = (a...) ->
						tracer "#{@name or Object.Type(@)}.#{label or f.name}(", a, ")"
						f.apply @, a
					tracer "Trace: #{label or f.name} created."
					r.toString = f.toString
					r
			object:
				trace: (o, label, tracer) -> (o[k] = Object.Trace(o[k], "#{label}.#{k}", tracer) for k in Object.Keys(o)); o
			array:
				trace: (o, label, tracer) -> (o[i] = Object.Trace(o[i], "#{label}[#{i}]", tracer) for i in [0...o.length]); o
		return (o, label, tracer) -> Object.Type.lookup(o).trace(o, label, tracer)
	)()

Object.Extend Function,
	Identity: (o) -> o # the empty function
	Not: (f) -> (x) -> not f(x)
	Compose: (f,g) -> (x) -> f.call(y, (y = g.call(x,x)))
	And: (f,g) -> (x) -> g.call(x,x) and f.call(x,x)
	Bound: (f, t, args = []) -> # Function.Bound(/f/, /t/) - whenever /f/ is called, _this_ is /t/
		if Object.IsFunction f.bind
			args.splice 0, 0, t
			r = f.bind.apply f, args
		else
			r = (a...) ->
				if args.length > 0
					a = args
				f.apply t, a
		r.toString = () ->
			"bound-method of #{t}.#{f.name}"
		r
	UpperLimit: (x) -> (y) -> Math.min(x, y)
	LowerLimit: (x) -> (y) -> Math.max(x, y)
	Px: (d) -> () -> Number.Px(@,d)
	Memoize: (f) ->
		cache = {} # a new cache for this function only
		(a...) -> cache[Object.Hash(a)] ?= f.apply @, a

Object.Extend String,
	Capitalize: capital
	Dashize: (name) ->
		ret = ""
		for i in [0...(name?.length|0)]
			c = name.charCodeAt i
			if ORD_Z >= c >= ORD_A # is upper case
				c = (c - ORD_A) + ORD_a # shift to lower
				ret += '-'
			ret += String.fromCharCode(c)
		return ret
	Camelize: (name) ->
		while (i = name?.indexOf('-')) > -1
			name = String.Splice(name, i, i+2, name[i+1].toUpperCase())
		name
	PadLeft: (s, n, c = " ") -> # String.PadLeft(string, width, fill=" ")
		while s.length < n
			s = c + s
		s
	PadRight: (s, n, c = " ") -> # String.PadRight(string, width, fill=" ")
		while s.length < n
			s = s + c
		s
	Splice: (s, i, j, n) -> # String.Splice(string, start, end, n) - replace a substring with n
		nn = s.length
		end = j
		if end < 0
			end += nn
		start = i
		if start < 0
			start += nn
		s.substring(0,start) + n + s.substring(end)
	Checksum: (s) -> # String.Checksum(string) - Adler32 checksum of a string
		a = 1; b = 0
		for i in [0...s.length]
			a = (a + s.charCodeAt(i)) % 65521
			b = (b + a) % 65521
		return (b << 16) | a
	Builder: () -> # String.Builder - builds a string
		if Object.IsWindow(@) then return new String.Builder()
		items = []
		@length   = 0
		@append   = (s) => items.push s; @length += s?.toString().length|0
		@prepend  = (s) => items.splice 0,0,s; @length += s?.toString().length|0
		@clear    = ( ) => ret = @toString(); items = []; @length = 0; ret
		@toString = ( ) => items.join("")
		@

Object.Extend Array,
	Coalesce: (a...) -> # Array.Coalesce - returns the first non-null argument
		for i in a
			if Object.IsArray(i) then i = Array.Coalesce i...
			if i? then return i
		null
	Extend: (a, b) -> (a.push(i) for i in b); a # works in-place; unlike concat
	Swap: (a, i,j) ->
		if i isnt j
			[a[i],a[j]] = [a[j],a[i]]
		a
	Shuffle: (a) ->
		i = a.length-1
		while i >= 0
			j = Math.floor(Math.random() * i)
			Array.Swap(a, i,j)
			i--
		a

Object.Extend Number,
	Px: (x, d=0) -> x? and (parseInt(x,10)+(d|0))+"px"
	AtLeast: (x) -> (y) -> Math.max parseFloat(y or 0), x
	AtMost: (x) -> (y) -> Math.min parseFloat(y or 0), x

Object.Type.extend null, toArray: (o) -> [o]
Object.Type.extend
	array:
		toArray: Function.Identity
	number:
		toArray: (o) -> new Array(o)
	undefined:
		toArray: (o) -> []
	null:
		toArray: (o) -> []
	string:
		toArray: (s,c) ->
			s = s.trimLeft()
			try
				if s[0] is "<"
					set = [Bling.HTML.parse(s)]
				else if c.querySelectorAll
					set = c.querySelectorAll(s)
				else
					throw Error "invalid context: #{c} (type: #{Object.Type c})"
			catch e
				throw Error "invalid selector: #{s} (error: #{e})"

default_context = document ? {}
Bling = (selector, context = default_context) ->
	set = Object.Inherit Bling, Object.Extend Object.Type.lookup(selector).toArray(selector, context),
			selector: selector
			context: context
	set.length = set.len()
	set
Bling.prototype = new Array # start with a shallow copy (!) of the Array prototype, plugins will extend
Bling.toString = () -> "function Bling(selector, context) { ... }" # dont waste a bunch of space in logs
Bling.plugins = []
Bling.plugin = (constructor) ->
	try
		name = constructor.name
		plugin = constructor.call Bling,Bling
		name = name or plugin.name
		if not name
			throw Error "plugin requires a 'name'"
		Bling.plugins.push(name)
		Bling.plugins[name] = plugin
		delete plugin.name
		# if a plugin defines root items, extend Bling directly
		if '$' of plugin
			# apply the root extensions
			Object.Extend(Bling, plugin['$'])
			delete plugin['$']
		# everything else about the plugin extends the prototype
		Object.Extend(Bling.prototype, plugin)
	catch error
		log "failed to load plugin: '#{name}', message: '#{error.message}'"
		throw error
Object.Type.register "bling",
	match: (o) -> Object.IsType Bling, o
	hash: (o) -> Object.Hash(o.selector) + o.map(Object.Hash).sum()
	toArray: Function.Identity
	toString: (o) -> Bling.symbol + "([" + o.map(Object.String).join(", ")+ "])"

(($) ->

	$.plugin () -> # Symbol - allow to safely use something other than $ by assigning to Bling.symbol
		symbol = null
		cache = {}
		g = Object.global
		g.Bling = Bling
		Object.defineProperty $, "symbol",
			set: (v) ->
				g[symbol] = cache[symbol]
				cache[v] = g[v]
				g[symbol = v] = Bling
			get: () -> symbol
		$.symbol = "$"

		return {
			name: "Symbol"
		}

	$.plugin () -> # Compat - compatibility patches
		leftSpaces_re = /^\s+/
		String::trimLeft ?= () -> @replace(leftSpaces_re, "")
		String::split ?= (sep) ->
			a = []; i = 0
			while (j = @indexOf sep,i) > -1
				a.push @substring(i,j)
				i = j + 1
			a
		Array::join ?= (sep = '') ->
			n = @length
			return "" if n is 0
			s = @[n-1]
			while --n > 0
				s = @[n-1] + sep + s
			s

		if Element?
			Element::matchesSelector = Array.Coalesce(
				Element::webkitMatchesSelector,
				Element::mozMatchesSelector,
				Element::matchesSelector
			)

			# if cloneNode does not take a 'deep' argument, add support
			if Element::cloneNode.length is 0
				oldClone = Element::cloneNode
				Element::cloneNode = (deep = false) ->
					n = oldClone.call(@)
					if deep
						for i in @childNodes
							n.appendChild i.cloneNode true
					return n

		return {
			name: "Compat"
		}

	$.plugin () -> # Core - the functional basis for all other modules
		TimeoutQueue = () -> # works like setTimeout but always fire callbacks in the order they were originally scheduled.
			q = []
			next = () => # next() consumes the next handler on the queue
				if q.length > 0
					q.shift()() # shift AND call
			@schedule = (f, n) => # schedule(f, n) sets f to run after n or more milliseconds
				if not Object.IsFunction(f)
					throw Error "function expected, got: #{Object.Type f}"
				nq = q.length
				f.order = n + new Date().getTime()
				if nq is 0 or f.order > q[nq-1].order # short-cut the common-case: f belongs after the end
					q.push(f)
				else
					for i in [0...nq]
						if q[i].order > f.order
							q.splice(i, 0, f)
							break
				setTimeout next, n
				return @
			@cancel = (f) =>
				if not Object.IsFunction(f)
					throw Error "function expected, got #{Object.Type(f)}"
				for i in [0...q.length]
					if q[i] == f
						q.splice(i, 1)
						break
			@
		timeoutQueue = new TimeoutQueue()

		getter = (prop) -> # used in .zip()
			() ->
				v = @[prop]
				if Object.IsFunction v
					return Function.Bound(v, @)
				return v
		zipper = (prop) -> # used in .zip()
			i = prop.indexOf(".")
			if i > -1
				return @zip(prop.substr(0, i)).zip(prop.substr(i+1))
			g = getter(prop)
			ret = @map(g)
			return ret

		return {
			name: 'Core'

			$:
				log: log
				assert: (c, m="") -> if not c then throw new Error("assertion failed: #{m}")
				delay: (n, f) ->
					if f
						timeoutQueue.schedule(f, n)
					# return an actor that can cancel
					return { cancel: () -> timeoutQueue.cancel(f) }
			toString: () -> Object.String(@)
			eq: (i) -> $([@[i]])
			each: (f) -> (f.call(t,t) for t in @); @
			map: (f) -> $(f.call(t,t) for t in @)
			reduce: (f, a) ->
				t = @
				if not a?
					a = @[0]
					t = @skip(1)
				(a = f.call x, a, x) for x in t
				a

			union: (other, strict = true) ->
				ret = $()
				ret.push(x) for x in @ when not ret.contains(x, strict)
				ret.push(x) for x in other when not ret.contains(x, strict)
				ret
			distinct: (strict = true) -> @union @, strict
			intersect: (other) -> $(x for x in @ when x in other) # another very beatiful expression
			contains: (item, strict = true) -> ((strict and t is item) or (not strict and t == item) for t in @).reduce(((a,x) -> a or x),false)
			count: (item, strict = true) -> $(1 for t in @ when (item is undefined) or (strict and t is item) or (not strict and t == item)).sum()

			zip: (a...) ->
				# .zip([/p/, ...]) - collects /x/./p/ for all /x/ in _this_.
				# recursively split names like "foo.bar"
				# zip("foo.bar") == zip("foo").zip("bar")
				# you can pass multiple properties, e.g.
				# zip("foo", "bar") == [ {foo: x.foo, bar: x.bar}, ... ]
				n = a.length
				switch n
					when 0
						return $()
					when 1
						ret = zipper.call(@, a[0])
						return ret
					else # > 1
						# if more than one argument is passed, new objects
						# with only those properties, will be returned
						set = {}
						nn = @len()
						list = $()
						j = 0 # insert marker into list
						# first collect a set of lists
						for i in [0...n]
							set[a[i]] = zipper.call(@, a[i])
						# then convert to a list of sets
						for i in [0...nn]
							o = {}
							for k of set
								o[k] = set[k].shift() # the first property from each list
							list[j++] = o # as a new object in the results
						list

			zap: (p, v) ->
				# .zap(p, v) - set /x/./p/ = /v/ for all /x/ in _this_.
				# just like zip, zap("a.b") == zip("a").zap("b")
				# but unlike zip, you cannot assign to different /p/ at once
				i = p.indexOf(".")
				if i > -1 # recurse compound names
					@zip(p.substr(0, i)).zap(p.substr(i+1), v)
				else if Object.IsArray(v) # accept /v/ as an array of values
					@each () ->
						@[p] = v[++i % v.length] # i starts at -1 because of the failed indexOf
				else if Object.IsFunction(v)
					@zap(p, @zip(p).map(v))
				else # accept a scalar /v/, even if v is undefined
					@each () ->
						@[p] = v

			take: (n) ->
				# .take([/n/]) - collect the first /n/ elements of _this_.
				# if n >= @length, returns a shallow copy of the whole bling
				nn = @len()
				start = 0
				end = Math.min n|0, nn
				if n < 0
					start = Math.max 0, nn+n
					end = nn
				a = $()
				j = 0
				for i in [start...end]
					a[j++] = @[i]
				a

			skip: (n = 0) ->
				# .skip([/n/]) - collect all but the first /n/ elements of _this_.
				# if n == 0, returns a shallow copy of the whole bling
				start = Math.max 0, n|0
				end = @len()
				a = $()
				j = 0
				for i in [start...end]
					a[j++] = @[i]
				a

			first: (n = 1) ->
				# .first([/n/]) - collect the first [/n/] element[s] from _this_.
				# if n is not passed, returns just the item (no bling)
				if n is 1
					@[0]
				else
					@take(n)

			last: (n = 1) ->
				# .last([/n/]) - collect the last [/n/] elements from _this_.
				# if n is not passed, returns just the last item (no bling)
				if n is 1
					@[@len() - 1]
				else
					@skip(@len() - n)

			slice: (start=0, end=@len()) ->
				# .slice(/i/, [/j/]) - get a subset of _this_ including [/i/../j/-1]
				# the j-th item will not be included - slice(0,2) will contain items 0, and 1.
				# negative indices work like in python: -1 is the last item, -2 is second-to-last
				# undefined start or end become 0, or @length, respectively
				j = 0
				n = @len()
				start += n if start < 0
				end += n if end < 0
				b = $()
				for i in [start...end]
					b[j++] = @[i]
				b

			extend: (b) ->
				# .extend(/b/) - insert all items from /b/ into _this_
				# note: unlike union, allows duplicates
				# note: also, does not create a new array, uses _this_ in-place
				i = @len() - 1
				j = -1
				n = b.len?() ? b.length
				while j < n-1
					@[++i] = b[++j]
				@

			push: (b) -> Array::push.call(@, b); @

			filter: (f) ->
				# .filter(/f/) - collect all /x/ from _this_ where /x/./f/(/x/) is true
				# or if f is a selector string, collects nodes that match the selector
				# or if f is a RegExp, collect nodes where f.test(x) is true
				b = $()
				g = switch Object.Type f
					when "string" then (x) -> x.matchesSelector(f)
					when "regexp" then (x) -> f.test(x)
					when "function" then f
					else
						throw new Error("unsupported type passed to filter: #{Object.Type(f)}")
				j = 0
				for it in @
					if g.call it, it
						b[j++] = it
				b

			test: (regex) -> @map () -> regex.test(@)

			matches: (expr) -> @zip('matchesSelector').call(expr)

			querySelectorAll: (s) ->
				@filter("*") # limit to only nodes
				.reduce (a, i) ->
					Array.Extend a, i.querySelectorAll(s)
				, $()

			weave: (b) ->
				# .weave(/b/) - interleave the items of _this_ and the set _b_
				# to produce: $([ b[i], this[i], ... ])
				# note: the items of b come first
				# note: if b and this are different lengths, the shorter
				# will yield undefineds into the result
				# the result always has 2 * max(length) items
				nn = @len()
				n = b.length
				i = nn - 1
				c = $()
				# first spread out this, from back to front
				for i in [nn-1..0]
					c[(i*2)+1] = @[i]
				# then interleave the source items, from front to back
				for i in [0...n]
					c[i*2] = b[i]
				c

			fold: (f) ->
				# .fold(/f/) - collect /c/ = /f/(a,b), complement of .weave()
				# /f/ accepts two items from the set, and returns one.
				# .fold() will always a set with half as many items
				# tip: use as a companion to weave.  weave two blings together,
				# then fold them to a bling the original size
				n = @len()
				j = 0
				# at least 2 items are required in the set
				b = $()
				for i in [0...n-1] by 2
					b[j++] = f.call @, @[i], @[i+1]
				# if there is an odd man out, make one last call
				if (n%2) is 1
					b[j++] = f.call @, @[n-1], undefined
				b

			flatten: () -> # .flatten() - collect the union of all sets in _this_
				b = $()
				n = @len()
				k = 0 # insert marker
				for i in [0...n]
					c = @[i]
					d = c.len?() ? c.length
					for j in [0...d]
						b[k++] = c[j]
				b

			call: () -> @apply(null, arguments)
			apply: (context, args) -> # .apply(/context/, [/args/]) - collect /f/.apply(/context/,/args/) for /f/ in _this_
				@map () ->
					if Object.IsFunction @
						@apply(context, args)
					else
						@

			delay: (n, f) -> # .delay(/n/, /f/) -  continue with /f/ on _this_ after /n/ milliseconds
				if Object.Type(f) is "function"
					g = Function.Bound(f, @)
					timeoutQueue.schedule(g, n)
					@.cancel = () -> timeoutQueue.cancel(g)
				@

			log: (label) -> # .log([label]) - console.log([/label/] + /x/) for /x/ in _this_
				n = @len()
				if label
					log(label, @, n + " items")
				else
					log(@, n + " items")
				@

			len: () -> # .len() - returns the max defined index + 1
				i = @length
				# scan forward to the end
				while @[i] isnt undefined
					i++
				# scan back to the real end
				while i > -1 and @[i] is undefined
					i--
				return i+1

			toArray: () -> (@.__proto__ = Array.prototype); @
		}

	$.plugin () -> # Math plugin
		name: 'Maths'
		$:
			range: (start, end, step = 1) -> # $.range generates an array of numbers
				step *= -1 if end < start and step > 0 # force step to have the same direction as start->end
				steps = Math.ceil( (end - start) / step )
				(start + (i*step) for i in [0...steps])
			zeros: (n) -> 0 for i in [0...n]
			ones: (n) -> 1 for i in [0...n]
		floats: () -> @map parseFloat
		ints: () -> @map () -> parseInt @, 10
		px: (delta=0) -> @ints().map Function.Px(delta)
		min: () -> @reduce (a) -> Math.min @, a
		max: () -> @reduce (a) -> Math.max @, a
		average: () -> @sum() / @len()
		sum: () -> @reduce (a) -> a + @
		squares: ()  -> @map () -> @ * @
		magnitude: () -> Math.sqrt @floats().squares().sum()
		scale: (r) -> @map () -> r * @
		normalize: () -> @scale(1/@magnitude())

	$.plugin () -> # Pub/Sub plugin
		subscribers = {} # a mapping of channel name to a list of subscribers
		archive = {} # archive published events here, so they can be replayed if necessary
		archive_limit = 1000 # maximum number of events (per type) to archive
		archive_trim = 100 # how much to trim all at once if we go over the maximum

		publish = (e, args = []) ->
			archive[e] ?= []
			archive[e].push(args)
			if archive[e].length > archive_limit
				archive[e].splice(0, archive_trim)
			subscribers[e] ?= []
			for func in subscribers[e]
				func.apply null, args
			@

		subscribe = (e, func, replay = true) ->
			subscribers[e] ?= []
			subscribers[e].push(func)
			if replay # replay the publish archive
				archive[e] ?= []
				for args in archive[e]
					func.apply null, args
			func

		unsubscribe = (e, func) ->
			if not func?
				subscribers[e] = []
			else
				subscribers[e] ?= []
				i = subscribers[e].indexOf(func)
				if i > -1
					subscribers[e].splice(i,i)

		# expose 'limit' and 'trim' for advanced users
		Object.defineProperty publish, 'limit',
			set: (n) ->
				archive_limit = n
				# enforce the new limit immediately
				for e of archive
					if archive[e].length > archive_limit
						archive[e].splice(0, archive_trim)
			get: () -> archive_limit

		Object.defineProperty publish, 'trim',
			set: (n) -> archive_trim = Math.min(n, archive_limit)
			get: () -> archive_trim

		return {
			name: "PubSub"
			$:
				publish: publish
				subscribe: subscribe
				unsubscribe: unsubscribe
		}

	if Object.global.document?
		Object.Type.register "nodelist",
			match: (o) -> o? and Object.IsType "NodeList", o
			hash: (o) -> $(Object.Hash(i) for i in x).sum()
			toArray: Function.Identity
			toString: (o) -> "{nodelist:"+$(o).zip('nodeName').join(",")+"}"
			toNode: -> $(@).toFragment()
		Object.Type.register "node",
			match: (o) -> o?.nodeType > 0
			hash: (o) -> String.Checksum(o.nodeName) + Object.Hash(o.attributes) + String.Checksum(o.innerHTML)
			toString: (o) -> o.toString()
			toNode: Function.Identity
		Object.Type.register "fragment",
			match: (o) -> o?.nodeType is 11
			hash: (o) -> $(Object.Hash(x) for x in o.childNodes).sum()
			toString: (o) -> o.toString()
			toNode: Function.Identity
		Object.Type.extend
			bling:
				toNode: -> @toFragment()
			string:
				toNode: -> $(@).toFragment()
			function:
				toNode: -> $(@toString()).toFragment()

		$.plugin () -> # Html plugin
			before = (a,b) -> # insert b before a
				if not a.parentNode?  # create a fragment if parent node is null
					df = document.createDocumentFragment()
					df.appendChild(a)
				a.parentNode.insertBefore b, a

			after = (a,b) -> # insert b after a
				if not a.parentNode?
					df = document.createDocumentFragment()
					df.appendChild(a)
				a.parentNode.insertBefore b, a.nextSibling

			toNode = (x) -> Object.Type.lookup(x).toNode.call x,x

			escaper = null

			getCSSProperty = (k) ->
				# window.getComputedStyle is not a normal function
				# (it doesnt support .call() so we can't use it with .map())
				# so define something that does work properly for use in .css
				() -> window.getComputedStyle(@, null).getPropertyValue(k)

			return {
				name: 'Html'

				$:
					HTML: # $.HTML.* - HTML methods similar to the global JSON object
						parse: (h) -> # $.HTML.parse(/h/) - parse the html in string h, a Node.
							node = document.createElement("div")
							node.innerHTML = h
							childNodes = node.childNodes
							n = childNodes.length
							if n is 1
								return node.removeChild(childNodes[0])
							df = document.createDocumentFragment()
							for i in [0...n]
								df.appendChild(node.removeChild(childNodes[0]))
							return df
						stringify: (n) -> # $.HTML.stringify(/n/) - the _Node_ /n/ in it's html-string form
							switch Object.Type n
								when "string" then n
								when "node"
									n = n.cloneNode(true)
									d = document.createElement("div")
									d.appendChild(n)
									ret = d.innerHTML # serialize to a string
									d.removeChild(n) # clean up to prevent leaks
									ret
								else "unknown type: " + Object.Type(n)
						escape: (h) -> # $.HTML.escape(/h/) - accept html string /h/, a string with html-escapes like &amp;
							escaper or= $("<div>&nbsp;</div>").child(0)
							# insert html using the text node's .data property
							# then get escaped html from the parent's .innerHTML
							ret = escaper.zap('data', h).zip("parentNode.innerHTML").first()
							# clean up so escaped content isn't leaked into the DOM
							escaper.zap('data', '')
							ret
					camelName: String.Camelize
					dashName: String.Dashize

				html: (h) -> # .html([h]) - get [or set] /x/.innerHTML for each node
					return switch Object.Type h
						when "undefined" then @zip 'innerHTML'
						when "string" then @zap 'innerHTML', h
						when "bling" then @html h.toFragment()
						when "node"
							@each () -> # replace all our children with the new child
								@replaceChild @childNodes[0], h
								while @childNodes.length > 1
									@removeChild @childNodes[1]

				append: (x) -> # .append(/n/) - insert /n/ [or a clone] as the last child of each node
					x = toNode(x) # parse, cast, do whatever it takes to get a Node or Fragment
					a = @zip('appendChild')
					a.take(1).call(x)
					a.skip(1).each (f) ->
						f(x.cloneNode(true)) # f is already bound to @
					@

				appendTo: (x) -> # .appendTo(/n/) - each node [or a fragment] will become the last child of n
					$(x).append(@)
					@

				prepend: (x) -> # .prepend(/n/) - insert n [or a clone] as the first child of each node
					if x?
						x = toNode(x)
						@take(1).each () ->
							before @childNodes[0], x
						@skip(1).each () ->
							before @childNodes[0], x.cloneNode(true)
					@

				prependTo: (x) -> # .prependTo(/n/) - each node [or a fragment] will become the first child of n
					if x?
						$(x).prepend(@)
					@

				before: (x) -> # .before(/x/) - insert content x before each node
					if x?
						x = toNode(x)
						@take(1).each () -> before @, x
						@skip(1).each () -> before @, x.cloneNode(true)
					@

				after: (x) -> # .after(/n/) - insert content n after each node
					if x?
						x = toNode(x)
						@take(1).each () -> after @, x
						@skip(1).each () -> after @, x.cloneNode(true)
					@

				wrap: (parent) -> # .wrap(/p/) - p becomes the new .parentNode of each node
					# all items of @ will become children of parent
					# parent will take each child's position in the DOM
					parent = toNode(parent)
					if Object.IsFragment(parent)
						throw new Error("cannot wrap with a fragment")
					@each (child) ->
						switch Object.Type(child)
							when "fragment"
								parent.appendChild(child)
							when "node"
								p = child.parentNode
								if not p
									parent.appendChild(child)
								else # swap out the DOM nodes using a placeholder element
									marker = document.createElement("dummy")
									# put a marker in the DOM, put removed node in new parent
									parent.appendChild( p.replaceChild(marker, child) )
									# replace marker with new parent
									p.replaceChild(parent, marker)

				unwrap: () -> # .unwrap() - replace each node's parent with itself
					@each () ->
						if @parentNode and @parentNode.parentNode
							@parentNode.parentNode.replaceChild(@, @parentNode)
						else if @parentNode
							@parentNode.removeChild(@)

				replace: (n) -> # .replace(/n/) - replace each node with n [or a clone]
					n = toNode(n)
					b = $()
					j = 0
					# first node gets the real n
					@take(1).each () ->
						@parentNode?.replaceChild(n, @)
						b[j++] = n
					# the rest get clones of n
					@skip(1).each () ->
						c = n.cloneNode(true)
						@parentNode?.replaceChild(c, @)
						b[j++] = c
					# the set of inserted nodes
					b

				attr: (a,v) -> # .attr(a, [v]) - get [or set] an /a/ttribute [/v/alue]
					switch v
						when undefined
							return @zip("getAttribute").call(a, v)
						when null
							return @zip("removeAttribute").call(a, v)
						else
							@zip("setAttribute").call(a, v)
							return @

				data: (k, v) ->
					k = "data-#{String.Dashize(k)}"
					@attr(k, v)

				addClass: (x) -> # .addClass(/x/) - add x to each node's .className
					@removeClass(x).each () ->
						c = @className.split(" ").filter (y) ->
							y isnt ""
						c.push(x) # since we dont know the len, its still faster to push, rather than insert at len()
						@className = c.join " "

				removeClass: (x) -> # .removeClass(/x/) - remove class x from each node's .className
					notx = (y)-> y != x
					@each () ->
						c = @className?.split(" ").filter(notx).join(" ")
						if c.length is 0
							@removeAttribute('class')

				toggleClass: (x) -> # .toggleClass(/x/) - add, or remove if present, class x from each node
					@each () ->
						cls = @className.split(" ")
						if( cls.indexOf(x) > -1 )
							c = cls.filter((y) -> y != x).join(" ")
						else
							cls.push(x)
						c = cls.filter(Function.Not Object.IsEmpty).join(" ")
						if c.length > 0
							@className = c
						else
							@removeAttribute('class')

				hasClass: (x) -> # .hasClass(/x/) - true/false for each node: whether .className contains x
					@zip('className.split').call(" ").zip('indexOf').call(x).map (x) -> x > -1

				text: (t) -> # .text([t]) - get [or set] each node's .textContent
					return @zap('textContent', t) if t?
					return @zip('textContent')

				val: (v) -> # .val([v]) - get [or set] each node's .value
					return @zap('value', v) if v?
					return @zip('value')

				css: (k,v) ->
					# .css(k, [v]) - get/set css properties for each node
					# called with string k and undefd v -> value of k
					# called with string k and string v -> set property k = v
					# called with object k and undefd v -> set css(x, k[x]) for x in k
					if v? or Object.IsObject k
						setter = @zip 'style.setProperty'
						nn = setter.len()
						if Object.IsObject k
							for i of k
								setter.call i, k[i], ""
						else if Object.IsString v
							setter.call k, v, ""
						else if Object.IsArray v
							n = Math.max v.length, nn
							for i in [0...n]
								setter[i%nn] k, v[i%n], ""
						return @
					else
						# collect the computed values
						cv = @map getCSSProperty(k)
						# collect the values specified directly on the node
						ov = @zip('style').zip k
						# weave and fold them so that object values override computed values
						ov.weave(cv).fold (x,y) -> x or y

				defaultCss: (k, v) ->
					# .defaultCss(k, [v]) - adds an inline style tag to the head for the current selector.
					# If k is an object of k:v pairs, then no second argument is needed.
					# Unlike css() which applies css directly to the style attribute,
					# defaultCss() adds actual css text to the page, based on @selector,
					# so it can still be over-ridden by external css files (such as themes)
					# also, @selector need not match any nodes at the time of the call
					sel = @selector
					style = ""
					if Object.IsString(k)
						if Object.IsString(v)
							style += "#{sel} { #{k}: #{v} } "
						else throw Error("defaultCss requires a value with a string key")
					else if Object.IsObject(k)
						style += "#{sel} { "
						style += "#{i}: #{k[i]}; " for i of k
						style += "} "
					$("<style></style>").text(style).appendTo("head")
					@

				empty: () -> # .empty() - remove all children
					@html ""

				rect: () -> # .rect() - collect a ClientRect for each node in @
					@zip('getBoundingClientRect').call()

				width: (w) -> # .width([/w/]) - get [or set] each node's width value
					if w == null
						return @rect().zip("width")
					return @css("width", w)

				height: (h) -> # .height([/h/]) - get [or set] each node's height value
					if h == null
						return @rect().zip("height")
					return @css("height", h)

				top: (y) -> # .top([/y/]) - get [or set] each node's top value
					if y == null
						return @rect().zip("top")
					return @css("top", y)

				left: (x) -> # .left([/x/]) - get [or set] each node's left value
					if x == null
						return @rect().zip("left")
					return @css("left", x)

				bottom: (x) -> # .bottom([/x/]) - get [or set] each node's bottom value
					if x == null
						return @rect().zip("bottom")
					return @css("bottom", x)

				right: (x) -> # .right([/x/]) - get [or set] each node's right value
					if x == null
						return @rect().zip("right")
					return @css("right", x)

				position: (x, y) -> # .position([/x/, [/y/]]) - get [or set] each node's top and left values
					if x == null
						return @rect()
					# with just x, just set style.left
					if y == null
						return @css("left", Number.Px(x))
					# with x and y, set style.top and style.left
					return @css({top: Number.Px(y), left: Number.Px(x)})

				center: (mode ="viewport") -> # .center([mode]) - move the elements to the center of the screen
					# mode is one of: "viewport" (default), "horizontal" or "vertical"
					# TODO: "viewport" should probably use window.innerHeight
					# TODO: this is all wrong...
					body = document.body
					vh = body.scrollTop  + (body.clientHeight/2)
					vw = body.scrollLeft + (body.clientWidth/2)
					@each () ->
						t = $(@)
						h = t.height().floats().first()
						w = t.width().floats().first()
						if mode is "viewport" or mode is "horizontal"
							x = vw - (w/2)
						else
							x = NaN
						if mode is "viewport" or mode is "vertical"
							y = vh - (h/2)
						else
							y = NaN
						t.css {
							position: "absolute",
							left: Number.Px(x),
							top: Number.Px(y)
						}

				scrollToCenter: () -> # .scrollToCenter() - scroll first node to center of viewport
					document.body.scrollTop = @zip('offsetTop')[0] - (window.innerHeight / 2)
					@

				child: (n) -> # .child(/n/) - returns the /n/th childNode for each in _this_
					@zip('childNodes').map () ->
						i = n
						if i < 0
							i += @length
						@[i]

				children: () -> # .children() - collect all children of each node
					@map () ->
						$(@childNodes, @)

				parent: () -> # .parent() - collect .parentNode from each of _this_
					@zip('parentNode')

				parents: () -> # .parents() - collects the full ancestry up to the owner
					@map () ->
						b = $()
						j = 0
						p = @
						while p = p.parentNode
							b[j++] = p
						b

				prev: () -> # .prev() - collects the chain of .previousSibling nodes
					@map () ->
						b = $()
						j = 0
						p = @
						while p = p.previousSibling
							b[j++] = p
						b

				next: () -> # .next() - collect the chain of .nextSibling nodes
					@map () ->
						b = $()
						j = 0
						p = @
						while p = p.nextSibling
							b[j++] = p
						b

				remove: () -> # .remove() - removes each node in _this_ from the DOM
					@each ()->
						if @parentNode
							@parentNode.removeChild(@)

				find: (css) -> # .find(/css/) - collect nodes matching /css/
					@filter("*") # limit to only nodes
						.map( () -> $(css, @) )
						.flatten()

				clone: (deep=true) -> # .clone(deep=true) - copies a set of DOM nodes
					@map () ->
						if Object.IsNode @
							@cloneNode deep
						else
							null

				toFragment: () ->
					if @len() > 1
						df = document.createDocumentFragment()
						adder = Function.Bound(df.appendChild, df)
						@map(toNode).map adder
						return df
					return toNode(@[0])
			}

		$.plugin () -> # Transform plugin, for accelerated animations
			COMMASEP = ", "
			speeds = # constant speed names
				"slow": 700
				"medium": 500
				"normal": 300
				"fast": 100
				"instant": 0
				"now": 0
			# matches all the accelerated css property names
			accel_props_re = /(?:scale(?:3d)*|translate(?:[XYZ]|3d)*|rotate(?:[XYZ]|3d)*)/
			updateDelay = 30 # ms to wait for DOM changes to apply
			testStyle = document.createElement("div").style

			transformProperty = "transform"
			transitionProperty = "transition-property"
			transitionDuration = "transition-duration"
			transitionTiming = "transition-timing-function"

			# detect which browser's transform properties to use
			if "WebkitTransform" of testStyle
				transformProperty = "-webkit-transform"
				transitionProperty = "-webkit-transition-property"
				transitionDuration = "-webkit-transition-duration"
				transitionTiming = "-webkit-transition-timing-function"
			else if "MozTransform" of testStyle
				transformProperty = "-moz-transform"
				transitionProperty = "-moz-transition-property"
				transitionDuration = "-moz-transition-duration"
				transitionTiming = "-moz-transition-timing-function"
			else if "OTransform" of testStyle
				transformProperty = "-o-transform"
				transitionProperty = "-o-transition-property"
				transitionDuration = "-o-transition-duration"
				transitionTiming = "-o-transition-timing-function"

			return {
				name: 'Transform'
				$: {
					duration: (speed) -> # $.duration(/s/) - given a speed description (string|number), return a number in milliseconds
						d = speeds[speed]
						return d if d?
						return parseFloat speed
				}

				# like jquery's animate(), but using only webkit-transition/transform
				transform: (end_css, speed, easing, callback) ->
					# .transform(css, [/speed/], [/callback/]) - animate css properties on each node
					# animate css properties over a duration
					# accelerated: scale, translate, rotate, scale3d,
					# ... translateX, translateY, translateZ, translate3d,
					# ... rotateX, rotateY, rotateZ, rotate3d
					# easing values (strings): ease | linear | ease-in | ease-out
					# | ease-in-out | step-start | step-end | steps(number[, start | end ])
					# | cubic-bezier(number, number, number, number)

					if Object.IsFunction(speed)
						callback = speed
						speed = null
						easing = null
					else if Object.IsFunction(easing)
						callback = easing
						easing = null
					if not speed?
						speed = "normal"
					easing or= "ease"
					# duration is always in milliseconds
					duration = $.duration(speed) + "ms"
					props = []
					p = 0 # insert marker for props
					# what to send to the -webkit-transform
					trans = ""
					# real css values to be set (end_css without the transform values)
					css = {}
					for i of end_css
						# pull all the accelerated values out of end_css
						if accel_props_re.test(i)
							ii = end_css[i]
							if ii.join
								ii = $(ii).px().join(COMMASEP)
							else if ii.toString
								ii = ii.toString()
							trans += " " + i + "(" + ii + ")"
						else # stick real css values in the css dict
							css[i] = end_css[i]
					# make a list of the properties to be modified
					for i of css
						props[p++] = i
					# and include -webkit-transform if we have transform values to set
					if trans
						props[p++] = transformProperty

					# sets a list of properties to apply a duration to
					css[transitionProperty] = props.join(COMMASEP)
					# apply the same duration to each property
					css[transitionDuration] =
						props.map(() -> duration)
							.join(COMMASEP)
					# apply an easing function to each property
					css[transitionTiming] =
						props.map(() -> easing)
							.join(COMMASEP)

					# apply the transformation
					if( trans )
						css[transformProperty] = trans
					# apply the css to the actual node
					@css(css)
					# queue the callback to be executed at the end of the animation
					# WARNING: NOT EXACT!
					@delay(duration, callback)

				hide: (callback) -> # .hide() - each node gets display:none
					@each () ->
						if @style
							@_display = "" # stash the old display
							if @style.display is not "none"
								@_display = @syle.display
							@style.display = "none"
					.trigger("hide")
					.delay(updateDelay, callback)

				show: (callback) -> # .show() - show each node
					@each () ->
						if @style
							@style.display = @_display
							delete @_display
					.trigger("show")
					.delay(updateDelay, callback)

				toggle: (callback) -> # .toggle() - show each hidden node, hide each visible one
					@weave(@css("display"))
						.fold (display, node) ->
							if display is "none"
								node.style.display = node._display or ""
								delete node._display
								$(node).trigger("show")
							else
								node._display = display
								node.style.display = "none"
								$(node).trigger("hide")
							node
						.delay(updateDelay, callback)

				fadeIn: (speed, callback) -> # .fadeIn() - fade each node to opacity 1.0
					@.css('opacity','0.0')
						.show () ->
							@transform {
								opacity:"1.0",
								translate3d: [0,0,0]
							}, speed, callback
				fadeOut: (speed, callback, x = 0.0, y = 0.0) -> # .fadeOut() - fade each node to opacity:0.0
					@transform {
						opacity:"0.0",
						translate3d:[x,y,0.0]
					}, speed, () -> @hide(callback)
				fadeLeft: (speed, callback) -> @fadeOut(speed, callback, "-"+@width().first(), 0.0)
				fadeRight: (speed, callback) -> @fadeOut(speed, callback, @width().first(), 0.0)
				fadeUp: (speed, callback) -> @fadeOut(speed, callback, 0.0, "-"+@height().first())
				fadeDown: (speed, callback)  -> @fadeOut(speed, callback, 0.0, @height().first())
			}

		$.plugin () -> # HTTP Request plugin: provides wrappers for making http requests
			formencode = (obj) -> # create &foo=bar strings from object properties
				s = []
				j = 0 # insert marker into s
				o = JSON.parse(JSON.stringify(obj)) # quickly remove all non-stringable items
				for i of o
					s[j++] = "#{i}=#{escape o[i]}"
				s.join("&")

			{
				name: 'Http'
				$: { # globals
					http: (url, opts = {}) -> # $.http(/url/, [/opts/]) - fetch /url/ using HTTP (method in /opts/)
						xhr = new XMLHttpRequest()
						if Object.IsFunction(opts)
							opts = {success: Function.Bound(opts, xhr)}
						opts = Object.Extend {
							method: "GET"
							data: null
							state: Function.Identity # onreadystatechange
							success: Function.Identity # onload
							error: Function.Identity # onerror
							async: true
							timeout: 0 # milliseconds, 0 is forever
							withCredentials: false
							followRedirects: false
							asBlob: false
						}, opts
						opts.state = Function.Bound(opts.state, xhr)
						opts.success = Function.Bound(opts.success, xhr)
						opts.error = Function.Bound(opts.error, xhr)
						if opts.data and opts.method is "GET"
							url += "?" + formencode(opts.data)
						else if opts.data and opts.method is "POST"
							opts.data = formencode(opts.data)
						xhr.open(opts.method, url, opts.async)
						xhr.withCredentials = opts.withCredentials
						xhr.asBlob = opts.asBlob
						xhr.timeout = opts.timeout
						xhr.followRedirects = opts.followRedirects
						xhr.onreadystatechange = () ->
							if opts.state
								opts.state()
							if xhr.readyState is 4
								if xhr.status is 200
									opts.success xhr.responseText
								else
									opts.error xhr.status, xhr.statusText
						xhr.send opts.data
						return $([xhr])

					post: (url, opts = {}) -> # $.post(/url/, [/opts/]) - fetch /url/ with a POST request
						if Object.IsFunction(opts)
							opts = {success: opts}
						opts.method = "POST"
						$.http(url, opts)

					get: (url, opts = {}) -> # $.get(/url/, [/opts/]) - fetch /url/ with a GET request
						if( Object.IsFunction(opts) )
							opts = {success: opts}
						opts.method = "GET"
						$.http(url, opts)
				}
			}

		$.plugin () -> # Events plugin
			EVENTSEP_RE = /,* +/
			events = ['mousemove','mousedown','mouseup','mouseover','mouseout','blur','focus',
				'load','unload','reset','submit','keyup','keydown','change',
				'abort','cut','copy','paste','selection','drag','drop','orientationchange',
				'touchstart','touchmove','touchend','touchcancel',
				'gesturestart','gestureend','gesturecancel',
				'hashchange'
			] # 'click' is handled specially

			binder = (e) ->
				(f = {}) ->
					return @bind(e, f) if Object.IsFunction f
					return @trigger(e, f)

			register_live = (selector, context, e, f, h) ->
				$(context)
					.bind(e, h) # bind the proxy handler
					.each () ->
						a = (@__alive__ or= {})
						b = (a[selector] or= {})
						c = (b[e] or= {})
						# make a record using the fake handler as key
						c[f] = h

			unregister_live = (selector, context, e, f) ->
				$c = $(context)
				$c.each () ->
					a = (@__alive__ or= {})
					b = (a[selector] or= {})
					c = (b[e] or= {})
					$c.unbind(e, c[f])
					delete c[f]

			# detect and fire the document.ready event
			readyTriggered = 0
			readyBound = 0
			triggerReady = () ->
				if not readyTriggered++
					$(document).trigger("ready").unbind("ready")
					document.removeEventListener?("DOMContentLoaded", triggerReady, false)
					window.removeEventListener?("load", triggerReady, false)
			bindReady = () ->
				if not readyBound++
					document.addEventListener?("DOMContentLoaded", triggerReady, false)
					window.addEventListener?("load", triggerReady, false)
			bindReady()

			ret = {
				name: 'Events'
				bind: (e, f) -> # .bind(e, f) - adds handler f for event type e
					# e is a string like 'click', 'mouseover', etc.
					# e can be comma-separated to bind multiple events at once
					c = (e or "").split(EVENTSEP_RE)
					h = (evt) ->
						ret = f.apply @, arguments
						if ret is false
							Event.Prevent evt
						ret
					@each () ->
						for i in c
							@addEventListener i, h, false

				unbind: (e, f) -> # .unbind(e, [f]) - removes handler f from event e
					# if f is not present, removes all handlers from e
					c = (e or "").split(EVENTSEP_RE)
					@each () ->
						for i in c
							@removeEventListener(i, f, null)

				once: (e, f) -> # .once(e, f) - adds a handler f that will be called only once
					c = (e or "").split(EVENTSEP_RE)
					for i in c
						@bind i, (evt) ->
							f.call(@, evt)
							@removeEventListener(evt.type, arguments.callee, null)

				cycle: (e, funcs...) -> # .cycle(e, ...) - bind handlers for e that trigger in a cycle
					# one call per trigger. when the last handler is executed
					# the next trigger will call the first handler again
					c = (e or "").split(EVENTSEP_RE)
					nf = funcs.length
					cycler = () ->
						i = -1
						(evt) -> funcs[i = ++i % nf].call(@, evt)
					@bind j, cycler() for j in c
					@

				trigger: (evt, args = {}) -> # .trigger(e, a) - initiates a fake event
					# evt is the type, 'click'
					# args is an optional mapping of properties to set,
					#		{screenX: 10, screenY: 10}
					# note: not all browsers support manually creating all event types
					evts = (evt or "").split(EVENTSEP_RE)
					args = Object.Extend {
						bubbles: true
						cancelable: true
					}, args

					for evt_i in evts
						if evt_i in ["click", "mousemove", "mousedown", "mouseup", "mouseover", "mouseout"] # mouse events
							e = document.createEvent "MouseEvents"
							args = Object.Extend {
								detail: 1,
								screenX: 0,
								screenY: 0,
								clientX: 0,
								clientY: 0,
								ctrlKey: false,
								altKey: false,
								shiftKey: false,
								metaKey: false,
								button: 0,
								relatedTarget: null
							}, args
							e.initMouseEvent evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
								args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
								args.button, args.relatedTarget

						else if evt_i in ["blur", "focus", "reset", "submit", "abort", "change", "load", "unload"] # UI events
							e = document.createEvent "UIEvents"
							e.initUIEvent evt_i, args.bubbles, args.cancelable, window, 1

						else if evt_i in ["touchstart", "touchmove", "touchend", "touchcancel"] # touch events
							e = document.createEvent "TouchEvents"
							args = Object.Extend {
								detail: 1,
								screenX: 0,
								screenY: 0,
								clientX: 0,
								clientY: 0,
								ctrlKey: false,
								altKey: false,
								shiftKey: false,
								metaKey: false,
								# touch values:
								touches: [],
								targetTouches: [],
								changedTouches: [],
								scale: 1.0,
								rotation: 0.0
							}, args
							e.initTouchEvent(evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
								args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
								args.touches, args.targetTouches, args.changedTouches, args.scale, args.rotation)

						else if evt_i in ["gesturestart", "gestureend", "gesturecancel"] # gesture events
							e = document.createEvent "GestureEvents"
							args = Object.Extend {
								detail: 1,
								screenX: 0,
								screenY: 0,
								clientX: 0,
								clientY: 0,
								ctrlKey: false,
								altKey: false,
								shiftKey: false,
								metaKey: false,
								# gesture values:
								target: null,
								scale: 1.0,
								rotation: 0.0
							}, args
							e.initGestureEvent evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
								args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
								args.target, args.scale, args.rotation

						# iphone events that are not supported yet (dont know how to create yet, needs research)
						# iphone events that we cant properly emulate (because we cant create our own Clipboard objects)
						# iphone events that are just plain events
						# and general events
						# else if evt_i in ["drag", "drop", "selection", "cut", "copy", "paste", "orientationchange"]
						else
							e = document.createEvent "Events"
							e.initEvent evt_i, args.bubbles, args.cancelable
							try
								e = Object.Extend e, args
							catch err

						if not e
							continue
						else
							try
								@each () -> @dispatchEvent e
							catch err
								log("dispatchEvent error:",err)
					@

				live: (e, f) -> # .live(e, f) - handle events for nodes that will exist in the future
					selector = @selector
					context = @context
					# wrap f
					handler = (evt) ->
						# when event 'e' is fired
						# re-execute the selector in the original context
						$(selector, context)
							# then see if the event would bubble into a match
							.intersect($(evt.target).parents().first().union($(evt.target)))
							# then fire the real handler 'f' on the matched nodes
							.each () ->
								evt.target = @
								f.call(@, evt)
					# bind the handler to the context
					# record f so we can 'die' it if needed
					register_live selector, context, e, f, handler
					@

				die: (e, f) ->
					# die(e, [f]) - stop f [or all] from living for event e
					h = unregister_live @selector, @context, e, f
					$(@context).unbind e, h
					@

				liveCycle: (e, funcs...) -> # .liveCycle(e, ...) - bind each /f/ in /funcs/ to handle /e/
					i = -1
					nf = funcs.length
					@live e, (evt) ->
						funcs[i = ++i % nf].call @, evt

				click: (f = {}) -> # .click([f]) - trigger [or bind] the 'click' event
					if @css("cursor").intersect(["auto",""]).len() > 0
						@css "cursor", "pointer" # if the cursor is just default then make it look clickable
					if Object.IsFunction f
						@bind 'click', f
					else
						@trigger 'click', f

				ready: (f = {}) ->
					if Object.IsFunction f
						if readyTriggered
							f.call @
						else
							@bind "ready", f
					else
						@trigger "ready", f
			}

			# add event binding/triggering shortcuts for the generic events
			events.forEach (x) ->
				ret[x] = binder(x)
			return ret

		$.plugin () -> # LazyLoader plugin, depends on PubSub
			create = (elementName, props) ->
				Object.Extend document.createElement(elementName), props

			lazy_load = (elementName, props) ->
				depends = provides = null
				n = create elementName, Object.Extend(props, {
					onload: () ->
						if provides?
							$.publish(provides)
				})
				$("head").delay 10, () ->
					if depends?
						$.subscribe depends, () => @append(n)
					else
						@append(n)
				n = $(n)
				Object.Extend n, {
					depends: (tag) -> depends = elementName+"-"+tag; n
					provides: (tag) -> provides = elementName+"-"+tag; n
				}

			return {
				name: "LazyLoader"
				$:
					script: (src) ->
						lazy_load "script", { src: src }
					style: (src) ->
						lazy_load "link", { href: src, "rel!": "stylesheet" }
			}

)(Bling)
# vim: ft=coffee sw=2 ts=2
