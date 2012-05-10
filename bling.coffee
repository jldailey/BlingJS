# Why not add some "bling" to that plain old list of things?

# Once a list has been tricked out, it is blessed with many new features,
# many of which will be familiar from jQuery; like `each`, and `html`.
# Other features are wholly new and powerful (e.g. `select`, and `zap`).

# Named after the bling symbol `$` to which it is bound by default.

# Philoshopy
# ----------
# 1. Always work on _sets_ of stuff, scalars are annoying.
#    If you always write code to handle sets, you usually handle the scalar case for free.
# 2. Don't alter global _prototypes_; global _types_ are OK.
# 3. Have fun and learn; about the DOM, about jQuery, about JavaScript and CoffeeScript.
# 4. Never be afraid to delete code you don't like.

# Author
# ------
# Jesse Dailey <jesse.dailey@gmail.com>, Copyright: 2011, License: MIT.

# Warming Up
# ---------

# We need a few things to get started:

# A safe reference to `console.log()`:
log = (a...) ->
	try return console.log?.apply console, a
	alert a.join(", ")

# A safe reference to the `global` object:
Object.defineProperty Object, 'global', get: -> window ? global

# A safe replacement for `Object.keys`:
keys = (o, inherited = false) -> (k for k of o when (inherited or o.hasOwnProperty(k)))

# A way to assign values from `b` to `a`, with optional whitelist:
extend = (a, b, k) ->
	return a if not b?
	if not Array.isArray?(k)
		k = keys(b)
	for key in k
		v = b[key]
		if not v? then continue
		a[key] = v
	a

# A way to proper case a string:
capital = (name) -> (name.split(" ").map (x) -> x[0].toUpperCase() + x.substring(1).toLowerCase()).join(" ")

# Basic Globals
# -------------

# This section starts with the basic things we want to do with objects.
# All of these extensions are attached to the global `Object` value, not the
# _prototype_. So you use them like: `Object.Keys(foo)`.
extend Object,
	# Keys and Extend are made public here for plugins.
	Keys: keys,
	Extend: extend,

	# Type System
	# -----------

	# JavaScript's type system is beautiful, but arcane and problematic.

	# The idea of the prototype chain is very powerful and can be used
	# to model a class-based system (like Java's, as CoffeeScript does),
	# but can also easily emulate other systems; like Traits from Scala,
	# and Mixins from Ruby.

	# Prototypes allow for an object to transform itself in new ways that
	# you can't do in other languages, like the ability to splice a new object
	# anywhere in a prototype chain for a single object instance.

	# But, the power of prototypes is hidden behind lots of bad implementation
	# choices; one of the first everyone finds is how difficult it is to ask:
	# > What kind of type is this?

	# `typeof` is famously unhelpful here; e.g. `typeof [] == typeof {}`.

	# Many attempts have been made to improve the type system, but they
	# do not address the `typeof` problem; even CoffeeScript's own
	# `class` and `extends` syntax.  Also, along the way, they forget
	# they are in a prototype-based system, and they throw away it's
	# flexibility.

	# To fix this, we will create a _type classifier_ for the core of
	# our type system.

	# Later, we will extend the classifier so that we can define operations on
	# the type-instances, rather than attaching them to any
	# instances or prototypes directly.

	# Before we build a full classifier, we need a few things.
	
	# `Object.IsType(T, obj)` is a simple boolean test to see if any
	# object `o` is of type `T`; respecting prototype chains,
	# constructors, and anything else we can think of that matters.
	IsType: (T, o) ->
		return T in [o,"null","undefined"] if not o?
		o.constructor is T or
			o.constructor.name is T or
			Object::toString.apply(o) is "[object #{T}]" or
			Object.IsType T, o.__proto__

	# Object.Inherit(parent, child) is similar to Extend, except it works by
	# inserting the parent as the proto of the child instance. This is unlike
	# coffee's `class X extends Y`, because it expects the target `obj`
	# to be an _instance_, and the parent can either be an instance or a
	# constructor.
	Inherit: (parent, obj) ->
		if typeof parent is "function"
			obj.constructor = parent
			parent = parent::
		obj.__proto__ = parent
		obj

	# Now, let's begin to build the classifier: `Object.Type(obj)`.
	Type: (->

		# Internally, Object.Type maintains a registry of known types.
		cache = {}

		# Each type in the registry is an instance that inherits from a
		# base object.  Later, when we want to do more than `match` with
		# each type, we will extend this base type to provide default
		# implementations.
		base =
			name: 'unknown'
			match: (o) -> true

		# When checking for matches, this array of names will control
		# the precedence of the checks.
		order = []

		# When adding a new type to the regisry:
		register = (name, data) ->
			# * Create a global `Object.Is___` boolean check for the type.
			Object["Is"+capital(name)] = (o) -> data.match.call o,o
			# * Put the type check in order (if it isn't already).
			order.unshift name if not (name of cache)
			# * Inherit from the base type and store in the cache.
			cache[data.name = name] = Object.Inherit base, data

		# Later, you can extend previously registered types with new
		# functionality.
		extend = (name, data) ->
			# If explicitly passed a null for the name, extend base type
			if data? and not name?
				Object.Extend base, data
			# The `name` should be of a registered type (a key into the cache)
			else if typeof name is "string"
				# But, if you attempt to extend a type that was not registered yet,
				# it will be automatically registered (shh, don't tell anyone).
				cache[name] = Object.Extend cache[name] ? register(name,{}), data
			# But you can also extend a bunch of types at once, by passing a
			# 2-level deep object, where the first level of keys are type
			# names and the second level of keys are objects full of
			# extensions.
			else Object.Type.extend k, name[k] for k of name

		# To classify an object, simply check every match in order.
		# Returns all matching type-instances, so you can access any extensions.
		lookup = (obj) -> cache[name] for name in order when cache[name]?.match.call obj, obj

		# Now, register all the built-in types. These checks are
		# executed in _reverse order_, so the first listed here, `"unknown"`,
		# is always checked last.
		register "unknown",   match: -> true
		# This implies that the 'simplest' checks should be registered
		# first, and conceptually more specialized checks would get added
		# as time goes on (so specialized type matches are preferred).
		register "object",    match: -> typeof @ is "object"
		register "error",     match: -> Object.IsType 'Error', @
		register "regexp",    match: -> Object.IsType 'RegExp', @
		register "string",    match: -> typeof @ is "string" or Object.IsType String, @
		register "number",    match: -> Object.IsType Number, @
		register "bool",      match: -> typeof @ is "boolean" or String(@) in ["true","false"]
		register "array",     match: -> Array.isArray?(@) or Object.IsType Array, @
		register "function",  match: -> typeof @ is "function"
		register "global",    match: -> typeof @ is "object" and 'setInterval' of @
		# These checks for null and undefined are small exceptions to the
		# simple-first idea, since they are precise and getting them out
		# of the way early lets later checks omit a safety check.
		register "undefined", match: (x) -> x is undefined
		register "null",      match: (x) -> x is null

		# Now, we finally have all the pieces to make the real classifier.
		Object.Extend ((o) -> lookup(o)[0].name),
			register: register
			lookup: lookup
			extend: extend
		# Example: Calling Object.Type directly will get you the simple name of the
		# best match.
		# > `Object.Type([]) == "array"`

		# If you want to know everything, you can use lookup
		# directly.
		# > `Object.Type.lookup([]).select("name") == ["array"]`

		# You can also tell when things are made of more than one type.
		# > `Object.Type.lookup("<a>").select("name") == ["html","string"]`

		# Later, once other systems have extended the base type, the
		# type-instance returned from Object.Type.lookup will do more.

		# If an object is of multiple types, for instance "html" is a
		# "string" with special formatting.  To disambiguate these:

		# > `Object.Type.lookup(a="<a>")
		# > .filter(-> @name is "string")
		# > .select("hash")
		# > .call(a)`

	)()

