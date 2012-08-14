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


# A shim for `Object.keys`.
Object.keys ?= (o) -> (k for k of o)

# A shim for `Object.values`.
Object.values ?= (o) -> (o[k] for k of o)

# A way to assign properties from `b` to `a`.
extend = (a, b) ->
	if b then a[k] = v for k,v of b when v?
	a

# A wrapper for Object.defineProperty that changes the defaults.
defineProperty = (o,name,opts) ->
	Object.defineProperty o,name, extend({
		configurable: true
		enumerable: true
	}, opts)
	o

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
		parent = parent.prototype
	if parent.__proto__ is Object.prototype
		parent.__proto__ = obj.__proto__
	obj.__proto__ = parent
	obj

# Now, let's begin to build the classifier for `$.type(obj)`.
_type = do ->

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
		cache[name][name] = (o) -> o

	# Later, plugins can `extend` previously registered types with new
	# functionality.
	_extend = (name, data) ->
		# The `name` should be of a registered type (a key into the cache)
		if typeof name is "string"
			# But, if you attempt to extend a type that was not registered yet,
			# it will be automatically registered.
			cache[name] ?= register name, {}
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
	register "number",    match: -> (isType Number, @) and @ isnt NaN
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
		as: (t, o, rest...) -> lookup(o)[t]?(o, rest...)

	# Example: Calling $.type directly will get you the simple name of the
	# best match.
	# > `type([]) == "array"`

	# If you want to know everything, you can use lookup
	# directly.
	# > `type.lookup([]).name == "array"`

	# Later, once other systems have extended the base type, the
	# type-instance returned from type.lookup will do more.

_pipe = do ->
	# Pipes are one way to make extensible code that I am playing with.
	# Each pipe is a named list of methods. You can add new
	# methods to either end. To execute the whole pipe you call it
	# with an array of arguments.

	# Add a method to a pipe:
	# > `$.pipe("amplify").append (x) -> x+1`

	# The output of each function becomes the input of the next function
	# in the pipe.
	# > `$.pipe("amplify").append (x) -> x*2`

	# Invoking a pipe with arguments will call all the functions and
	# return the final value.
	# > `$.pipe("amplify", 10) == 22`

	pipes = {}

	(name, args) ->
		p = (pipes[name] or= [])
		if not args
			return {
				prepend: (obj) -> p.unshift(obj); obj
				append: (obj) -> p.push(obj); obj
			}
		for func in p
			args = func.call @, args
		args

# The Bling Constructor
# =====================
# This is using coffee's class syntax, but only as a hack really.

# First, we want the Bling function to have a name so that
# `$().constructor.name == "Bling"`, for sanity, and for easily
# detecting a mixed-jQuery environment (we do try to play nice).

