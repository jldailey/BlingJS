# Types plugin
# ------------
# Exposes the type system publicly.
$.plugin
	provides: "type,is,inherit,extend,defineProperty,isType,are,as,isSimple,isDefined,isEmpty"
	depends: "compat"
, ->
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
		else (o.constructor? and (o.constructor is T or o.constructor.name is T)) or
			Object::toString.apply(o) is "[object #{T}]" or
			isType T, o.__proto__ # recursive

	# `inherit(parent, child)` is similar to extend, except it works by
	# inserting the parent as the prototype of the child _instance_. This is unlike
	# coffee's `class X extends Y`, because it expects the target `child`
	# to be an _instance_, and the `parent` can either be an _instance_ or a
	# __constructor__.
	inherit = (parent, objs...) ->
		return unless objs.length > 0
		obj = objs.shift()
		if typeof parent is "function"
			parent = parent.prototype
		# if the parent isn't bringing it's own __proto__ chain
		if parent.__proto__ in [Object.prototype, null, undefined]
			# splice the new parent such that the original chain is preserved
			parent.__proto__ = obj.__proto__
		obj.__proto__ = parent
		if objs.length > 0
			return inherit obj, objs...
		else obj

	# Now, let's begin to build the classifier for `$.type(obj)`.
	_type = do ->

		# Privately, maintain a registry of known types.
		cache = {}

		# Each type in the registry is an instance that inherits from a
		# _base_ object.  Later, when we want to do more than `is` with
		# each type, we will extend this base with default implementations.
		base =
			name: 'unknown'
			is: -> true

		# When classifying an object, this array of names will control
		# the _order_ of the calls to `is` (and thus, the _type precedence_).
		order = []
		_with_cache = {} # for finding types that have a certain method { method: [ types ] }
		_with_insert = (method, type) ->
			a = (_with_cache[method] or= [])
			if (i = a.indexOf type) is -1
				a.push type


		# When adding a new type to the regisry:
		register = (name, data) ->
			unless 'is' of data
				throw new Error("$.type.register given a second argument without an 'is' function")
			# * Put the type check in order (if it isn't already).
			order.unshift name if not (name of cache)
			# * inherit from the base type and store in the cache.
			cache[data.name = name] = if (base isnt data) then (inherit base, data) else data
			# * Fill-in the identity conversion (from name to name).
			cache[name][name] = (o) -> o
			for key of cache[name]
				_with_insert key, cache[name]

		# Later, plugins can `extend` previously registered types with new
		# functionality.
		_extend = (name, data) ->
			# The `name` should be of a registered type (a key into the cache)
			if typeof name is "string"
				# But, if you attempt to extend a type that was not registered yet,
				# it will be automatically registered.
				cache[name] or= register name, {}
				cache[name] = extend cache[name], data
				for method of data
					_with_insert method, cache[name]
			# But you can also extend a bunch of types at once, by passing a
			# 2-level deep object, where the first level of keys are type
			# names and the second level of keys are objects full of
			# extensions.
			else if typeof name is "object"
				(_extend k, name[k]) for k of name

		# To classify an object, simply check every match in order.
		lookup = (obj) ->
			for name in order
				if cache[name]?.is.call obj, obj
					return cache[name]

		# Now, register all the built-in types. These checks are
		# executed in _reverse order_, so the first listed here, `"unknown"`,
		# is always checked last.
		register "unknown",   base
		# This implies that the 'simplest' checks should be registered
		# first, and conceptually more specialized checks would get added
		# as time goes on (so specialized type matches are preferred).
		register "object",    is: (o) -> typeof o is "object" and (o.constructor?.name in [undefined, "Object"])
		register "error",     is: (o) -> isType 'Error', o
		register "regexp",    is: (o) -> isType 'RegExp', o
		register "string",    is: (o) -> typeof o is "string" or isType String, o
		register "number",    is: (o) -> (isType Number, o) and not isNaN(o)
		register "bool",      is: (o) -> typeof o is "boolean" or try String(o) in ["true","false"]
		register "array",     is: Array.isArray or (o) -> isType Array, o
		register "buffer",    is: Buffer.isBuffer or -> false
		register "function",  is: (o) -> typeof o is "function"
		register "global",    is: (o) -> typeof o is "object" and 'setInterval' of @
		register "arguments", is: (o) -> try 'callee' of o and 'length' of o
		# These checks for null and undefined are small exceptions to the
		# simple-first idea, since they are precise and getting them out
		# of the way early lets the above tests omit a safety check.
		register "undefined", is: (x) -> x is undefined
		register "null",      is: (x) -> x is null

		# Now, we finally have all the pieces to make the real classifier.
		return extend ((o) -> lookup(o).name),
			register: register
			lookup: lookup
			extend: _extend
			get: (t) -> cache[t]
			is: (t, o) -> cache[t]?.is.call o, o
			as: (t, o, rest...) -> lookup(o)[t]?(o, rest...)
			# Find all types with a certain function available:
			# e.g. $.type.with('compact') == a list of all `compact`-able types
			with: (f) -> _with_cache[f] ? []

		# Example: Calling $.type directly will get you the simple name of the
		# best match.
		# > `type([]) == "array"`

		# If you want to know everything, you can use lookup
		# directly.
		# > `type.lookup([]).name == "array"`

		# Later, once other systems have extended the base type, the
		# type-instance returned from type.lookup will do more.

	# Extending the type system
	# First, we give the basic types the ability to turn into something
	# array-like, for use by the constructor hook.
	_type.extend
		# If we don't know any better way, we just stick the
		# thing inside a real array.
		unknown:   { array: (o) -> [o] }
		# But where we do know better, we can provide more meaningful
		# conversions. Later, in the DOM plugin, we will extend
		# this further to know how to convert "html", "node", etc.

		# Null and undefined values convert to an empty array.
		null:      { array:     -> [] }
		undefined: { array:     -> [] }
		# Arrays just convert to themselves.
		array:     { array: (o) -> o }
		# Numbers create a new array of that capacity (but zero length).
		number:    { array: (o) -> $.extend new Array(o), length: 0 }
		# Arguments get sliced into to a real array.
		arguments: { array: (o) -> Array::slice.apply o }

	# Now, we register "bling", and all the things we know how to do
	# with it:
	maxHash = Math.pow(2,32)
	_type.register "bling",
		# Add the type test so: `$.type($()) == "bling"`.
		is:     (o) -> o and isType $, o
		# Bling extends array so they can convert themselves.
		array:  (o) -> o.toArray()
		# Their hash is just the sum of member hashes (order matters).
		hash:   (o) -> o.map($.hash).reduce (a,x) -> ((a*a)+x) % maxHash
		# They have a very literal string representation.
		string: (o) -> $.symbol + "([" + o.map((x) -> $.type.lookup(x).string(x)).join(", ") + "])"
		repr:   (o) -> $.symbol + "([" + o.map((x) -> $.type.lookup(x).repr(x)).join(", ") + "])"

	$:
		# __$.inherit(parent, child)__ makes _parent_ become the
		# immediate *__proto__* of _child_.
		inherit: inherit
		# __$.extend(a,b)__ assigns properties from `b` onto `a`.
		extend: extend
		# __$.defineProperty(obj, name, opts)__ is like the native Object.defineProperty
		# except with defaults that make the new properties 'public'.
		defineProperty: (o, name, opts) ->
			Object.defineProperty o, name, extend({ configurable: true, enumerable: true }, opts)
			o
		# __$.isType(Array, [])__ is lower level than the others,
		# doing simple comparison between constructors along the
		# prototype chain.
		isType: isType
		# `$.type([])` equals `"array"`.
		type: _type
		# `$.is("function", ->)` equals true/false.
		is: _type.is
		# `$.are("function", (->), (->)) equals true/false.
		are: (type, args...) ->
			for a in args
				return false unless $.is type, a
			return true
		# `$.as("number", "1234")` attempt to convert types.
		as: _type.as
		isDefined: (o) -> o?
		isSimple: (o) -> _type(o) in ["string", "number", "bool"]
		isEmpty: (o) -> o in ["", null, undefined] \
			or o.length is 0 or (typeof o is "object" and Object.keys(o).length is 0)
	defineProperty: (name, opts) -> @each -> $.defineProperty @, name, opts