# Using the Type System
# =====================
extend Object,
	# Two helpers, self-explanatory.
	IsSimple: (o) -> Object.Type(o) in ["string", "number", "bool"]
	IsEmpty: (o) -> o in ["", null, undefined]

	# Object.String
	# -------------
	# Object.String extends the base type to allow for converting things
	# to string based on their type. This is a separate system from the
	# native Object.prototype.toString chain of methods.

	# This is the first proof-of-concept of modular extensions to the
	# type system, and also gives us a way to control the string
	# output in ways that won't impact other code that relies on the
	# behavior of toString.
	String: (->
		# First, extend the base type with a default `string` function
		Object.Type.extend null, string: (o) -> o.toString?() ? String(o)
		# Now, for each basic type, provide a basic `string` function.
		Object.Type.extend
			null:      { string: -> "null" }
			undefined: { string: -> "undefined" }
			string:    { string: Function.Identity }
			array:     { string: (a) -> "[" + (Object.String(x) for x in a).join(",") + "]" }
			object:    { string: (o) -> "{" + ("#{k}:#{Object.String(v)}" for k,v in o).join(", ") + "}" }
			number:    { string: (n) ->
				switch true
					when n.precision? then n.toPrecision(n.precision)
					when n.fixed? then n.toFixed(n.fixed)
					else String(n)
			}
		# Later, more complex types will be added by plugins.

		# With `string` known to the type system, the actual implementation of
		# `Object.String` is trivial:
		(x) -> Object.Type.lookup(x)[0].string(x)
	)()

	# Object.Hash
	# -----------
	# Reduces any thing to an integer hash code (not secure).
	Hash: (->
		Object.Type.extend null, hash: (o) -> String.Checksum Object.String(o)
		Object.Type.extend
			object: { hash: (o) -> (Object.Hash(o[k]) for k of o) + Object.Hash(Object.Keys(o)) }
			array:  { hash: (o) -> (Object.Hash(i) for i in x).reduce (a,x) -> a+x }
			bool:   { hash: (o) -> parseInt(1 if o) }
		(x) -> Object.Type.lookup(x)[0].hash(x)
	)()

	# Object.Trace
	# ------------
	# A very useful debugging tool, `Object.Trace` will deep-walk all
	# properties and wrap all functions with new functions that call the
	# originals but log the calls (and use the property names from the
	# deep walk as labels).
	Trace: (->
		Object.Type.extend null, trace: Function.Identity
		Object.Type.extend
			object: { trace: (o, label, tracer) -> (o[k] = Object.Trace(o[k], "#{label}.#{k}", tracer) for k in Object.Keys(o)); o }
			array:  { trace: (o, label, tracer) -> (o[i] = Object.Trace(o[i], "#{label}[#{i}]", tracer) for i in [0...o.length]); o }
			function:
				trace: (f, label, tracer) ->
					r = (a...) ->
						tracer "#{@name or Object.Type(@)}.#{label or f.name}(", a, ")"
						f.apply @, a
					tracer "Trace: #{label or f.name} created."
					r.toString = f.toString
					r
		(o, label, tracer) -> Object.Type.lookup(o)[0].trace(o, label, tracer)
	)()
	# Trace could probably be improved to support filters on which keys
	# to trace...

# Function Globals
# ----------------
# These are little function factories, for mixing and composing other functions.
extend Function,
	# __Function.Identity(x)__ returns x.
	Identity: (o) -> o
	# __Function.Not(f)__ returns a new function that returns `not
	# f(...)`.
	Not: (f) -> (a...) -> not f.apply @, a
	# __Function.Compose(f,g)__ composes _f_ and _g_ to `f(g(...))`.
	Compose: (f,g) -> (x) -> f.call(y, (y = g.call(x,x)))
	# __Function.And(f,g)__ returns a new function that returns f(x) && g(x).
	And: (f,g) -> (x) -> g.call(x,x) and f.call(x,x)
	# __Function.Once(f)__ returns a new function that will only call
	# _f_ **once**, or _n_ times if you pass the optional argument.
	Once: (f,n=1) -> f.n = n; (a...) -> (f.apply @,a) if f.n-- > 0
	# __Function.Bound(context,f,[args])__ returns a new function that forces this === context when called.
	Bound: (t, f, args = []) ->
		if Object.IsFunction f.bind
			args.splice 0, 0, t
			r = f.bind.apply f, args
		else
			r = (a...) -> f.apply t, (args if args.length else a)
		extend r, { toString: -> "bound-method of #{t}.#{f.name}" }
	# __Function.Memoize(f)__ returns a new function that caches function calls to f, based on hashing the arguments.
	Memoize: (f) -> cache = {}; (a...) -> cache[Object.Hash(a)] ?= f.apply @, a # BUG: does not cache if f returns null on purpose