# Second, the `new` operator is not great.  What it does normally is
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

	# Compute the default context object only once, privately, so we dont have to check
	# during every construction.
	default_context = if document? then document else {}

	constructor: (selector, context = default_context) ->
		return Bling.pipe "bling-init", [selector, context]

	@pipe: _pipe

	# Create the very first pipe used by the constructor: "bling-init".
	# This first piece of the pipe converts [selector, context] -> object;
	# and should always be in the _middle_ (if you `prepend` onto the
	# beginning of this pipe you should accept and return [selector, context].
	# If you `append` onto the end, you should accept and return a bling object.
	@pipe("bling-init").prepend (args) ->
		[selector, context] = args
		# Classify the type of selector to get a type-instance, which is
		# used to convert the selector and context together to an array.
		inherit Bling, inherit {
			selector: selector
			context: context
		}, _type.lookup(selector).array(selector, context)
		# Note: Uses inherit to _hijack_ the resulting array's prototype in-place.

	# $.plugin( [ opts ], func )
	# -----------------
	# Each plugin function should return an object full of stuff to
	# extend the Bling prototype with.

	# Example: the simplest possible plugin.
	# > $.plugin -> echo: -> @

	# This defines: `$(...).echo()`.  Also, this will
	# create a 'root' version if one doesnt exist: `$.echo`.

	# You can explicitly define root-level values by nesting things
	# under a `$` key:
	# > $.plugin () -> $: hello: -> "Hello!"

	# This will create `$.hello`, but not `$().hello`.
	@plugin: (opts, constructor) ->
		if not constructor?
			constructor = opts; opts = {}

		# Support a { depends: } option as a shortcut for `$.depends`.
		if "depends" of opts
			return @depends opts.depends, =>
				# Pass along any { provides: } options to the deferred call.
				@plugin { provides: opts.provides }, constructor
		try
			# We call the plugin constructor and expect that it returns an
			# object full of things to extend either Bling or it's prototype.
			if (plugin = constructor?.call @,@)
				# If the plugin has a `$` key, extend the root.
				extend @, plugin?.$
				# Clean off keys we no longer care about: `$` and `name`. (An
				# older version of plugin() used to require names,
				# but we ignore them now in favor of depends/provides.
				['$','name'].forEach (k) -> delete plugin[k]
				# Now put everything else on the Bling prototype.
				extend @::, plugin
				# Finally, add root-level wrappers for anything that doesn't
				# have one already.
				for key of plugin then do (key) =>
					@[key] or= (a...) => (@::[key].apply $(a[0]), a[1...])
				# Support a { provides: } option as a shortcut for
				# `$.provides`.
				if opts.provides? then @provide opts.provides
		catch error
			console.log "failed to load plugin: #{@name} #{error.message}: #{error.stack}"
		@

	# Code dependencies
	# -----------------
	# $.depends, $.provide and $.provides, allow for representing
	# dependencies between any functions. Plugins can and should use this
	# to ensure their correct loading order.
	dep = # private stuff for depends/provides system.
		q: []
		done: {}
		filter: (n) ->
			(if (typeof n) is "string" then n.split /, */ else n)
			.filter (x) -> not (x of dep.done)

	# Example: `$.depends "tag", -> $.log "hello"`
	# This example will not log "hello" until `provide("tag")` is
	# called.
	@depends: (needs, f) ->
		if (needs = dep.filter needs).length is 0 then f()
		else dep.q.push (need) ->
			(needs.splice i, 1) if (i = needs.indexOf need) > -1
			return (needs.length is 0 and f)
		f

	@provide: (needs, data) ->
		for need in dep.filter needs
			dep.done[need] = i = 0
			while i < dep.q.length
				if (f = dep.q[i] need)
					dep.q.splice i,1
					f data
				else i++
		data

	@provides: (needs, f) ->
		(args...) ->
			Bling.provide needs, f args...

	#### Extending the type system
	# First, we give the basic types the ability to turn into something
	# array-like, for use by the constructor pipeline.
	_type.extend
		# If we don't know any better way, we just stick the
		# thing inside a real array.
		unknown:   { array: (o) -> [o] }
		# But where we do know better, we can provide more meaningful
		# conversions. Later, in the DOM plugin, we will extend
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
	_type.register "bling",
		# Add the type test so: `$.type($()) == "bling"`.
		match:  (o) -> o and isType Bling, o
		# Blings extend arrays so they convert to themselves.
		array:  (o) -> o.toArray()
		# Their hash is just the sum of member hashes (order matters).
		hash:   (o) ->
			o.map(Bling.hash).reduce (a,x) -> (a*a)+x
		# They have a very literal string representation.
		string: (o) -> Bling.symbol + "([" + o.map((x) -> $.type.lookup(x).string(x)).join(", ") + "])"
		repr: (o) -> Bling.symbol + "([" + o.map((x) -> $.type.lookup(x).repr(x)).join(", ") + "])"

# We specify an inheritance similar to `class Bling extends (new Array)`,
# if such a thing were supported by the syntax directly.
Bling.prototype = []
Bling.prototype.constructor = Bling

