# License: MIT. Author: Jesse Dailey <jesse.dailey@gmail.com>

# Philoshopy
# ----------
# 1. Always work on _sets_, scalars are annoying.
#    If you always write code to handle sets, you usually handle the scalar case for free.
# 2. Don't alter global prototypes; play _nice_ with others.
# 3. Have _fun_ and learn; about the DOM, about jQuery, about JavaScript and CoffeeScript.
# 4. Have the _courage_ to refactor; learning requires some chaos.

# Warming Up
# ---------
# We need a few things to get started.

# We need a few things to get started:

# A safe logger to use for `$.log()`.
log = (a...) ->
	try return console.log.apply console, a
	alert a.join(", ")

# A shim for `Object.keys`.
Object.keys ?= (o) -> (k for k of o)

# A way to assign properties from `b` to `a`.
extend = (a, b) ->
	return a if not b
	for k in Object.keys(b)
		v = b[k]
		if v? then a[k] = v
	a

# A wrapper for Object.defineProperty that changes the defaults
defineProperty = (o,name,opts) ->
	Object.defineProperty o,name, extend({
		configurable: true
		enumerable: true
	}, opts)

# Type System
# -----------
# The core is built around a _type classifier_. Initially, this
# will only know how to match types (and the order to check them in).
# Later in this file, the type-instance resulting from classification will be
# extended to provide more operations, e.g. helping to construct blings.

# Before we build a full classifier, we need a few type-related
# helpers.

# `isType(T, obj)` is a simple boolean test to see if any
# object is of type `T`; respecting prototype chains,
# constructors, and anything else we can think of that matters.
isType = (T, o) ->
	if not o? then T in [o,"null","undefined"]
	else o.constructor is T or
		o.constructor.name is T or
		Object::toString.apply(o) is "[object #{T}]" or
		isType T, o.__proto__ # recursive

# `inherit(parent, child)` is similar to extend, except it works by
# inserting the parent as the prototype of the child _instance_. This is unlike
# coffee's `class X extends Y`, because it expects the target `child`
# to be an _instance_, and the `parent` can either be an _instance_ or a
# __constructor__.
inherit = (parent, obj) ->
	if typeof parent is "function"
		obj.constructor = parent
		parent = parent:: # so that the obj instance will inherit all of the prototype (but _not a copy_ of it).
	obj.__proto__ = parent
	obj

# Now, let's begin to build the classifier for `$.type(obj)`.
type = (->

	# Privately, maintain a registry of known types.
	cache = {}

	# Each type in the registry is an instance that inherits from a
	# _base_ object.  Later, when we want to do more than `match` with
	# each type, we will extend this base with default implementations.
	base =
		name: 'unknown'
		match: (o) -> true

	# When classifying an object, this array of names will control
	# the order of the calls to `match` (and thus, the _type precedence_).
	order = []

	# When adding a new type to the regisry:
	register = (name, data) ->
		# * Put the type check in order (if it isn't already).
		order.unshift name if not (name of cache)
		# * inherit from the base type and store in the cache.
		cache[data.name = name] = if (base isnt data) then (inherit base, data) else data

	# Later, plugins can `extend` previously registered types with new
	# functionality.
	_extend = (name, data) ->
		# The `name` should be of a registered type (a key into the cache)
		if typeof name is "string"
			# But, if you attempt to extend a type that was not registered yet,
			# it will be automatically registered.
			cache[name] ?= register(name, {})
			cache[name] = extend cache[name], data
		# But you can also extend a bunch of types at once, by passing a
		# 2-level deep object, where the first level of keys are type
		# names and the second level of keys are objects full of
		# extensions.
		else if typeof name is "object"
			(_extend k, name[k]) for k of name

	# To classify an object, simply check every match in order.
	lookup = (obj) ->
		for name in order
			if cache[name]?.match.call obj, obj
				return cache[name]

	# Now, register all the built-in types. These checks are
	# executed in _reverse order_, so the first listed here, `"unknown"`,
	# is always checked last.
	register "unknown",   base
	# This implies that the 'simplest' checks should be registered
	# first, and conceptually more specialized checks would get added
	# as time goes on (so specialized type matches are preferred).
	register "object",    match: -> typeof @ is "object"
	register "error",     match: -> isType 'Error', @
	register "regexp",    match: -> isType 'RegExp', @
	register "string",    match: -> typeof @ is "string" or isType String, @
	register "number",    match: -> isType Number, @
	register "bool",      match: -> typeof @ is "boolean" or String(@) in ["true","false"]
	register "array",     match: -> Array.isArray?(@) or isType Array, @
	register "function",  match: -> typeof @ is "function"
	register "global",    match: -> typeof @ is "object" and 'setInterval' of @ # Use the same crude method as jQuery for detecting the window, not very safe but it does work in Node and the browser
	# These checks for null and undefined are small exceptions to the
	# simple-first idea, since they are precise and getting them out
	# of the way early lets the above tests omit a safety check.
	register "undefined", match: (x) -> x is undefined
	register "null",      match: (x) -> x is null

	# Now, we finally have all the pieces to make the real classifier.
	return extend ((o) -> lookup(o).name),
		register: register
		lookup: lookup
		extend: _extend
		is: (t, o) -> cache[t]?.match.call o, o

	# Example: Calling $.type directly will get you the simple name of the
	# best match.
	# > `type([]) == "array"`

	# If you want to know everything, you can use lookup
	# directly.
	# > `type.lookup([]).name == "array"`

	# Later, once other systems have extended the base type, the
	# type-instance returned from type.lookup will do more.

)()


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