# String Globals
# --------------
# Lots of basic things to do with strings.
extend String,

	# Make a "px" string:
	# Accept anything parseInt-able (including an existing "px"
	# string), adjusts by optional delta.
	Px: (x, delta=0) -> x? and (parseInt(x,10)+(delta|0))+"px"
	# Example: Add 100px of width to an element.

	# jQuery style:
	# > `node.css("width",String.Px(node.css("width"), + 100))`

	# Bling style:
	# > `node.zap 'style.width', -> String.Px(@, + 100)

	# Properly **Capitalize** Each Word In A String.
	Capitalize: capital

	# Convert a camelCase name to a dash-name.
	Dashize: (name) ->
		ret = ""
		for i in [0...(name?.length|0)]
			c = name.charCodeAt i
			# For each uppercase character,
			if 91 > c > 64
				# Shift it to lower case and insert a '-'.
				c += 32
				ret += '-'
			ret += String.fromCharCode(c)
		return ret

	# Convert a dash-name to a camelName.
	Camelize: (name) ->
		name.split('-')
		while (i = name?.indexOf('-')) > -1
			name = String.Splice(name, i, i+2, name[i+1].toUpperCase())
		name

	# Fill the left side of a string to make it a fixed width.
	PadLeft: (s, n, c = " ") -> # String.PadLeft(string, width, fill=" ")
		while s.length < n
			s = c + s
		s

	# Fill the right side of a string to make it a fixed width.
	PadRight: (s, n, c = " ") -> # String.PadRight(string, width, fill=" ")
		while s.length < n
			s = s + c
		s

	# Count the number of occurences of `x` in `s`.
	Count: (s, x, i = 0, n = 0) -> String.Count(s,x,j+1,n+1) if (j=s.indexOf(x,i)) > i-1 else n

	# Splice the substring `n` into the string `s', replacing indices
	# between `i` and `j`.
	Splice: (s, i, j, n) ->
		nn = s.length
		end = j
		if end < 0
			end += nn
		start = i
		if start < 0
			start += nn
		s.substring(0,start) + n + s.substring(end)
	
	# Compute the Adler32 checksum of a string.
	Checksum: (s) ->
		a = 1; b = 0
		for i in [0...s.length]
			a = (a + s.charCodeAt(i)) % 65521
			b = (b + a) % 65521
		return (b << 16) | a
	
	# Return a string-builder, which uses arrays to defer all string
	# concatenation until you call `builder.toString()`.
	Builder: ->
		if Object.IsWindow(@) then return new String.Builder()
		items = []
		@length   = 0
		@append   = (s) => items.push s; @length += s?.toString().length|0
		@prepend  = (s) => items.splice 0,0,s; @length += s?.toString().length|0
		@clear    = ( ) => ret = @toString(); items = []; @length = 0; ret
		@toString = ( ) => items.join("")
		@

# The Bling Constructor
# =====================
# This is using coffee's class syntax, but only as a hack really.

# First, we want the Bling function to have a name so that
# `$().constructor.name == "Bling"`, for sanity, and for easily
# detecting a mixed-jQuery environment (we do try to play nice).

# Second, the `new` operator is not good.  What it does normally is
# make a shallow copy of the prototype to use as context and return
# value for the constructor.

# In that simple statement is basically the core of the JS type
# system, and even in that one sentence there are three problems:

# 1. _The copy is shallow_; creating ambiguously-shared state between
# instances.
# 2. _There is a copy at all_; one should avoid copying in critical
# sections whenever possible.
# 3. _It replaces the return value of the constructor_; reducing
# flexibility in implementations.

# So, the Bling constructor should not be called as `new Bling`,
# and this means our assignment to a symbol (`$`) remains simple.
class Bling extends Array
	constructor: (selector, context = document or {}) ->
		# Since we have this nice Type system, our constructor is succinct:
		# 1. Classify the type.
		# 2. Convert the selector to a set using the type-instance.
		# 3. Use Object.Inherit to _hijack_ the set's prototype in-place.
		return Object.Inherit Bling, Object.Extend Object.Type.lookup(selector).array(selector, context),
			selector: selector
			context: context

	# $.plugin( func )
	# -----------------
	# Each plugin is a function that returns an object full of stuff to
	# extend the Bling prototype with.

	# Example: the simplest possible plugin.
	# > $.plugin () -> echo: -> @

	# After this, `$(...).echo()` will work.  Also, this will also
	# create a default global version: `$.echo`.
	
	# You can explicitly define root-level values by nesting things
	# under a `$` key:
	# > $.plugin () -> $: hello: -> "Hello!"

	# This will create `$.hello`, but not `$().hello`.
	@plugin: (constructor) ->
		try
			# We call the plugin constructor and expect that it returns an
			# object full of things to be publicly exposed.
			if (plugin = constructor.call @,@)?
				# If the plugin has a `$` key, apply those to Bling directly
				extend @, plugin?.$
				# Clean off keys we don't care about: `$` and `name`. (An
				# older version of plugin() used to require names,
				# but we ignore them now in case we are loading an out-dated
				# plugin).
				['$','name'].forEach (k) -> delete plugin[k]
				# Now put everything else on the Bling prototype
				extend @::, plugin
				# Finally, add default global versions of anything that
				# doesn't have one already.
				( @[key] ?= (a...) => (@::[key].apply $(a[0]), a[1...]) ) for key of plugin # and gets a default global implementation
		catch error
			log "failed to load plugin: '#{error.message}'"
		@

	# Adding "bling" to the Type System
	# ---------------------------------
	# First, we give the basic types the ability to turn into something
	# array-like, for use in the constructor.

	# By default, if we don't know any better way, we just stick the
	# thing inside a real array.
	Object.Type.extend null, array: (o) -> [o]
	# But where we do know better, we can provide more meaningful
	# conversions. Later, in the DOM section, we will extend
	# this further to know how to convert "html", "node", etc.
	Object.Type.extend
		# Null and undefined values convert to an empty array
		null:      { array: (o) -> [] }
		undefined: { array: (o) -> [] }
		# Arrays just convert to themselves
		array:     { array: Function.Identity }
		# Numbers create a new array of that capacity:
		# > `$(10) == $(new Array(10))`
		number:    { array: (o) -> Object.Extend new Array(o), length: 0 }
	
	# Second, we register "bling", and all the things we know how to do
	# with it:
	Object.Type.register "bling",
		match:  (o) -> Object.IsType Bling, o
		array:  Function.Identity
		hash:   (o) -> o.map(Object.Hash).sum()
		string: (o) -> Bling.symbol + "([" + o.map(Object.String).join(", ")+ "])"