# Plugins
# =======
# Now that we have a way to load plugins and express dependencies
# between them, all future code will come in a plugin.
#
# For the rest of this file, set up a namespace that protects `$`,
# so we can safely use short-hand in all of our plugins.
do ($ = Bling) ->

	# Grab a safe reference to the global object
	$.global = glob = if window? then window else global

	# Types plugin
	# ------------
	# Exposes the type system publicly.
	$.plugin
		provides: "type"
	, ->
		$:
			# __$.inherit(parent, child)__ makes _parent_ become the
			# immediate *__proto__* of _child_.
			inherit: inherit
			# __$.extend(a,b)__ assigns properties from `b` onto `a`.
			extend: extend
			# __$.defineProperty(obj, name, opts)__ is like the native Object.defineProperty
			# except with defaults that make the new properties 'public'.
			defineProperty: defineProperty
			# __$.isType(Array, [])__ is lower level than the others,
			# doing simple comparison between constructors along the
			# prototype chain.
			isType: isType
			# `$.type([])` equals `"array"`.
			type: _type
			# `$.is("function", ->)` equals true/false.
			is: _type.is
			as: _type.as
			isSimple: (o) -> _type(o) in ["string", "number", "bool"]
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
		depends: "type"
	, ->
		# The current symbol.
		symbol = null
		# Allocate some space to remember clobbered symbols.
		cache = {}
		# Export the global 'Bling' symbol.
		glob.Bling = Bling
		if module?
			module.exports = Bling
		# Define $.symbol as a dynamic property.
		defineProperty $, "symbol",
			set: (v) ->
				# When you assign to $.symbol, it _moves_ the current
				# shortcut for Bling, preserving previous values.
				glob[symbol] = cache[symbol]
				cache[symbol = v] = glob[v]
				glob[v] = Bling
			get: -> symbol
		return $:
			symbol: "$"
			noConflict: ->
				Bling.symbol = "Bling"
				return Bling
		# Example:
		# > `Bling.symbol = "_"; _("body").html("Hello World");`
		# If `$` had been bound before, it's value will be restored.

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
			# If cloneNode does not take a 'deep' argument, add support.
			if Element::cloneNode.length is 0
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
	$.plugin
		provides: "core"
		depends: "string"
	, ->

		defineProperty $, "now",
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
			or: (x) -> @[i] or= x for i in [0...@length]; @

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

			# Remove a property from each item.
			clean: (prop) -> @each -> delete @[prop]

			# Get a new set with only the first _n_ items from _this_.
			take: (n = 1) ->
				end = Math.min n, @length
				$( @[i] for i in [0...end] )

			# Get a new set with every item except the first _n_ items.
			skip: (n = 0) ->
				start = Math.max 0, n|0
				$( @[i] for i in [start...@length] )

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
				# $( Array::filter.call @, g )
				$( it for it in @ when g.call(it,it) )

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
					$.log(label, @toString(), @length + " items")
				else
					$.log(@toString(), @length + " items")
				@

			# Convert this to an array.
			toArray: ->
				@__proto__ = Array::
				@ # no copies, yay?
		}

	# Math Plugin
	# -----------
	# All the stuff you need to use blings as vectors in linear algebra.
	$.plugin
		provides: "math"
		depends: "core"
	, ->
		$.type.extend
			bool: { number: (o) -> if o then 1 else 0 }
			number: { bool: (o) -> not not o }

		$:
			# Get an array of sequential numbers.
			range: (start, end, step = 1) ->
				if not end? then (end = start; start = 0)
				step *= -1 if end < start and step > 0 # force step to have the same sign as start->end
				$( (start + (i*step)) for i in [0...Math.ceil( (end - start) / step )] )
			# Get an array of zeros.
			zeros: (n) -> $( 0 for i in [0...n] )
			# Get an array of ones.
			ones: (n) -> $( 1 for i in [0...n] )
		# Convert everything to a float.
		floats: -> @map parseFloat
		# Convert everything to an int.
		ints: -> @map -> parseInt @, 10
		# Convert everything to a "px" string.
		px: (delta) -> @ints().map -> $.px @,delta
		# Get the smallest element (defined by Math.min)
		min: -> @filter( isFinite ).reduce Math.min
		# Get the largest element (defined by Math.max)
		max: -> @filter( isFinite ).reduce Math.max
		# Get the mean (average) of the set.
		mean: -> @sum() / @length
		avg: -> @sum() / @length
		# Get the sum of the set.
		sum: -> @filter( isFinite ).reduce(((a) -> a + @), 0)
		# Get the product of all items in the set.
		product: -> @filter( isFinite ).reduce (a) -> a * @
		# Get a new set with every item squared.
		squares: -> @map -> @ * @
		# Get the magnitude (vector length) of this set.
		magnitude: -> Math.sqrt @floats().squares().sum()
		# Get a new set, scaled by a real factor.
		scale: (r) -> @map -> r * @
		# Add this to d, get a new set.
		add: (d) -> switch $.type(d)
			when "number" then @map -> d + @
			when "bling","array" then $( @[i]+d[i] for i in [0...Math.min(@length,d.length)] )
		# Get a new vector with same direction, but magnitude equal to 1.
		normalize: -> @scale(1/@magnitude())

	# String Plugin
	# -------------
	# Filling out the standard library of string functions.
	$.plugin
		provides: "string"
		depends: "function"
	, ->
		safer = (f) ->
			(a...) ->
				try return f(a...)
				catch err then return "[Error: #{err.message}]"
		$.type.extend
			# First, extend the base type with a default `string` function
			unknown:
				string: safer (o) -> o.toString?() ? String(o)
				repr: safer (o) -> $.type.lookup(o).string(o)
				number: safer (o) -> parseFloat String o
			# Now, for each basic type, provide a basic `string` function.
			# Later, more complex types will be added by plugins.
			null: { string: -> "null" }
			undefined: { string: -> "undefined" }
			string:
				number: safer parseFloat
				repr:   (s) -> "'#{s}'"
			array:  { string: safer (a) -> "[" + ($.toString(x) for x in a).join(",") + "]" }
			object: { string: safer (o) ->
				ret = []
				for k of o
					try
						v = o[k]
					catch err
						v = "[Error: #{err.message}]"
					ret.push "#{k}:#{v}"
				"{" + ret.join(', ') + "}"
			}
			function:
				string: (f) -> f.toString().replace(/^([^{]*){(?:.|\n|\r)*}$/, '$1{ ... }')
			number:
				repr:   (n) -> String(n)
				string: safer (n) ->
					switch true
						when n.precision? then n.toPrecision(n.precision)
						when n.fixed? then n.toFixed(n.fixed)
						else String(n)

		# Return a bunch of root-level string functions.
		return {
			$:
				# __$.toString(x)__ returns a fairly verbose string, based on
				# the type system's "string" method.
				toString: (x) ->
					if not x? then "function Bling(selector, context) { [ ... ] }"
					else
						try
							$.type.lookup(x).string(x)
						catch err
							"[Error: #{err.message}]"

				# __$.toRepr(x)__ returns a a code-like view of an object, using the
				# type system's "repr" method.
				toRepr: (x) -> $.type.lookup(x).repr(x)

				# __$.px(x,[delta])__ computes a "px"-string ("20px"), `x` can
				# be a number or a "px"-string; if `delta` is present it will
				# be added to the number portion.
				px: (x, delta=0) -> x? and (parseInt(x,10)+(delta|0))+"px"
				# Example: Add 100px of width to an element.

				# jQuery style:
				# `nodes.each(function(){ $(this).css("width",($(this).css("width") + 100) + "px")})`

				# Bling style:
				# `nodes.zap 'style.width', -> $.px @, + 100`

				# Properly **Capitalize** Each Word In A String.
				capitalize: (name) -> (name.split(" ").map (x) -> x[0].toUpperCase() + x.substring(1).toLowerCase()).join(" ")

				# Convert a _camelCase_ name to a _dash-name_.
				dashize: (name) ->
					ret = ""
					for i in [0...(name?.length|0)]
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

				stringTruncate: (s, n, c = "...") ->
					s = s.split(' ')
					r = []
					while n > 0
						x = s.shift()
						n -= x.length
						if n >= 0
							r.push x
					r.join('') + c


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

				# __$.repeat(x, n)__ repeats x, n times.
				repeat: (x, n=2) ->
					switch true
						when n is 1 then x
						when n < 1 then ""
						when $.is "string", x then x + $.repeat(x, n-1)
						else $(x).extend $.repeat(x, n-1)

				# Return a string-builder, which uses arrays to defer all string
				# concatenation until you call `builder.toString()`.
				stringBuilder: ->
					if $.is("global", @) then return new $.stringBuilder()
					items = []
					@length   = 0
					@append   = (s) => items.push s; @length += s?.toString().length|0
					@prepend  = (s) => items.splice 0,0,s; @length += s?.toString().length|0
					@clear    = ( ) => ret = @toString(); items = []; @length = 0; ret
					@toString = ( ) => items.join("")
					@
			toString: -> $.toString @
			toRepr: -> $.toRepr @
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
				if $.is "function", f.bind
					args.splice 0, 0, t
					r = f.bind.apply f, args
				else
					r = (a...) -> f.apply t, (args if args.length else a)
				$.extend r, { toString: -> "bound-method of #{t}.#{f.name}" }
			# __$.memoize(f)__ returns a new function that caches function calls to f, based on hashing the arguments.
			memoize: (f) ->
				cache = {}
				(a...) -> cache[$.hash a] ?= f.apply @, a # BUG: skips cache if f returns null on purpose
			# __$.E(f)__ is an "error thingie". You use it to create a wrapper for standard node style callbacks:
			#    e = $.E (err) -> $.log err
			#    f.readFile "foo", e (data) ->
			E: (callback) -> (f) -> (err, data) ->
				return f(data) unless err
				callback err, data

	# Hash plugin
	# -----------
	# `$.hash(o)` Reduces any thing to an integer hash code (not secure).
	$.plugin
		provides: "hash"
		depends: "type"
	, ->
		$.type.extend
			unknown: { hash: (o) -> $.checksum $.toString o }
			object:  { hash: (o) ->
				$.hash(Object) +
					$($.hash(o[k]) for k of o).sum() +
					$.hash Object.keys o
			}
			array:   { hash: (o) ->
				$.hash(Array) + $(o.map $.hash).reduce (a,x) ->
					(a*a)+(x|0)
				, 1
			}
			bool:    { hash: (o) -> parseInt(1 if o) }
		return {
			$:
				hash: (x) -> $.type.lookup(x).hash(x)
			hash: -> $.hash @
		}

	# Publish/Subscribe plugin
	# -----------------
	# Publish messages to a named channel, those messages invoke each
	# function subscribed to that channel.
	$.plugin
		provides: "pubsub"
	, ->
		subscribers = {} # a mapping of channel name to a list of subscribers
		return {
			$:
				publish: (e, args...) ->
					f.apply null, args for f in (subscribers[e] or= [])
					args
				publisher: (e, func) ->
					(args...) ->
						func.apply @, args
						$.publish e, args
				subscribe: (e, func) ->
					(subscribers[e] or= []).push func
					func
				unsubscribe: (e, func) ->
					if not func?
						subscribers[e] = []
					else
						a = (subscribers[e] or= [])
						if (i = a.indexOf func)  > -1
							a.splice(i,i)
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
	# The EventEmitter interface that NodeJS uses is much simpler (and
	# faster) than the DOM event model.  With this plugin, every new
	# bling becomes an EventEmitter automatically, or you can mix it in
	# to any object: `$.EventEmitter(obj)`.
	$.plugin
		provides: "EventEmitter"
	, ->
		$: EventEmitter: $.pipe("bling-init").append (obj) ->
			listeners = {}
			list = (e) -> (listeners[e] or= [])
			inherit {
				emit:               (e, a...) -> (f.apply(@, a) for f in list(e)); @
				addListener:        (e, h) -> list(e).push(h); @emit('newListener', e, h)
				on:                 (e, h) -> @addListener e, h
				removeListener:     (e, h) -> (list(e).splice i, 1) if (i = list(e).indexOf h) > -1
				removeAllListeners: (e) -> listeners[e] = []
				setMaxListeners:    (n) -> # who really needs this in the core API?
				listeners:          (e) -> list(e).slice 0
			}, obj

# vim: ft=coffee sw=2 ts=2