# 1. _The copy is shallow_; creating partially-shared state between
# instances.
# 2. _There is a copy at all_; it's nice to avoid copying in critical
# sections whenever possible.
# 3. _It replaces the return value of the constructor_; reducing
# flexibility in implementations.

# So, the Bling constructor should not be called as `new Bling`,
# and as a bonus our assignment to a symbol (`$`) remains simple.
class Bling
	
	# We compute this only once, privately, so we dont have to check
	# during every construction.
	default_context = if document? then document else {}

	constructor: (selector, context = default_context) ->
		# Since we have this nice Type system, our constructor is succinct:
		# * Classify the type.
		# * Convert the selector to a set using the type-instance (which
		# in the case of anything array-like is a no-op).
		# * Use inherit to _hijack_ the set's prototype in-place.
		return inherit Bling, extend type.lookup(selector).array(selector, context),
			selector: selector
			context: context

	# $.plugin( [ opts ], func )
	# -----------------
	# Each plugin is a function that returns an object full of stuff to
	# extend the Bling prototype with.

	# Example: the simplest possible plugin.
	# > $.plugin -> echo: -> @

	# After this, `$(...).echo()` will work.  Also, this will
	# create a default 'root' version: `$.echo`.

	# You can explicitly define root-level values by nesting things
	# under a `$` key:
	# > $.plugin () -> $: hello: -> "Hello!"

	# This will create `$.hello`, but not `$().hello`.
	@plugin: (opts, constructor) ->
		if not constructor?
			constructor = opts; opts = {}
		
		if "depends" of opts
			return @depends opts.depends, =>
				@plugin { provides: opts.provides }, constructor
		try
			# We call the plugin constructor and expect that it returns an
			# object full of things to attach to either Bling or it's prototype.
			if (plugin = constructor?.call @,@)
				# If the plugin has a `$` key, extend the root.
				extend @, plugin?.$
				# Clean off keys we no longer care about: `$` and `name`. (An
				# older version of plugin() used to require names,
				# but we ignore them now in favor of depends/provides.
				['$','name'].forEach (k) -> delete plugin[k]
				# Now put everything else on the Bling prototype
				extend @::, plugin
				# Finally, add root-level wrappers for anything that doesn't
				# have one already.
				( @[key] or= (a...) => (@::[key].apply $(a[0]), a[1...]) ) for key of plugin
				if opts.provides? then @provide opts.provides
		catch error
			log "failed to load plugin: #{this.name} '#{error.message}'"
			throw error
		@
	
	# Code dependencies
	# -----------------
	# $.depends, $.provide and $.provides, allow for representing
	# dependencies between any functions. Plugins can and should use this
	# to ensure their correct loading order.
	qu = []
	done = {}
	filt = (n) ->
		(if (typeof n) is "string" then n.split "," else n)
		.filter (x) -> not (x of done)

	@depends: (needs, f) ->
		if (needs = filt(needs)).length is 0 then f()
		else qu.push (need) ->
			((needs.splice i, 1) if ( i = needs.indexOf need ) > -1) and
			needs.length is 0 and
			f
		f

	@provide: (needs) ->
		console.log "provide(#{needs})"
		for need in filt(needs)
			done[need] = i = 0
			while i < qu.length
				if (f = qu[i](need)) then (qu.splice i,1; f())
				else i++
		null

	@provides: (needs, f) -> (a...) -> r=f(a...); Bling.provide(needs); r

	#### Registering the "bling" type.
	# First, we give the basic types the ability to turn into something
	# array-like, for use by the constructor.
	type.extend
		# If we don't know any better way, we just stick the
		# thing inside a real array.
		unknown:   { array: (o) -> [o] }
		# But where we do know better, we can provide more meaningful
		# conversions. Later, in the DOM section, we will extend
		# this further to know how to convert "html", "node", etc.

		# Null and undefined values convert to an empty array.
		null:      { array: (o) -> [] }
		undefined: { array: (o) -> [] }
		# Arrays just convert to themselves.
		array:     { array: (o) -> o }
		# Numbers create a new array of that capacity.
		number:    { array: (o) -> Bling.extend new Array(o), length: 0 }

	# Now, we register "bling", and all the things we know how to do
	# with it:
	type.register "bling",
		# Add the type test so: `$.type($()) == "bling"`.
		match:  (o) -> o and isType Bling, o
		# Blings extend arrays so they convert to themselves.
		array:  (o) -> o.toArray()
		# Their hash is just the sum of member hashes.
		hash:   (o) -> o.map(Bling.hash).sum()
		# They have a very literal string representation.
		string: (o) -> Bling.symbol + "([" + o.map(Bling.toString).join(", ")+ "])"

Bling.prototype = [] # similar to `class Bling extends (new Array)`,
# if such a thing were supported by the syntax directly.