# Plugins
# ==============
# Quickly set up a namespace that protects `$`, so we can safely use
# short-hand in all of our plugins.
(($) ->

	# Symbol Plugin
	# -------------
	# Symbol adds a dynamic property: Bling.symbol, which contains the
	# current global binding where you can find Bling (default: `$`).

	# When you assign a symbol, it carefully tracks the previous values
	# and restores them later if you change.  This is all so we can
	# play nice with jQuery and underscore.  For instance, if you load
	# jQuery, then load Bling, you set `Bling.symbol = "_"` and `$` will
	# go back to pointing at jQuery, and you can do `_(...)` to create a
	# Bling set.

	# There is no restriction on the length or nature of the symbol
	# except that it must be a valid JavaScript identifier:
	# > `Bling.symbol = 'foo'; Object.IsBling(foo()) == true`
	$.plugin ->
		symbol = null
		cache = {}
		(g = Object.global).Bling = Bling
		Object.defineProperty $, "symbol",
			set: (v) ->
				g[symbol] = cache[symbol]
				cache[symbol = v] = g[v]
				g[v] = Bling
			get: -> symbol
		return $: symbol: "$"

	# Compat Plugin
	# -------------
	# This keeps getting smaller over time, but we just try to bundle
	# 'shim-like' stuff here; adding or replacing basic ES5 stuff that
	# we need to use.
	$.plugin ->
		# Make sure we have String functions: `trimLeft`, and `split`.
		String::trimLeft or= -> @replace(/^\s+/, "")
		String::split or= (sep) ->
			a = []; i = 0
			while (j = @indexOf sep,i) > -1
				a.push @substring(i,j)
				i = j + 1
			a
		# Make sure we have Array functions: `join`.
		Array::join or= (sep = '') ->
			n = @length
			return "" if n is 0
			s = @[n-1]
			while --n > 0
				s = @[n-1] + sep + s
			s

		# Add a handy nuke function to events: `preventAll`.
		if Event?
			Event::preventAll = () ->
				@preventDefault()
				@stopPropagation()
				@cancelBubble = true

		# Make sure we have Element functions: `matchesSelector`, and
		# `cloneNode`.
		if Element?
			Element::matchesSelector = Element::webkitMatchesSelector or
				Element::mozMatchesSelector or
				Element::matchesSelector

			if Element::cloneNode.length is 0 # if cloneNode does not take a 'deep' argument, add support
				oldClone = Element::cloneNode
				Element::cloneNode = (deep = false) ->
					n = oldClone.call(@)
					if deep
						for i in @childNodes
							n.appendChild i.cloneNode true
					return n

		return { }

	# Core Plugin
	# -----------
	# The functional basis for all other modules.  Provides all the
	# basic stuff that you are familiar with from jQuery: 'each', 'map',
	# etc.
	$.plugin ->

		# A functor that will read property `p` from some object later.
		gettor = (prop) -> -> if Object.IsFunction(v = @[prop]) then Function.Bound(@,v) else v
		# A helper that will recursively split `p` on `.` and map a gettor
		# to read a set of complex `p` values from an object.
		selector = (p) ->
			if (i = p.indexOf '.') > -1 then @select(p.substr 0,i).select(p.substr i+1)
			else @map(gettor p)
		# See: `$.select`.

		return {
			$:
				log: log
				assert: (c, m="") -> if not c then throw new Error("assertion failed: #{m}")
				now: -> +new Date()
				delay: (->
					# `delay` uses a wrapper around setTimeout that preserves
					# the order of the delayed functions.

					# Since JS uses a single event loop, what happens if several
					# timeouts were scheduled at a time when the event loop is busy?

					# All the due functions are called in no particular order; even if
					# they were clearly scheduled in a sequence like:
					# `setTimeout(f,1); setTimeout(g,2)`.  These will execute in
					# random order when using setTimeout directly.  This isn't
					# necessarily about timer (in)accuracy, it's about how it
					# stores and dequeues handlers.

					# So, timeoutQueue will the control the order.
					timeoutQueue = Object.Extend [], (->
						next = -> @shift()() if @length
						schedule: (f, n) ->
							f.order = n + $.now()
							for i in [0...@length]
								if @[i].order > f.order
									@splice i,0,f
									break
							setTimeout next, n
							@
						cancel: (f) ->
							for i in [0...@length]
								if @[i] == f
									@splice i, 1
									break
							@
					)()

					# Note that this reverses the order of _n_ and _f_
					# intentionally.  Throughout this library, the convention is
					# to put the simple things first, to improve code flow:
					# > `$.delay 5, () ->` vs. `$.delay (() -> ), 5`
					(n, f) ->
						if Object.IsFunction(f) then timeoutQueue.schedule(f, n)
						cancel: -> timeoutQueue.cancel(f)

				)()

			# A fairly verbose string description.
			toString: -> Object.String(@)

			# Get a new set containing only the i-th element of _this_.
			eq: (i) -> $([@[i]])

			# Call a function on every item in _this_.
			each: (f) -> (f.call(t,t) for t in @); @
			# Get a new set with the results of calling a function of every
			# item in _this_.
			map: (f) -> $(f.call(t,t) for t in @)
			# Reduce _this_ to a single value, accumulating in _a_.
			# Example: `(a,x) -> a+x` == `(a) -> a+@`.
			reduce: (f, a) ->
				t = @
				if not a?
					a = @[0]
					t = @skip(1)
				(a = f.call x, a, x) for x in t
				a
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
			contains: (item, strict = true) -> ((strict and t is item) or (not strict and t == item) for t in @).reduce ((a,x) -> a or x), false
			# Get an integer count of items in _this_.
			count: (item, strict = true) -> $(1 for t in @ when (item is undefined) or (strict and t is item) or (not strict and t == item)).sum()
			# Get the first non-null item in _this_.
			coalesce: ->
				for i in @
					if Object.Type(i) in ["array","bling"] then i = $(i).coalesce()
					if i? then return i
				null
			# Swap item i with item j, in-place.
			swap: (i,j) ->
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
			select: (a...) ->
				# > `$([x]).select("name") == [ x.name ]`
				# > `$([x]).select("childNodes.1.nodeName") == [ x.childNodes[1].nodeName ]`
				return switch (n = a.length)
					# Select nothing, get nothing.
					when 0 then $()
					# Select one property, get a list of those values.
					when 1 then selector.call @, a[0]

			# Replace any false-ish items in _this_ with _x_.
			# > `$("<a>").select('parentNode').or(document)
			or: (x) -> @[i] or= x for i in [0...@length]; @

			# Assign the value _v_ to property _b_ on every
			# item in _this_.
			zap: (p, v) ->
				# `zap` supports the name dot-delimited property name scheme
				# that `select` uses. It does this by using `select`
				# internally.
				i = 0
				# If there is a dot in the name, zoom to the _last_ dot.
				i = p.indexOf(".",i) while i > -1
				if i > -1
					# Use `select` to find the head portion, the tail should be
					# a single property with no dots, which we recurse on (into
					# a lower branch next time).
					return @select(p.substr(0, i)).zap(p.substr(i+1), v)
				# If _v_ is a sequence of values, they are striped across each
				# item in _this_.
				if Object.IsArray v then @each -> @[p] = v[++i % v.length] # i starts at -1 because of the failed indexOf
				# If _v_ is a function, map and set each item's property,
				# akin to: `x[p] = v(x[p])`.
				else if Object.IsFunction v then @zap p, @select(p).map v
				# Anything else, scalars, objects, null, anything, get
				# assigned directly to each item in this.
				else @each -> @[p] = v


			# Get a new set with only the first _n_ items from _this_.
			# Negative _n_ counts from the end. `take(1)` returns a set with
			# one item.
			take: (n = 1) ->
				nn = @length
				start = 0
				end = Math.min n|0, nn
				if n < 0
					start = Math.max 0, nn+n
					end = nn
				$( @[i] for i in [start...end] )

			# Get a new set with every item except the first _n_ items.
			# Negative _n_ counts from the end. Always returns a set.
			skip: (n = 0) ->
				start = Math.max 0, n|0
				$( @[i] for i in [start...@length] )

			# Get the first item(s).
			first: (n = 1) -> if n is 1 then @[0] else @take(n)

			# Get the last item(s).
			last: (n = 1) -> if n is 1 then @[@length - 1] else @skip(@length - n)

			slice: (start=0, end=@length) -> # .slice(/i/, [/j/]) - get a subset of _this_ including [/i/../j/-1]
				# negative indices work like in python: -1 is the last item, -2 is second-to-last, null means inclusive
				n = @length
				start += n if start < 0
				end += n if end < 0
				$( @[i] for i in [start...end] )

			extend: (b) -> @.push(i) for i in b; @
			push: (b) -> Array::push.call(@, b); @

			filter: (f) -> # .filter(/f/) - select all /x/ from _this_ where /x/./f/(/x/) is true
				# or if f is a selector string, selects nodes that match the selector
				# or if f is a RegExp, select nodes where f.test(x) is true
				g = switch Object.Type f
					when "string" then (x) -> x.matchesSelector(f)
					when "regexp" then (x) -> f.test(x)
					when "function" then f
					else
						throw new Error("unsupported type passed to filter: #{Object.Type(f)}")
				$( it for it in @ when g.call(it,it) )

			test: (regex) -> @map -> regex.test(@)
			matches: (expr) -> @select('matchesSelector').call(expr)

			querySelectorAll: (s) ->
				@filter("*").reduce (a, i) ->
					a.extend(i.querySelectorAll(s))
				, $()

			# Get a new set with items interleaved from the items in _a_ and
			# _b_. The result is:
			# > `$([ b[i], this[i], ... ])`
			weave: (b) ->
				c = $()
				# First spread out _this_, from back to front.
				for i in [@length-1..0]
					c[(i*2)+1] = @[i]
				# Then interleave items from _b_, from front to back
				for i in [0...b.length]
					c[i*2] = b[i]
				c
			# Notes about `weave`:
			# * the items of b come first.
			# * the result always has 2 * max(length) items.
			# * if b and this are different lengths, the shorter will yield
			# `undefined`s into the result.

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
				b = $([])
				(b.push(j) for j in i) for i in @
				b

			# Call every function in _this_ with the same arguments.
			call: -> @apply(null, arguments)

			# Apply every function in _this_ to _context_ with _args_.
			apply: (context, args) ->
				@map -> @apply(context, args) if Object.IsFunction @ else @

			# Continue with _f_ after _n_ milliseconds.
			delay: (n, f) ->
				$.delay n, Function.Bound(@, f)

			# Log one line for each item.
			log: (label) -> # .log([label]) - console.log([/label/] + /x/) for /x/ in _this_
				if label
					$.log(label, @, @length + " items")
				else
					$.log(@, @length + " items")
				@

			array: -> (@.__proto__ = Array::); @ # no copies, yay!
		}

	$.plugin -> # Math plugin
		$:
			range: (start, end, step = 1) -> # $.range generates an array of numbers
				step *= -1 if end < start and step > 0 # force step to have the same sign as start->end
				$( (start + (i*step)) for i in [0...Math.ceil( (end - start) / step )] )
			zeros: (n) -> $( 0 for i in [0...n] )
			ones: (n) -> $( 1 for i in [0...n] )
		floats: -> @map parseFloat
		ints: -> @map -> parseInt @, 10
		px: (delta) -> @ints().map -> String.Px @,delta
		min: -> @reduce (a) -> Math.min @, a
		max: -> @reduce (a) -> Math.max @, a
		mean: -> @sum() / @length
		sum: -> @reduce (a) -> a + @
		squares: -> @map -> @ * @
		magnitude: -> Math.sqrt @floats().squares().sum()
		scale: (r) -> @map -> r * @
		add: (d) -> @map -> d + @
		normalize: -> @scale(1/@magnitude())

	$.plugin -> # Pub/Sub plugin
		subscribers = {} # a mapping of channel name to a list of subscribers

		publish = (e, args...) ->
			f.apply null, args for f in (subscribers[e] or= [])
			@

		subscribe = (e, func) ->
			(subscribers[e] or= []).push func
			func

		unsubscribe = (e, func) ->
			if not func?
				subscribers[e] = []
			else
				subscribers[e] or= []
				i = subscribers[e].indexOf(func)
				if i > -1
					subscribers[e].splice(i,i)

		return {
			$:
				publish: publish
				subscribe: subscribe
				unsubscribe: unsubscribe
		}

	$.plugin -> # Throttle/Debounce plugin
		return {
			$:
				throttle: (f,n=250,last=0) ->
					(a...) ->
						gap = $.now() - last
						if gap > n
							last += gap
							return f.apply @,a
						null
				debounce: (f,n=250,last=0) -> # must be a silence of n ms before f is called again
					(a...) ->
						last += (gap = $.now() - last)
						return f.apply @,a if gap > n else null
		}

	$.plugin -> # EventEmitter
		class EventEmitter
			constructor:        -> @_eh = {}
			addListener:        (e, h) -> (@_eh[e] or= []).push(h); @emit('newListener', e, h)
			on:                 (e, h) -> @addListener e, h
			once:               (e,h) -> @addListener e, (f = (a...) -> @removeListener(f); h(a...))
			removeListener:     (e, h) -> @_eh[e].splice i, 1 if (i = (@_eh[e] or= []).indexOf(h)) > -1
			removeAllListeners: (e) -> @_eh[e] = []
			setMaxListeners:    (n) -> # nop for now... who really needs this in the core API?
			listeners:          (e) -> @_eh[e]
			emit:               (e, a...) -> (f.apply(@, a) for f in (@_eh[e] or= [])); null

		return $: EventEmitter: EventEmitter


	if Object.global.document?
		Object.Type.register "nodelist",
			match: (o) -> o? and Object.IsType "NodeList", o
			hash: (o) -> $(Object.Hash(i) for i in x).sum()
			array: Function.Identity
			string: (o) -> "{nodelist:"+$(o).select('nodeName').join(",")+"}"
			node: -> $(@).toFragment()
		Object.Type.register "node",
			match: (o) -> o?.nodeType > 0
			hash: (o) -> String.Checksum(o.nodeName) + Object.Hash(o.attributes) + String.Checksum(o.innerHTML)
			string: (o) -> o.toString()
			node: Function.Identity
		Object.Type.register "fragment",
			match: (o) -> o?.nodeType is 11
			hash: (o) -> $(Object.Hash(x) for x in o.childNodes).sum()
			string: (o) -> o.toString()
			node: Function.Identity
		Object.Type.register "html",
			match: (o) -> typeof o is "string" and (s=o.trimLeft())[0] == "<" and s[s.length-1] == ">"
			node: (o) -> Object.Type.lookup(h = Bling.HTML.parse(o)).node(h)
			array: (o,c) -> Object.Type.lookup(h = Bling.HTML.parse(o)).array(h,c)
		Object.Type.extend null, node: -> null
		Object.Type.extend
			bling:    { node: -> @toFragment() }
			string:
				node: -> $(@).toFragment()
				array: (o,c) -> c.querySelectorAll?(o)
			function: { node: -> $(@toString()).toFragment() }

		$.plugin -> # Html plugin
			frag = (a) ->
				if not a.parentNode?
					df = document.createDocumentFragment()
					df.appendChild(a)
				a
			before = (a,b) -> frag(a).parentNode.insertBefore b, a
			after = (a,b) -> frag(a).parentNode.insertBefore b, a.nextSibling
			node = (x) -> Object.Type.lookup(x).node(x)
			escaper = 0

			# window.getComputedStyle is not a normal function
			# (it doesnt support .call() so we can't use it with .map())
			# so define something that does work properly for use in .css
			computeCSSProperty = (k) -> -> window.getComputedStyle(@, null).getPropertyValue(k)

			getOrSetRect = (p) -> (x) -> @css(p, x) if x? else @rect().select(p)

			return {
				$:

					# `$.HTML` provides methods similar to the global JSON
					# object, for parsing from and to HTML.
					HTML:
						# Parse the html in string h into a node or fragment.
						parse: (h) ->
							# Put the html into a new div.
							(node = document.createElement("div")).innerHTML = h
							# If there's only one resulting child, return that Node.
							if n = (childNodes = node.childNodes).length is 1
								return node.removeChild(childNodes[0])
							# Otherwise, copy all the div's children into a new
							# fragment.
							df = document.createDocumentFragment()
							df.appendChild(node.removeChild(childNodes[0])) for i in [0...n]
							df
						# Convert a node or fragment to an HTML string.
						stringify: (n) ->
							switch Object.Type n
								when "string","html" then n
								when "node","fragment"
									d = document.createElement "div"
									d.appendChild (n = n.cloneNode true)
									# Uses .innerHTML to render the HTML.
									ret = d.innerHTML
									d.removeChild n # break links to prevent leaks
									ret
								else "HTML.stringify of unknown type: " + Object.Type(n)
						# Escape html characters in _h_, so "<" becomes "&lt;",
						# etc.
						escape: (h) ->
							# Create a singleton div with a text node within it.
							escaper or= $("<div>&nbsp;</div>").child(0)
							# Insert _h_ using the text node's .data property,
							# then get escaped html from the _parent's_ innerHTML.
							ret = escaper.zap('data', h).select("parentNode.innerHTML").first()
							# Clean up so content doesn't litter.
							escaper.zap('data', '')
							ret

				# Get [or set] innerHTML for each node.
				html: (h) ->
					return switch Object.Type h
						when "undefined","null" then @select 'innerHTML'
						when "string" then @zap 'innerHTML', h
						when "bling" then @html h.toFragment()
						when "node"
							@each -> # replace all our children with the new child
								@replaceChild @childNodes[0], h
								while @childNodes.length > 1
									@removeChild @childNodes[1]

				append: (x) -> # .append(/n/) - insert /n/ [or a clone] as the last child of each node
					x = node(x) # parse, cast, do whatever it takes to get a Node or Fragment
					a = @select('appendChild')
					a.take(1).call(x)
					a.skip(1).each (f) ->
						f(x.cloneNode(true)) # f is already bound to @
					@

				appendTo: (x) -> # .appendTo(/n/) - each node [or a fragment] will become the last child of n
					$(x).append(@)
					@

				prepend: (x) -> # .prepend(/n/) - insert n [or a clone] as the first child of each node
					if x?
						x = node(x)
						@take(1).each ->
							before @childNodes[0], x
						@skip(1).each ->
							before @childNodes[0], x.cloneNode(true)
					@

				prependTo: (x) -> # .prependTo(/n/) - each node [or a fragment] will become the first child of n
					if x?
						$(x).prepend(@)
					@

				before: (x) -> # .before(/x/) - insert content x before each node
					if x?
						x = node(x)
						@take(1).each -> before @, x
						@skip(1).each -> before @, x.cloneNode(true)
					@

				after: (x) -> # .after(/n/) - insert content n after each node
					if x?
						x = node(x)
						@take(1).each -> after @, x
						@skip(1).each -> after @, x.cloneNode(true)
					@

				wrap: (parent) -> # .wrap(/p/) - p becomes the new .parentNode of each node
					# all items of @ will become children of parent
					# parent will take each child's position in the DOM
					parent = node(parent)
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

				unwrap: -> # .unwrap() - replace each node's parent with itself
					@each ->
						if @parentNode and @parentNode.parentNode
							@parentNode.parentNode.replaceChild(@, @parentNode)
						else if @parentNode
							@parentNode.removeChild(@)

				replace: (n) -> # .replace(/n/) - replace each node with n [or a clone]
					n = node(n)
					b = $()
					j = 0
					# first node gets the real n
					@take(1).each ->
						@parentNode?.replaceChild(n, @)
						b[j++] = n
					# the rest get clones of n
					@skip(1).each ->
						c = n.cloneNode(true)
						@parentNode?.replaceChild(c, @)
						b[j++] = c
					# the set of inserted nodes
					b

				attr: (a,v) -> # .attr(a, [v]) - get [or set] an /a/ttribute [/v/alue]
					switch v
						when undefined
							return @select("getAttribute").call(a, v)
						when null
							return @select("removeAttribute").call(a, v)
						else
							@select("setAttribute").call(a, v)
							return @

				data: (k, v) ->
					k = "data-#{String.Dashize(k)}"
					@attr(k, v)

				addClass: (x) -> # .addClass(/x/) - add x to each node's .className
					@removeClass(x).each ->
						c = @className.split(" ").filter (y) ->
							y isnt ""
						c.push(x) # since we dont know the len, its still faster to push, rather than insert at len()
						@className = c.join " "

				removeClass: (x) -> # .removeClass(/x/) - remove class x from each node's .className
					notx = (y)-> y != x
					@each ->
						c = @className?.split(" ").filter(notx).join(" ")
						if c.length is 0
							@removeAttribute('class')

				toggleClass: (x) -> # .toggleClass(/x/) - add, or remove if present, class x from each node
					notx = (y) -> y isnt x
					@each ->
						cls = @className.split(" ")
						filter = Function.Not Object.IsEmpty
						if( cls.indexOf(x) > -1 )
							filter = Function.And notx, filter
						else
							cls.push(x)
						c = cls.filter(filter).join(" ")
						@className = c
						if c.length is 0
							@removeAttribute('class')

				hasClass: (x) -> # .hasClass(/x/) - true/false for each node: whether .className contains x
					@select('className.split').call(" ").select('indexOf').call(x).map (x) -> x > -1

				text: (t) -> # .text([t]) - get [or set] each node's .textContent
					return @zap('textContent', t) if t?
					return @select('textContent')

				val: (v) -> # .val([v]) - get [or set] each node's .value
					return @zap('value', v) if v?
					return @select('value')

				# Get [or set] css properties.
				css: (k,v) ->
					# If we are doing assignment.
					if v? or Object.IsObject k
						# Use a bound-method to do the assignment for us.
						setter = @select 'style.setProperty'
						# If you give an object as a key, then use every k:v pair.
						if Object.IsObject k then setter.call i, k[i], "" for i of k
						# So, the key is simple, and if the value is a string,
						# just do simple assignment (using setProperty).
						else if Object.IsString v then setter.call k, v, ""
						# If the value was actually an array of values, then
						# stripe the values across each item.
						else if Object.IsArray v
							setter[i%nn] k, v[i%n], "" for i in [0...n = Math.max v.length, nn = setter.len()]
						return @
					# Else, we are reading CSS properties.
					else
						# So, collect the full computed values.
						cv = @map computeCSSProperty(k)
						# Then, collect the values specified directly on the node.
						ov = @select('style').select k
						# Weave and fold them so that object values override
						# computed values.
						ov.weave(cv).fold (x,y) -> x or y

				# Set css properties by injecting a style element in the the
				# head. If _k_ is an object of k:v pairs, then no second argument is needed.
				defaultCss: (k, v) ->
					# @selector need not match any nodes at the time of the call.
					sel = @selector
					style = ""
					if Object.IsString(k)
						if Object.IsString(v)
							style += "#{sel} { #{k}: #{v} } "
						else throw Error("defaultCss requires a value with a string key")
					else if Object.IsObject(k)
						style += "#{sel} { " +
							"#{i}: #{k[i]}; " for i of k +
						"} "
					$("<style></style>").text(style).appendTo("head")
					@

				# Get a bounding-box for each item.
				rect: -> @select('getBoundingClientRect').call()

				# Get [or set] each item's width.
				width: getOrSetRect("width")

				# Get [or set] each item's height.
				height: getOrSetRect("height")

				# Get [or set] each item's top.
				top: getOrSetRect("top")

				# Get [or set] each item's left.
				left: getOrSetRect("left")

				# Get [or set] each item's bottom.
				bottom: getOrSetRect("bottom")

				# Get [or set] each item's right.
				right: getOrSetRect("right")

				# Get [or set] each item's position.
				position: (left, top) ->
					switch true
						# If called with no arguments, just return the position.
						when not left? then @rect()
						# If called with only one argument, only set "left".
						when not top? then @css("left", String.Px(left))
						# If called with both arguments, set "top" and "left".
						else @css({top: String.Px(top), left: String.Px(left)})

				# Adjust the document's scroll position so the first node in
				# _this_ is centered in the viewport.
				scrollToCenter: ->
					document.body.scrollTop = @[0].offsetTop - (window.innerHeight / 2)
					@

				# Get the _n-th_ child from each node in _this_.
				child: (n) -> @select('childNodes').map -> @[ (n+@length) if n < 0 else n ]

				parents: -> @map -> p = @; $( p while p = p?.parentNode ) # .parents() - collects the full ancestry up to the owner

				prev: -> @map -> p = @; $( p while p = p?.previousSibling ) # .prev() - collects the chain of .previousSibling nodes

				next: -> @map -> p = @; $( p while p = p?.nextSibling ) # .next() - collect the chain of .nextSibling nodes

				remove: -> @each -> @parentNode?.removeChild(@) # .remove() - removes each node in _this_ from the DOM

				find: (css) -> # .find(/css/) - collect nodes matching /css/
					@filter("*") # limit to only DOM nodes
						.map( -> $(css, @) )
						.flatten()

				clone: (deep=true) -> @map -> (@cloneNode deep) if Object.IsNode @ # .clone(deep=true) - copies a set of DOM nodes

				toFragment: ->
					if @length > 1
						df = document.createDocumentFragment()
						adder = Function.Bound(df, df.appendChild)
						@map(node).map adder
						return df
					return node(@[0])
			}

		$.plugin -> # Transform plugin, for accelerated animations
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
				$:
					duration: (speed) -> # $.duration(/s/) - given a speed description (string|number), return a number in milliseconds
						d = speeds[speed]
						return d if d?
						return parseFloat speed

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
						props.map( -> duration)
							.join(COMMASEP)
					# apply an easing function to each property
					css[transitionTiming] =
						props.map( -> easing)
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
					@each ->
						if @style
							@_display = "" # stash the old display
							if @style.display is not "none"
								@_display = @syle.display
							@style.display = "none"
					.trigger("hide")
					.delay(updateDelay, callback)

				show: (callback) -> # .show() - show each node
					@each ->
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
						.show ->
							@transform {
								opacity:"1.0",
								translate3d: [0,0,0]
							}, speed, callback
				fadeOut: (speed, callback, x = 0.0, y = 0.0) -> # .fadeOut() - fade each node to opacity:0.0
					@transform {
						opacity:"0.0",
						translate3d:[x,y,0.0]
					}, speed, -> @hide(callback)
				fadeLeft: (speed, callback) -> @fadeOut(speed, callback, "-"+@width().first(), 0.0)
				fadeRight: (speed, callback) -> @fadeOut(speed, callback, @width().first(), 0.0)
				fadeUp: (speed, callback) -> @fadeOut(speed, callback, 0.0, "-"+@height().first())
				fadeDown: (speed, callback)  -> @fadeOut(speed, callback, 0.0, @height().first())
			}

		$.plugin -> # HTTP Request plugin: provides wrappers for making http requests
			formencode = (obj) -> # create &foo=bar strings from object properties
				o = JSON.parse(JSON.stringify(obj)) # quickly remove all non-stringable items
				("#{i}=#{escape o[i]}" for i of o).join("&")

			Object.Type.register "http",
				match: (o) -> Object.IsType 'XMLHttpRequest', o
				asArray: (o) -> [o]

			return {
				$: # globals
					http: (url, opts = {}) -> # $.http(/url/, [/opts/]) - fetch /url/ using HTTP (method in /opts/)
						xhr = new XMLHttpRequest()
						if Object.IsFunction(opts)
							opts = {success: Function.Bound(xhr, opts)}
						opts = extend {
							method: "GET"
							data: null
							state: Function.Identity # onreadystatechange
							success: Function.Identity # onload
							error: Function.Identity # onerror
							async: true
							asBlob: false
							timeout: 0 # milliseconds, 0 is forever
							followRedirects: false
							withCredentials: false
						}, opts
						opts.state = Function.Bound(xhr, opts.state)
						opts.success = Function.Bound(xhr, opts.success)
						opts.error = Function.Bound(xhr, opts.error)
						if opts.data and opts.method is "GET"
							url += "?" + formencode(opts.data)
						else if opts.data and opts.method is "POST"
							opts.data = formencode(opts.data)
						xhr.open(opts.method, url, opts.async)
						xhr = extend xhr,
							asBlob: opts.asBlob
							timeout: opts.timeout
							followRedirects: opts.followRedirects
							withCredentials: opts.withCredentials
							onreadystatechange: ->
								opts.state?()
								if xhr.readyState is 4
									if xhr.status is 200
										opts.success xhr.responseText
									else
										opts.error xhr.status, xhr.statusText
						xhr.send opts.data
						return $(xhr)

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

		$.plugin -> # Events plugin
			EVENTSEP_RE = /,* +/
			events = ['mousemove','mousedown','mouseup','mouseover','mouseout','blur','focus',
				'load','unload','reset','submit','keyup','keydown','change',
				'abort','cut','copy','paste','selection','drag','drop','orientationchange',
				'touchstart','touchmove','touchend','touchcancel',
				'gesturestart','gestureend','gesturecancel',
				'hashchange'
			] # 'click' is handled specially

			binder = (e) -> (f) -> @bind(e, f) if Object.IsFunction f else @trigger(e, f)

			register_live = (selector, context, evt, f, h) ->
				$(context).bind(evt, h)
					# set/create all of @__alive__[selector][evt][f]
					.each -> (((@__alive__ or= {})[selector] or= {})[evt] or= {})[f] = h

			unregister_live = (selector, context, e, f) ->
				$c = $(context)
				$c.each ->
					a = (@__alive__ or= {})
					b = (a[selector] or= {})
					c = (b[e] or= {})
					$c.unbind(e, c[f])
					delete c[f]

			# detect and fire the document.ready event
			triggerReady = Function.Once ->
				$(document).trigger("ready").unbind("ready")
				document.removeEventListener?("DOMContentLoaded", triggerReady, false)
				window.removeEventListener?("load", triggerReady, false)
			bindReady = Function.Once ->
				document.addEventListener?("DOMContentLoaded", triggerReady, false)
				window.addEventListener?("load", triggerReady, false)
			bindReady()

			ret = {
				bind: (e, f) -> # .bind(e, f) - adds handler f for event type e
					c = (e or "").split(EVENTSEP_RE)
					h = (evt) ->
						ret = f.apply @, arguments
						if ret is false
							evt.preventAll()
						ret
					@each -> (@addEventListener i, h, false) for i in c

				unbind: (e, f) -> # .unbind(e, [f]) - removes handler f from event e
					c = (e or "").split(EVENTSEP_RE)
					@each -> (@removeEventListener i, f, null) for i in c

				once: (e, f) -> # .once(e, f) - adds a handler f that will only fire once (per node)
					c = (e or "").split(EVENTSEP_RE)
					for i in c
						@bind i, (evt) ->
							f.call(@, evt)
							@removeEventListener(evt.type, arguments.callee, null)

				cycle: (e, funcs...) -> # .cycle(e, ...) - bind handlers for e that trigger in a cycle
					c = (e or "").split(EVENTSEP_RE)
					nf = funcs.length
					cycler = (i = -1) ->
						(evt) -> funcs[i = ++i % nf].call(@, evt)
					@bind j, cycler() for j in c
					@

				trigger: (evt, args = {}) -> # .trigger(e, a) - initiates a fake event
					args = extend {
						bubbles: true
						cancelable: true
					}, args

					for evt_i in (evt or "").split(EVENTSEP_RE)
						if evt_i in ["click", "mousemove", "mousedown", "mouseup", "mouseover", "mouseout"] # mouse events
							e = document.createEvent "MouseEvents"
							args = extend {
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
							args = extend {
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
							args = extend {
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
								e = extend e, args
							catch err

						if not e
							continue
						else
							try
								@each -> @dispatchEvent e
							catch err
								log("dispatchEvent error:",err)
					@

				live: (e, f) -> # .live(e, f) - handle events for nodes that will exist in the future
					selector = @selector
					context = @context
					# wrap f
					handler = (evt) -> # later, when event 'e' is fired
						$(selector, context) # re-execute the selector in the original context
							.intersect($(evt.target).parents().first().union($(evt.target))) # see if the event would bubble into a match
							.each -> f.call(evt.target = @, evt) # then fire the real handler 'f' on the matched nodes
					# record f so we can 'die' it if needed
					register_live selector, context, e, f, handler
					@

				die: (e, f) -> # die(e, [f]) - stop f [or all] from living for event e
					$(@context).unbind e, unregister_live(@selector, @context, e, f)
					@

				liveCycle: (e, funcs...) -> # .liveCycle(e, ...) - bind each /f/ in /funcs/ to handle /e/
					i = -1; nf = funcs.length
					@live e, (evt) -> funcs[i = ++i % nf].call @, evt

				click: (f = {}) -> # .click([f]) - trigger [or bind] the 'click' event
					if @css("cursor") in ["auto",""] # if the cursor is default
						@css "cursor", "pointer" # then make it look clickable
					if Object.IsFunction f
						@bind 'click', f
					else
						@trigger 'click', f

				ready: (f) ->
					return (f.call @) if triggerReady.n <= 0
					@bind "ready", f
			}

			# add event binding/triggering shortcuts for the generic events
			events.forEach (x) -> ret[x] = binder(x)
			return ret

		$.plugin -> # LazyLoader plugin, depends on PubSub
			create = (elementName, props) ->
				extend document.createElement(elementName), props

			lazy_load = (elementName, props) ->
				depends = provides = null
				n = create elementName, extend(props, {
					onload: ->
						if provides?
							$.publish(provides)
				})
				$("head").delay 10, ->
					if depends?
						$.subscribe depends, => @append(n)
					else @append(n)
				extend $(n),
					depends: (tag) -> depends = elementName+"-"+tag; @
					provides: (tag) -> provides = elementName+"-"+tag; @

			return {
				$:
					script: (src) ->
						lazy_load "script", { src: src }
					style: (src) ->
						lazy_load "link", { href: src, "rel!": "stylesheet" }
			}



)(Bling)
# vim: ft=coffee sw=2 ts=2