# Plugins
# =======
# Now that we have a way to load plugins and express dependencies
# between them, all future code will come in a plugin.
# 
# For the rest of this file, set up a namespace that protects `$`,
# so we can safely use short-hand in all of our plugins.
(($) ->

	# Grab a safe (browser vs. nodejs) reference to the global object
	glob = if window? then window else global

	#### Types plugin
	# Exposes the type system publicly.
	$.plugin
		provides: "type"
	, ->
		$:
			inherit: inherit
			extend: extend
			defineProperty: defineProperty
			# `$.isType(Array, [])` is lower level than the others,
			# doing simple comparison between constructors.
			isType: isType
			# `$.type([])` equals `"array"`.
			type: type
			# `$.is("function", ->)` equals true/false.
			is: type.is
			isSimple: (o) -> type(o) in ["string", "number", "bool"]
			isEmpty: (o) -> o in ["", null, undefined]
	
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
	# > `Bling.symbol = 'foo'; $.is("bling", foo()) == true`
	$.plugin
		provides: "symbol"
	, ->
		symbol = null
		cache = {}
		glob.Bling = $
		defineProperty $, "symbol",
			set: (v) ->
				glob[symbol] = cache[symbol]
				cache[symbol = v] = glob[v]
				glob[v] = Bling
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
		# Find the last index of character `c` in the string `s`.
		String::lastIndexOf or= (s, c, i = -1) ->
			j = -1
			j = i while (i = s.indexOf c, i+1) > -1
			j

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

	# Delay Plugin
	# ------------
	# **Q**: Since JS uses a single event loop, what happens if multiple
	# setTimeout/Intervals are scheduled at a time when the event loop is busy?

	# **A**: All the due functions are called in no particular order; even if
	# they were clearly scheduled in a sequence like:
	# `setTimeout(f,1); setTimeout(g,2)`.  These will execute in
	# random order when using setTimeout directly.  This isn't
	# necessarily about timer (in)accuracy, it's about how it
	# stores and dequeues handlers.
	$.plugin
		depends: "function"
		provides: "delay"
	, ->
		$:
			delay: (->
				# timeoutQueue is a private array that controls the order.
				timeoutQueue = $.extend [], (->
					next = (a) -> -> a.shift()() if a.length
					add: (f, n) ->
						f.order = n + $.now
						for i in [0..@length] by 1
							if i is @length or @[i].order > f.order
								@splice i,0,f
								break
						setTimeout next(@), n
						@
					cancel: (f) ->
						for i in [0...@length] by 1
							if @[i] == f
								@splice i, 1
								break
						@
				)()

				# Note that this reverses the order of _n_ and _f_
				# intentionally.  Throughout this library, the convention is
				# to put the simple things first, to improve code flow:
				# > `$.delay 5, () ->` is better than `$.delay (() -> ), 5`
				(n, f) ->
					if $.is("function",f) then timeoutQueue.add(f, n)
					cancel: -> timeoutQueue.cancel(f)
			)()

		# Continue with _f_ after _n_ milliseconds.
		delay: (n, f, c=@) ->
			$.delay n, $.bound(c, f)


	# Core Plugin
	# -----------
	# The functional basis for all other modules.  Provides all the
	# basic stuff that you are familiar with from jQuery: 'each', 'map',
	# etc.
	$.plugin
		provides: "core"
	, ->

		defineProperty $, "now",
			get: -> +new Date

		# Negative indices should work the same everywhere.
		index = (i, o) ->
			i += o.length while i < 0
			Math.min i, o.length

		return {
			$:
				log: log
				assert: (c, m="") -> if not c then throw new Error("assertion failed: #{m}")
				coalesce: (a...) -> $(a).coalesce()

			# Get a new set containing only the i-th element of _this_.
			eq: (i) -> $([@[index i, @]])

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
					if $.type(i) in ["array","bling"] then i = $(i).coalesce()
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
			select: (->
				# A helper that will read property `p` from some object later.
				getter = (prop) -> -> if $.is("function",v = @[prop]) then $.bound(@,v) else v
				# Recursively split `p` on `.` and map the getter helper
				# to read a set of complex `p` values from an object.
				# > `$([x]).select("name") == [ x.name ]`
				# > `$([x]).select("childNodes.1.nodeName") == [ x.childNodes[1].nodeName ]`
				select = (p) ->
					if (i = p.indexOf '.') > -1 then @select(p.substr 0,i).select(p.substr i+1)
					else @map(getter p)
			)()

			# Replace any false-ish items in _this_ with _x_.
			# > `$("<a>").select('parentNode').or(document)`
			or: (x) -> @[i] or= x for i in [0...@length] by 1; @

			# Assign the value _v_ to property _b_ on every
			# item in _this_.
			zap: (p, v) ->
				# `zap` supports the same dot-delimited property name scheme
				# that `select` uses. It does this by using `select`
				# internally.

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
				$( @[i] for i in [start...end] by 1 )

			# Append the items in _b_ into _this_. Modifies _this_ in-place.
			extend: (b) -> @.push(i) for i in b; @

			# Appends a single item to _this_; unlike a native Array, it
			# returns a reference to _this_ for chaining.
			push: (b) -> Array::push.call(@, b); @

			# Get a new set containing only items that match _f_. _f_ can be
			# any of:
			filter: (f) ->
				# The argument _f_ can be any of:
				g = switch $.type f
					# * selector string: `.filter("td.selected")`
					when "string" then (x) -> x.matchesSelector(f)
					# * RegExp object: `.filter(/^prefix-/)`
					when "regexp" then (x) -> f.test(x)
					# * function: `.filter (x) -> (x%2) is 1`
					when "function" then f
					else
						throw new Error("unsupported type passed to filter: #{$.type(f)}")
				$( Array::filter.call @, g )
				# $( it for it in @ when g.call(it,it) )

			# Get a new set of booleans, true if the node from _this_
			# matched the CSS expression.
			matches: (expr) -> @select('matchesSelector').call(expr)

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
				@map -> if $.is "function", @ then @apply(context, args) else @

			# Log one line for each item in _this_.
			log: (label) ->
				if label
					$.log(label, @, @length + " items")
				else
					$.log(@, @length + " items")
				@

			# Convert this to an array.
			toArray: -> (@.__proto__ = Array::); @ # no copies, yay?
		}

	# Math Plugin
	# -----------
	# All the stuff you need to use blings as vectors in linear algebra.
	$.plugin
		provides: "math"
	, ->
		$:
			# Get an array of numbers.
			range: (start, end, step = 1) ->
				step *= -1 if end < start and step > 0 # force step to have the same sign as start->end
				$( (start + (i*step)) for i in [0...Math.ceil( (end - start) / step )] )
			# Get an array of zeros.
			zeros: (n) -> $( 0 for i in [0...n] by 1 )
			# Get an array of ones.
			ones: (n) -> $( 1 for i in [0...n] by 1)
		# Convert everything to a float.
		floats: -> @map parseFloat
		# Convert everything to an int.
		ints: -> @map -> parseInt @, 10
		# Convert everything to a "px" string.
		px: (delta) -> @ints().map -> $.px @,delta
		# Get the smallest element (defined by Math.min)
		min: -> @reduce (a) -> Math.min @, a
		# Get the largest element (defined by Math.max)
		max: -> @reduce (a) -> Math.max @, a
		# Get the mean (average) of the set.
		mean: -> @sum() / @length
		# Get the sum of the set.
		sum: -> @reduce (a) -> a + @
		# Get the product of all items in the set.
		product: -> @reduce (a) -> a * @
		# Get a new set with every item squared.
		squares: -> @map -> @ * @
		# Get the magnitude (vector length) of this set.
		magnitude: -> Math.sqrt @floats().squares().sum()
		# Get a new set, scaled by a real factor.
		scale: (r) -> @map -> r * @
		# Add this to d, get a new set.
		add: (d) -> switch $.type(d)
			when "number" then @map -> d + @
			when "bling","array" then $( @[i]+d[i] for i in [0...Math.min(@length,d.length)-1] by 1 )
		# Get a new set with same direction, but magnitude equal to 1.
		normalize: -> @scale(1/@magnitude())

	# String Plugin
	# -------------
	# Filling out the standard library of string functions.
	$.plugin
		depends: "function"
		provides: "string"
	, ->
		#### toString
		# Extend the base type to allow for converting things
		# to string based on their type. This is a separate system from the
		# native Object.prototype.toString chain of methods.

		$.type.extend
			# First, extend the base type with a default `string` function
			unknown:   { string: (o) -> o.toString?() ? String(o) }
			# Now, for each basic type, provide a basic `string` function.
			# Later, more complex types will be added by plugins.
			null:      { string: -> "null" }
			undefined: { string: -> "undefined" }
			string:    { string: $.identity }
			array:     { string: (a) -> "[" + ($.toString(x) for x in a).join(",") + "]" }
			object:    { string: (o) -> "{" + ("#{k}:#{$.toString(v)}" for k,v in o).join(", ") + "}" }
			number:    { string: (n) ->
				switch true
					when n.precision? then n.toPrecision(n.precision)
					when n.fixed? then n.toFixed(n.fixed)
					else String(n)
			}

		# Return a bunch of root-level string functions.
		return {
			$:
				# __$.toString(x)__ returns a fairly verbose string, based on
				# the type system's "string" method.
				toString: (x) ->
					if not x? then "function Bling(selector, context) { [ ... ] }"
					else $.type.lookup(x).string(x)
				# __$.px(x,[delta])__ computes a "px"-string ("20px"), `x` can
				# be a number or a "px"-string; if `delta` is present it will
				# be added to the number portion.
				px: (x, delta=0) -> x? and (parseInt(x,10)+(delta|0))+"px"
				# Example: Add 100px of width to an element.

				# jQuery style:
				# `node.css("width",(node.css("width") + 100) + "px")`

				# Bling style:
				# `node.zap 'style.width', -> $.px @, + 100`

				# Properly **Capitalize** Each Word In A String.
				capitalize: (name) -> (name.split(" ").map (x) -> x[0].toUpperCase() + x.substring(1).toLowerCase()).join(" ")

				# Convert a _camelCase_ name to a _dash-name_.
				dashize: (name) ->
					ret = ""
					for i in [0...(name?.length|0)] by 1
						c = name.charCodeAt i
						# For each uppercase character,
						if 91 > c > 64
							# Shift it to lower case and insert a '-'.
							c += 32
							ret += '-'
						ret += String.fromCharCode(c)
					ret

				# Convert a _dash-name_ to a _camelName_.
				camelize: (name) ->
					name.split('-')
					while (i = name?.indexOf('-')) > -1
						name = $.stringSplice(name, i, i+2, name[i+1].toUpperCase())
					name

				# Fill the left side of a string to make it a fixed width.
				padLeft: (s, n, c = " ") ->
					while s.length < n
						s = c + s
					s

				# Fill the right side of a string to make it a fixed width.
				padRight: (s, n, c = " ") ->
					while s.length < n
						s = s + c
					s

				# __$.stringCount(s,x)__ counts the number of occurences of `x` in `s`.
				stringCount: (s, x, i = 0, n = 0) ->
					if (j = s.indexOf x,i) > i-1
						$.stringCount s, x, j+1, n+1
					else n

				# __$.stringSplice(s,i,j,n)__ splices the substring `n` into the string `s', replacing indices
				# between `i` and `j`.
				stringSplice: (s, i, j, n) ->
					nn = s.length
					end = j
					if end < 0
						end += nn
					start = i
					if start < 0
						start += nn
					s.substring(0,start) + n + s.substring(end)

				# __$.checksum(s)__ computes the Adler32 checksum of a string.
				checksum: (s) ->
					a = 1; b = 0
					for i in [0...s.length]
						a = (a + s.charCodeAt(i)) % 65521
						b = (b + a) % 65521
					(b << 16) | a

				# Return a string-builder, which uses arrays to defer all string
				# concatenation until you call `builder.toString()`.
				stringBuilder: ->
					if $.is("window", @) then return new $.stringBuilder()
					items = []
					@length   = 0
					@append   = (s) => items.push s; @length += s?.toString().length|0
					@prepend  = (s) => items.splice 0,0,s; @length += s?.toString().length|0
					@clear    = ( ) => ret = @toString(); items = []; @length = 0; ret
					@toString = ( ) => items.join("")
					@
			toString: -> $.toString @
		}

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
			once: (f,n=1) -> f._once = n; -> (f.apply @,arguments) if f._once-- > 0
			# __$.bound(context,f,[args])__ returns a new function that
			# forces `this === context` when called.
			bound: (t, f, args = []) ->
				if $.is "function", f.bind
					args.splice 0, 0, t
					r = f.bind.apply f, args
				else
					r = (a...) -> f.apply t, (args if args.length else a)
				$.extend r, { toString: -> "bound-method of #{t}.#{f.name}" }
			# __$.memoize(f)__ returns a new function that caches function calls to f, based on hashing the arguments.
			memoize: (f) -> cache = {}; (a...) -> cache[$.hash(a)] ?= f.apply @, a # BUG: skips cache if f returns null on purpose


	# Trace Plugin
	# ------------
	# A very useful debugging tool, `$(o).trace() or $.trace(o)` will deep-walk all
	# properties and wrap all functions with new functions that call the
	# originals but log the calls (and use the property names from the
	# deep walk as labels).
	$.plugin
		provides: "trace"
		depends: "function,type"
	, ->
		$.type.extend
			unknown: { trace: $.identity }
			object:  { trace: (o, label, tracer) -> (o[k] = $.trace(o[k], "#{label}.#{k}", tracer) for k in Object.keys(o)); o }
			array:   { trace: (o, label, tracer) -> (o[i] = $.trace(o[i], "#{label}[#{i}]", tracer) for i in [0...o.length] by 1); o }
			function:
				trace: (f, label, tracer) ->
					r = (a...) ->
						tracer "#{@name or $.type(@)}.#{label or f.name}(", a, ")"
						f.apply @, a
					tracer "Trace: #{label or f.name} created."
					r.toString = f.toString
					r
		return {
			$:
				trace: (o, label, tracer) -> $.type.lookup(o).trace(o, label, tracer)
			trace: (label, tracer) -> @map -> $.trace(@,label,tracer)
		}


	# Hash plugin
	# -----------
	# `$.hash(o)` Reduces any thing to an integer hash code (not secure).
	$.plugin
		provides: "hash"
		depends: "type"
	, ->
		$.type.extend
			unknown: { hash: (o) -> $.checksum $.toString(o) }
			object:  { hash: (o) -> ($.hash(o[k]) for k of o) + $.hash(Object.keys(o)) }
			array:   { hash: (o) -> ($.hash(i) for i in x).reduce (a,x) -> a+x }
			bool:    { hash: (o) -> parseInt(1 if o) }
		return {
			$:
				hash: (x) -> $.type.lookup(x).hash(x)
			hash: () -> $.hash(@)
		}

	# Publish/Subscribe plugin
	# -----------------
	# Publish messages to a named channel, those messages invoke each
	# function subscribed to that channel.
	$.plugin
		provides: "pubsub"
	, ->
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
				a = (subscribers[e] or= [])
				if (i = a.indexOf func)  > -1
					a.splice(i,i)
		return {
			$:
				publish: publish
				subscribe: subscribe
				unsubscribe: unsubscribe
		}

	# Throttle Plugin
	# ---------------
	# `$.throttle` and `$.debounce` are two different ways to rate limit
	# a function.  Both are function decorators.
	$.plugin
		provides: "throttle"
		depends: "core"
	, ->
		$:
			throttle: (f,n=250,last=0) ->
				(a...) ->
					gap = $.now - last
					if gap > n
						last += gap
						return f.apply @,a
					null
			debounce: (f,n=250,last=0) -> # must be a silence of n ms before f is called again
				(a...) ->
					last += (gap = $.now - last)
					return f.apply @,a if gap > n else null

	# EventEmitter Plugin
	# -------------------
	# The EventEmitter interface that NodeJS uses is much simpler (and faster) than the DOM event model.
	# Example: `$.inherit new EventEmitter(), { myCode: () -> "..." }`
	$.plugin
		provides: "EventEmitter"
	, ->
		$: EventEmitter: class EventEmitter
			constructor:        -> @__event = {}
			addListener:        (e, h) -> (@__event[e] or= []).push(h); @emit('newListener', e, h)
			on:                 (e, h) -> @addListener e, h
			once:               (e,h) -> @addListener e, (f = (a...) -> @removeListener(f); h(a...))
			removeListener:     (e, h) -> (@__event[e].splice i, 1) if (i = (@__event[e] or= []).indexOf(h)) > -1
			removeAllListeners: (e) -> @__event[e] = []
			setMaxListeners:    (n) -> # nop for now... who really needs this in the core API?
			listeners:          (e) -> @__event[e]
			emit:               (e, a...) -> (f.apply(@, a) for f in (@__event[e] or= [])); null

	
	if glob.document?
		# DOM Plugin
		# ----------
		$.plugin
			depends: "function"
			provides: "dom"
		, ->
			$.type.register "nodelist",
				match:  (o) -> o? and $.isType "NodeList", o
				hash:   (o) -> $($.hash(i) for i in x).sum()
				array:  $.identity
				string: (o) -> "{nodelist:"+$(o).select('nodeName').join(",")+"}"
				node:   (o) -> $(o).toFragment()
			$.type.register "node",
				match:  (o) -> o?.nodeType > 0
				hash:   (o) -> $.checksum(o.nodeName) + $.hash(o.attributes) + $.checksum(o.innerHTML)
				string: (o) -> o.toString()
				node:   $.identity
			$.type.register "fragment",
				match:  (o) -> o?.nodeType is 11
				hash:   (o) -> $($.hash(x) for x in o.childNodes).sum()
				string: (o) -> o.toString()
				node:   $.identity
			$.type.register "html",
				match:  (o) -> typeof o is "string" and (s=o.trimLeft())[0] == "<" and s[s.length-1] == ">"
				node:   (o) -> $.type.lookup(h = Bling.HTML.parse(o)).node(h)
				array:  (o,c) -> $.type.lookup(h = Bling.HTML.parse(o)).array(h,c)
			$.type.extend
				unknown:  { node: -> null }
				bling:    { node: (o) -> o.toFragment() }
				string:
					node:  (o) -> $(o).toFragment()
					array: (o,c) -> c.querySelectorAll?(o)
				function: { node: (o) -> $(o.toString()).toFragment() }

			toFrag = (a) ->
				if not a.parentNode?
					df = document.createDocumentFragment()
					df.appendChild(a)
				a
			before = (a,b) -> toFrag(a).parentNode.insertBefore b, a
			after = (a,b) -> toFrag(a).parentNode.insertBefore b, a.nextSibling
			toNode = (x) -> $.type.lookup(x).node(x)
			escaper = null

			# window.getComputedStyle is not a normal function
			# (it doesnt support .call() so we can't use it with .map())
			# so define something that does work properly for use in .css
			computeCSSProperty = (k) -> -> window.getComputedStyle(@, null).getPropertyValue(k)

			getOrSetRect = (p) -> (x) -> if x? then @css(p, x) else @rect().select(p)

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
							switch $.type n
								when "string","html" then n
								when "node","fragment"
									d = document.createElement "div"
									d.appendChild (n = n.cloneNode true)
									# Uses .innerHTML to render the HTML.
									ret = d.innerHTML
									d.removeChild n # break links to prevent leaks
									ret
								else "HTML.stringify of unknown type: " + $.type(n)
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
					return switch $.type h
						when "undefined","null" then @select 'innerHTML'
						when "string" then @zap 'innerHTML', h
						when "bling" then @html h.toFragment()
						when "node"
							@each -> # replace all our children with the new child
								@replaceChild @childNodes[0], h
								while @childNodes.length > 1
									@removeChild @childNodes[1]

				append: (x) -> # .append(/n/) - insert /n/ [or a clone] as the last child of each node
					x = toNode(x) # parse, cast, do whatever it takes to get a Node or Fragment
					@each -> @appendChild x.cloneNode true

				appendTo: (x) -> # .appendTo(/n/) - each node [or fragment] will become the last child of x
					clones = @map( -> @cloneNode true)
					i = 0
					$(x).each -> @appendChild clones[i++]
					clones

				prepend: (x) -> # .prepend(/n/) - insert n [or a clone] as the first child of each node
					if x?
						x = toNode(x)
						@take(1).each ->
							before @childNodes[0], x
						@skip(1).each ->
							before @childNodes[0], x.cloneNode(true)
					@

				prependTo: (x) -> # .prependTo(/n/) - each node [or a fragment] will become the first child of x
					if x?
						$(x).prepend(@)
					@

				before: (x) -> # .before(/x/) - insert content x before each node
					if x?
						x = toNode(x)
						@take(1).each -> before @, x
						@skip(1).each -> before @, x.cloneNode(true)
					@

				after: (x) -> # .after(/n/) - insert content n after each node
					if x?
						x = toNode(x)
						@take(1).each -> after @, x
						@skip(1).each -> after @, x.cloneNode(true)
					@

				wrap: (parent) -> # .wrap(/p/) - p becomes the new .parentNode of each node
					# all items of @ will become children of parent
					# parent will take each child's position in the DOM
					parent = toNode(parent)
					if $.is("fragment", parent)
						throw new Error("cannot wrap with a fragment")
					@each (child) ->
						switch $.type(child)
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
					n = toNode(n)
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
					k = "data-#{$.dashize(k)}"
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
						filter = $.not $.isEmpty
						if( cls.indexOf(x) > -1 )
							filter = $.and notx, filter
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
					if v? or $.is "object", k
						# Use a bound-method to do the assignment for us.
						setter = @select 'style.setProperty'
						# If you give an object as a key, then use every k:v pair.
						if $.is "object", k then setter.call i, k[i], "" for i of k
						# So, the key is simple, and if the value is a string,
						# just do simple assignment (using setProperty).
						else if $.is "string", v then setter.call k, v, ""
						# If the value was actually an array of values, then
						# stripe the values across each item.
						else if $.is "array", v
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
					if $.is "string", k
						if $.is "string", v
							style += "#{sel} { #{k}: #{v} } "
						else throw Error("defaultCss requires a value with a string key")
					else if $.is "object", k
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
						when not top? then @css("left", $.px(left))
						# If called with both arguments, set "top" and "left".
						else @css({top: $.px(top), left: $.px(left)})

				# Adjust the document's scroll position so the first node in
				# _this_ is centered in the viewport.
				scrollToCenter: ->
					document.body.scrollTop = @[0].offsetTop - (window.innerHeight / 2)
					@

				# Get the _n-th_ child from each node in _this_.
				child: (n) -> @select('childNodes').map -> @[ if n < 0 then (n+@length) else n ]

				parents: -> @map -> p = @; $( p while p = p?.parentNode ) # .parents() - collects the full ancestry up to the owner

				prev: -> @map -> p = @; $( p while p = p?.previousSibling ) # .prev() - collects the chain of .previousSibling nodes

				next: -> @map -> p = @; $( p while p = p?.nextSibling ) # .next() - collect the chain of .nextSibling nodes

				remove: -> @each -> @parentNode?.removeChild(@) # .remove() - removes each node in _this_ from the DOM

				find: (css) -> # .find(/css/) - collect nodes matching /css/
					@filter("*") # limit to only DOM nodes
						.map( -> $(css, @) )
						.flatten()

				clone: (deep=true) -> @map -> (@cloneNode deep) if $.is "node", @ # .clone(deep=true) - copies a set of DOM nodes

				toFragment: ->
					if @length > 1
						df = document.createDocumentFragment()
						@map(toNode).map $.bound df, df.appendChild
						return df
					return toNode(@[0])
			}

	# Transform plugin
	# ----------------
	# For accelerated animations.
	$.plugin
		depends: "dom"
	, ->
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
				# $.duration(/s/) - given a speed description (string|number), return a number in milliseconds
				duration: (speed) ->
					d = speeds[speed]
					return d if d?
					return parseFloat speed

			# .transform(css, [/speed/], [/callback/]) - animate css properties on each node
			transform: (end_css, speed, easing, callback) ->
				# animate css properties over a duration
				# accelerated: scale, translate, rotate, scale3d,
				# ... translateX, translateY, translateZ, translate3d,
				# ... rotateX, rotateY, rotateZ, rotate3d
				# easing values (strings): ease | linear | ease-in | ease-out
				# | ease-in-out | step-start | step-end | steps(number[, start | end ])
				# | cubic-bezier(number, number, number, number)

				if $.is("function",speed)
					callback = speed
					speed = easing = null
				else if $.is("function",easing)
					callback = easing
					easing = null
				speed ?= "normal"
				easing or= "ease"
				# duration is always in milliseconds
				duration = $.duration(speed) + "ms"
				props = []
				# `trans` is what will be assigned to -webkit-transform
				trans = ""
				# real css values to be set (end_css without the transform values)
				css = {}
				for i of end_css
					# pull all the accelerated values out of end_css
					if accel_props_re.test(i)
						ii = end_css[i]
						if ii.join
							ii = $(ii).px().join COMMASEP
						else if ii.toString
							ii = ii.toString()
						trans += " " + i + "(" + ii + ")"
					# stick real css values in the css dict
					else css[i] = end_css[i]
				# make a list of the properties to be modified
				(props.push i) for i of css
				# and include -webkit-transform if we have transform values to set
				if trans
					props.push transformProperty

				# sets a list of properties to apply a duration to
				css[transitionProperty] = props.join COMMASEP
				# apply the same duration to each property
				css[transitionDuration] = props.map(-> duration).join COMMASEP
				# apply an easing function to each property
				css[transitionTiming] = props.map(-> easing).join COMMASEP

				# apply the transformation
				if trans
					css[transformProperty] = trans
				# apply the css to the actual node
				@css css
				# queue the callback to be executed at the end of the animation
				# WARNING: NOT EXACT!
				@delay duration, callback

			hide: (callback) -> # .hide() - each node gets display:none
				@each ->
					if @style
						@_display = "" # stash the old display
						if @style.display is not "none"
							@_display = @syle.display
						@style.display = "none"
				.trigger("hide")
				.delay updateDelay, callback

			show: (callback) -> # .show() - show each node
				@each ->
					if @style
						@style.display = @_display
						delete @_display
				.trigger("show")
				.delay updateDelay, callback

			toggle: (callback) -> # .toggle() - show each hidden node, hide each visible one
				@weave(@css("display"))
					.fold (display, node) ->
						if display is "none"
							node.style.display = node._display or ""
							delete node._display
							$(node).trigger "show"
						else
							node._display = display
							node.style.display = "none"
							$(node).trigger "hide"
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
			fadeLeft: (speed, callback) -> @fadeOut speed, callback, "-"+@width().first(), 0.0
			fadeRight: (speed, callback) -> @fadeOut speed, callback, @width().first(), 0.0
			fadeUp: (speed, callback) -> @fadeOut speed, callback, 0.0, "-"+@height().first()
			fadeDown: (speed, callback)  -> @fadeOut speed, callback, 0.0, @height().first()
		}

	# HTTP Plugin
	# -----------
	# Things like `.ajax()`, `.get()`, `$.post()`.
	$.plugin
		depends: "dom"
	, ->
		formencode = (obj) -> # create &foo=bar strings from object properties
			o = JSON.parse(JSON.stringify(obj)) # quickly remove all non-stringable items
			("#{i}=#{escape o[i]}" for i of o).join "&"

		$.type.register "http",
			match: (o) -> $.isType 'XMLHttpRequest', o
			array: (o) -> [o]

		return {
			$:
				# $.http(/url/, [/opts/]) - fetch /url/ using HTTP (method in /opts/)
				http: (url, opts = {}) ->
					xhr = new XMLHttpRequest()
					if $.is("function",opts)
						opts = success: $.bound(xhr, opts)
					opts = $.extend {
						method: "GET"
						data: null
						state: $.identity # onreadystatechange
						success: $.identity # onload
						error: $.identity # onerror
						async: true
						asBlob: false
						timeout: 0 # milliseconds, 0 is forever
						followRedirects: false
						withCredentials: false
					}, opts
					opts.state = $.bound(xhr, opts.state)
					opts.success = $.bound(xhr, opts.success)
					opts.error = $.bound(xhr, opts.error)
					if opts.data and opts.method is "GET"
						url += "?" + formencode(opts.data)
					else if opts.data and opts.method is "POST"
						opts.data = formencode(opts.data)
					xhr.open(opts.method, url, opts.async)
					xhr = $.extend xhr,
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

				# $.post(/url/, [/opts/]) - fetch /url/ with a POST request
				post: (url, opts = {}) ->
					if $.is("function",opts)
						opts = success: opts
					opts.method = "POST"
					$.http(url, opts)

				# $.get(/url/, [/opts/]) - fetch /url/ with a GET request
				get: (url, opts = {}) ->
					if( $.is("function",opts) )
						opts = success: opts
					opts.method = "GET"
					$.http(url, opts)
		}

	# Events plugin
	# -------------
	# Things like `.bind()`, `.trigger()`, etc.
	$.plugin
		depends: "dom,function,core"
		provides: "event"
	, ->
		EVENTSEP_RE = /,* +/
		events = ['mousemove','mousedown','mouseup','mouseover','mouseout','blur','focus',
			'load','unload','reset','submit','keyup','keydown','change',
			'abort','cut','copy','paste','selection','drag','drop','orientationchange',
			'touchstart','touchmove','touchend','touchcancel',
			'gesturestart','gestureend','gesturecancel',
			'hashchange'
		] # 'click' is handled specially

		binder = (e) -> (f) -> @bind(e, f) if $.is "function", f else @trigger(e, f)

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
		triggerReady = $.once ->
			$(document).trigger("ready").unbind("ready")
			document.removeEventListener?("DOMContentLoaded", triggerReady, false)
			window.removeEventListener?("load", triggerReady, false)
		bindReady = $.once ->
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
				args = $.extend
					bubbles: true
					cancelable: true
				, args

				for evt_i in (evt or "").split(EVENTSEP_RE)
					if evt_i in ["click", "mousemove", "mousedown", "mouseup", "mouseover", "mouseout"] # mouse events
						e = document.createEvent "MouseEvents"
						args = $.extend
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
						, args
						e.initMouseEvent evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
							args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.button, args.relatedTarget

					else if evt_i in ["blur", "focus", "reset", "submit", "abort", "change", "load", "unload"] # UI events
						e = document.createEvent "UIEvents"
						e.initUIEvent evt_i, args.bubbles, args.cancelable, window, 1

					else if evt_i in ["touchstart", "touchmove", "touchend", "touchcancel"] # touch events
						e = document.createEvent "TouchEvents"
						args = $.extend
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
						, args
						e.initTouchEvent(evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
							args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.touches, args.targetTouches, args.changedTouches, args.scale, args.rotation)

					else if evt_i in ["gesturestart", "gestureend", "gesturecancel"] # gesture events
						e = document.createEvent "GestureEvents"
						args = $.extend {
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
							e = $.extend e, args
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
				if $.is "function", f then @bind 'click', f
				else @trigger 'click', f

			ready: (f) ->
				return (f.call @) if triggerReady.n <= 0
				@bind "ready", f
		}

		# add event binding/triggering shortcuts for the generic events
		events.forEach (x) -> ret[x] = binder(x)
		return ret

	$.plugin
		depends: "dom"
		provides: "lazy"
	, ->
		lazy_load = (elementName, props) ->
			$("head").append $.extend document.createElement(elementName), props
		$:
			script: (src) ->
				lazy_load "script", { src: src }
			style: (src) ->
				lazy_load "link", { href: src, rel: "stylesheet" }


)(Bling, @)
# vim: ft=coffee sw=2 ts=2
