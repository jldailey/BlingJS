###
 bling.js
# --------
# Named after the bling symbol ($) to which it is bound by default.
# This is a jQuery-like framework.
# Blame: Jesse Dailey <jesse.dailey@gmail.com>
###

# constants
commasep = ", "
commasep_re = /, */
space = " "
leftSpaces_re = /^\s+/
emptyString = ""
object_cruft = /\[object (\w+)\]/
_1 = "$1"
Math_min = Math.min
Math_max = Math.max
Math_ceil = Math.ceil
Math_sqrt = Math.sqrt
Obj_toString = Object::toString
_log = (console ? console.log : (a...) -> alert(a.join(", ")))
_none = "none"
_relative = "relative"
_absolute = "absolute"
_width = "width"
_height = "height"
_top = "top"
_left = "left"
_right = "right"
_bottom = "bottom"
_string = "string"
_number = "number"
_function = "function"
_object = "object"
_object_Array = "[object Array]"
_px = "px"
_dot = "."
_undefined = "undefined"
_null = "null"

Array::extend = (a) ->
	j = @length
	for i in a
		@[j++] = i
	@

### Bling, the "constructor".
# -----------------------
# Bling (selector, context):
# @param {(string|number|Array|NodeList|Node|Window)=} selector
#   accepts strings, as css expression to select, ("body div + p", etc.)
#     or as html to create (must start with "<")
#   accepts existing Bling
#   accepts arrays of anything
#   accepts a single number, used as the argument in new Array(n), to pre-allocate space
# @param {Object=} context the item to consider the root of the search when using a css expression
#
###
class Bling extends Array
	@symbol = "$"
	@plugins = []
	constructor: (selector, context = document) ->
		@selector = selector
		@context = context

		if @ is window
			return new Bling(selector, context)

		if selector?
			if Object.IsNode selector or selector is window
				@[0] = selector
			else if typeof selector is _string
				selector = String.TrimLeft(selector)
				if selector[0] is "<"
					@[0] = Bling.HTML.parse(selector)
				else if context.querySelectorAll
					@extend context.querySelectorAll selector
				else if Object.IsBling context
					# search every item in the context
					@extend context.reduce (a, x) ->
						a.extend(x.querySelectorAll?(selector))
					, []
				else throw Error "invalid context: #{context} (type: #{typeof context})"
			else if "length" of selector
				@extend selector
			else throw Error "invalid selector: #{selector} (type: #{typeof selector})"

window["$"] = window["Bling"] = $ = Bling

Object.Keys = (o, inherited) ->
	# Object.Keys(/o/, [/inherited/]) - get a list of key names
	# by default, does not include properties inherited from a prototype
	###
		Example:
		> Object.Keys({"a": 1, b: 2})
		> == ["a", "b"]
	###
	keys = []; j = 0
	for i of o
		if inherited or o.hasOwnProperty(i)
			keys[j++] = i
	keys

Object.Extend = (a, b, k) ->
	# Object.Extend(a, b, [k]) - merge values from b into a
	# if k is present, it should be a list of property names to copy
	if Obj_toString.apply(k) is _object_Array # cant use Object.IsArray yet
		for i of k
			a[k[i]] = b[k[i]] unless b[k[i]] is undefined
	else
		for i of (k = Object.Keys(b))
			a[k[i]] = b[k[i]]
	a

### Object Extensions
# ----------------- ###
Object.Extend Object, {
	IsType: (o,T)->
		# Object.IsType(o,T) - true if object o is of type T (directly or indirectly)
		o == null ? o is T
			: o.__proto__ == null ? false
			: o.__proto__.constructor is T ? true
			: typeof T is _string ? o.constructor.name is T or Obj_toString.apply(o).replace(object_cruft, _1) is T
			: Object.IsType o.__proto__, T # recurse through sub-classes
	,
	IsString: (o)->
		# Object.IsString(a) - true if object a is a string
		o? and (typeof o is _string or Object.IsType(o, String))
	,
	IsNumber: isFinite,
	IsFunc: (o)->
		# Object.IsFunc(a) - true if object a is a function
		o? and (typeof o is _function or Object.IsType(o, Function))
			and o.call?
	,
	IsNode: (o)->
		# Object.IsNode(o) - true if object is a DOM node
		o? and o.nodeType > 0
	,
	IsFragment: (o)->
		# Object.IsFragment(o) - true if object is a DocumentFragment node
		o? and o.nodeType is 11
	,
	IsArray: (o)->
		# Object.IsArray(o) - true if object is an Array (or inherits Array)
		o? and (Object.ToString(o) is _object_Array
			or Object.IsType(o, Array))
	,
	IsBling: (o)->
		o? and Object.IsType(o, Bling)
	,
	IsObject: (o)->
		# Object.IsObject(o) - true if a is an object
		o? and typeof o is _object
	,
	IsDefined: (o)->
		# Object.IsDefined(o) - true if a is not null nor undefined
		o?
	,
	Unbox: (a)->
		# Object.Unbox(o) - primitive types can be 'boxed' in an object
		if a? and Object.IsObject(a)
			a.toString() if Object.IsString a
			Number(a) if Object.IsNumber a
		a
	,
	ToString: (x)-> Obj_toString.apply(x)
}

### Function Extensions
# ------------------- ###
Object.Extend(Function, {
	# the empty function
	Empty: ()->,
	Bound: (f, t, args = []) ->
		# Function.Bound(/f/, /t/) - whenever /f/ is called, _this_ is /t/
		### Example:
		> var log = window.console ? Function.Bound(console.log, console)
		>		: Function.Empty
		> log("hello", "world")
		###
		if "bind" in f
			args.splice(0, 0, t)
			r = f.bind.apply(f, args)
		else
			r = (a...) -> f.apply(t, args.length > 0 ? args : a)
		r.toString = () -> "bound-method of #{t}.#{f.name}"
		r
	,
	### Function.Trace - function decorator console.logs a message to record each call
	* @param {Function} f the function to trace
	* @param {string=} label (optional)
	###
	Trace: (f, label, tracer = _log) ->
		# Function.Trace(/f/, /label/) - log calls to /f/
		### Example:
			> someFunction() -> }
			> someFunction = Function.Trace(someFunction)
		###
		r = (a...) ->
			tracer("#{label or emptyString}#{@name or @}.#{f.name}(", a, ")")
			f.apply(@, arguments)
		r.toString = f.toString
		tracer("Function.Trace: #{label or f.name} created.")
		r
	,
	NotNull: (x)-> x != null,
	IndexFound: (x)-> x > -1,
	ReduceAnd: (x)-> x and @,
	UpperLimit: (x)-> (y)-> Math_min(x, y),
	LowerLimit: (x)-> (y)-> Math_max(x, y),
	Px:  (d)-> ()-> Number.Px(@,d)
})

### Array Extensions
# ---------------- ###
Object.Extend Array, {
	Coalesce: (a...) ->
		# Array.Coalesce - returns the first non-null argument
		if Object.IsArray(a[0])
			Array.Coalesce a[0]...
		else
			for i in a
				i if i?
}

### Number Extensions
# ----------------- ###
Object.Extend Number, {
	Px: (x,d=0) ->
		# Px(/x/, /delta/=0) - convert a number-ish x to pixels
		x? and (parseInt(x,10)+(d|0))+_px
	,
	# mappable versions of max() and min()
	AtLeast: (x)-> (y)-> Math_max(parseFloat(y or 0), x),
	AtMost: (x)-> (y)-> Math_min(parseFloat(y or 0), x)
}

### String Extensions
# ----------------- ###
Object.Extend String, {
	PadLeft: (s, n, c = space) ->
		# String.PadLeft(string, width, fill=" ")
		while s.length < n
			s = c + s
		s
	,
	PadRight: (s, n, c = space) ->
		# String.PadRight(string, width, fill=" ")
		while s.length < n
			s = s + c
		s
	,
	Splice: (s, i, j, n) ->
		# String.Splice(string, start, end, n) - replace a substring with n
		nn = s.length
		end = j == null ? nn
			: j < 0 ? nn + j
			: j
		start = i == null ? 0
			: i < 0 ? nn + i
			: i
		s.substring(0,start) + n + s.substring(end)
}

### Event Extensions
# ---------------- ###
Object.Extend Event, {
	Cancel: (evt) ->
	 evt.stopPropagation()
	 evt.preventDefault()
	 evt.cancelBubble = true
	 evt.returnValue = false
	,
	Prevent: (evt) ->
	 evt.preventDefault()
	,
	Stop: (evt) ->
	 evt.stopPropagation()
	 evt.cancelBubble = true
}

### Compatibility
# ------------- ###
String::trimLeft = Array.Coalesce(
	String::trimLeft,
	() -> @replace(leftSpaces_re, emptyString)
)

String::split = Array.Coalesce(
	String::split,
	(sep) ->
		a = []
		n = 0
		i = 0
		while (j = @indexOf(sep,i)) > -1
			a[n++] = @substring(i+1,j+1)
			i = j + 1
		return a
	,
)

Array::join = Array.Coalesce(
	Array::join,
	(sep) ->
		n = @length
		return emptyString if n is 0
		s = @[n-1]
		while --n > 0
			s = @[n-1] + sep + s
		s
	,
)



# clean up support for Selectors
Element::matchesSelector = Array.Coalesce(
	Element::webkitMatchesSelector,
	Element::mozMatchesSelector,
	Element::matchesSelector
)

Element::toString = (precise = false) ->
	if not precise
		Element::toString.apply(@)
	else
		@nodeName.toLowerCase()
		+ ( @id ? "##{@id}" : emptyString )
		+ ( @className ? ".#{@className.split(" ").join(".")}" : emptyString)

### $.plugin adds a new plugin to the library.
# @param {Function} constructor the closure to execute to get a copy of the plugin
# The constructor should either a list of functions (none anonymous),
# or, an object whose key names will be used.
###
$.plugin = (constructor) ->
	plugin = constructor.call($, $) # execute the plugin
	load(name, func) ->
		if( name[0] is Bling.symbol )
			Bling[name.substr(1)] = func
		else
			Bling::[name] = func
	if Object.IsArray(plugin)
		for i in plugin
			load(i.name, i)
	else
		for i in Object.Keys(plugin, true)
			load(i, plugin[i])
	$.plugins.push(constructor.name)
	$.plugins[constructor.name] = plugin

$.plugin(Core() ->
	# Core - the functional basis for all other modules

	class TimeoutQueue extends Array
		# the basic problem with setTimeout happens when multiple handlers
		# are scheduled to fire 'near' each other, values of 'near' depend on
		# how busy the rest of your script is.  if the timer event handlers are
		# blocked by other processing they might not check for 'due' execution
		# over some arbitrary time period.  if multiple handlers were due to fire
		# during that period, then all of the due handlers will fire
		# in no particular order.  @ queue will re-order them so they
		# always fire in the order they were scheduled
		constructor: () ->
			@next = () => # next() consumes the next handler on the queue
				if @length > 0
					@shift()() # shift AND call
			@schedule = (f, n) => # schedule(f, n) sets f to run after n or more milliseconds
				if not Object.IsFunc(f)
					throw Error "function expected, got: #{typeof f}"
				nn = @length
				f.order = n + new Date().getTime()
				if nn is 0 or f.order > @[nn-1].order
					@[nn] = f
				else
					for i in [0...nn]
						if @[i].order > f.order
							@splice(i, 0, f)
							break
				setTimeout(@next, n)
	timeoutQueue = new TimeoutQueue()

	# used in .zip()
	_getter(p) ->
		() ->
			v = @[p]
			Object.IsFunc(v) ? Function.Bound(v, @) : v
	# used in .zip()
	_zipper(p) ->
		i = p.indexOf(_dot)
		# split and recurse ?
		i > -1 ? @zip(p.substr(0, i)).zip(p.substr(i+1))
			# or map a getter across the values
			: @map _getter(p)

	return {

		eq: (i) ->
			# .eq(/i/) - a new set containing only the /i/th item
			$([@[i]])
		,

		each: (f) ->
			# .each(/f/) - apply function /f/ to every item /x/ in _this_.
			for i in @
				f.call(i, i)
			@
			### Example:
				> $("input[type=text]").each(() -> @value = "HI!")
			###
		,

		map: (f) ->
			# .map(/f/) - collect /f/.call(/x/, /x/) for every item /x/ in _this_.
			a = $()
			a.context = @
			a.selector = f
			nn = @len()
			for i in [0...nn]
				t = @[i]
				try
					a[i] = f.call(t, t)
				catch( err )
					a[i] = err
			a
			### Example:
				> $([1, 2, 3]).map(() -> @ * 2 )
				> == $([2, 4, 6])
			###
		,

		reduce: (f, init) ->
			# .reduce(/f/, [/init/]) - accumulate a = /f/(a, /x/) for /x/ in _this_.
			# along with respecting the context, we pass only the accumulation and one argument
			# so you can use functions like Math.min directly $([1,2,3]).reduce(Math.min)
			# @ fails with the ECMA reduce, since Math.min(a,x,i,items) is NaN
			a = init
			if not init?
				a = @[0]
				t = @skip(1)
			t.each () ->
				a = f.call(@, a, @)
			a
			### Example:

				Here, reduce is used to mimic sum.

				> $([12, 14, 9, 37])
				>		.reduce (a, x) ->	a + x
				> == 72

				But, you can accumulate anything easily, given an initial value.

				> $(["a", "a", "b"])
				>		.reduce (a, x) ->	a[x] = 1, { }
				> == {a: 1, b: 1}

				You can use any function that takes 2 arguments, including several useful built-ins.
				This is something you can't do with the native Array reduce.

				> $([12, 13, 9, 22]).reduce(Math.min)
				> == 9
			###
		,

		union: (other, strict) ->
			# .union(/other/) - collect all /x/ from _this_ and /y/ from _other_.
			# no duplicates, use concat if you want to preserve dupes
			ret = $()
			x = i = j = 0
			ret.context = [@, other]
			ret.selector = 'union'
			while x = @[j++]
				if not ret.contains(x, strict) # TODO: could speed this up by inlining contains
					ret[i++] = x
			j = 0
			while x = other[j++]
				if not ret.contains(x, strict)
					ret[i++] = x
			ret
			### Example:
				> $([1, 2, 3]).union([3, 4, 5])
				> == $([1, 2, 3, 4, 5])
			###
		,

		intersect: (other) ->
			# .intersect(/other/) - collect all /x/ that are in _this_ and _other_.
			ret = $()
			m = 0 # insert marker into ret
			n = @len()
			nn = (Object.IsFunc(other.len) ? other.len() : other.length),
			ret.context = [@, other]
			ret.selector = 'intersect'
			for i in [0...n]
				for j in [0...nn]
					if @[i] is other[j]
						ret[m++] = @[i]
						break
			ret
			### Example:
				> $([1, 2, 3]).intersect([3, 4, 5])
				> == $([3])
			###
		,

		distinct: (strict) ->
			# .distinct() - a copy of _this_ without duplicates.
			@union(@, strict)
			### Example:
				> $([1, 2, 1, 3]).distinct()
				> == $([1,2,3])
			###
		,

		contains: (item, strict) ->
			# .contains(/x/) - true if /x/ is in _this_, false otherwise.
			@count(item, strict) > 0
			### Example:
				> $("body").contains(document.body)
				> == true
			###
		,

		count: (item, strict) ->
			# .count(/x/) - returns how many times /x/ occurs in _this_.
			# since we want to be able to search for null values with .count(null)
			# but if you just call .count(), it returns the total length
			if item is undefined
				return @len()
			ret = 0
			@each (t) ->
				if (strict and t is item)
					|| (not strict and t == item)
					ret++
			ret
			### Example:
				> $("body").count(document.body)
				> == 1
			###
		,

		zip: (a...) ->
			# .zip([/p/, ...]) - collects /x/./p/ for all /x/ in _this_.
			# recursively split names like "foo.bar"
			# zip("foo.bar") == zip("foo").zip("bar")
			# you can pass multiple properties, e.g.
			# zip("foo", "bar") == [ {foo: x.foo, bar: x.bar}, ... ]
			n = a.length
			switch n
				when 1
					return _zipper.call(@, a[0])
				else # > 1
					# if more than one argument is passed, new objects
					# with only those properties, will be returned
					# like a "select" query in SQL
					master = {}
					b = $()
					nn = @len()
					# first collect a set of lists
					for i in [0...n]
						master[a[i]] = _zipper.call(@, a[i])
					# then convert to a list of sets
					for i in [0...nn]
						o = {}
						for k of master
							o[k] = master[k].shift() # the first property from each list
						b[j++] = o # as a new object in the results
					b
			### Example:
				> $(["foo","bar","bank"]).zip("length")
				> == $([3, 3, 4])

				You can use compound property names.

				> $("pre").first(3).zip("style.display")
				> == $(["block", "block", "block"])

				If you request many properties at once,
				you get back raw objects with only those properties.
				Similar to specifying columns on a SQL select query.

				> $("pre").first(1)
				>		.zip("style.display", "style.color")
				> == $([{'display':'block','color':'black'}])

				If the property value is a function,
				a bound-method is returned in its place.

				> $("pre").first(1)
				>		.zip("getAttribute")
				>		.toString()
				> == "$([bound-method of HTMLPreElement.getAttribute])"

				See: .call() for how to use a set of methods quickly.
			###
		,

		zap: (p, v) ->
			# .zap(p, v) - set /x/./p/ = /v/ for all /x/ in _this_.
			# just like zip, zap("a.b") == zip("a").zap("b")
			# but unlike zip, you cannot assign to many /p/ at once
			i = p.indexOf(_dot)
			i > -1 ?  # is /p/ a compound name like "foo.bar"?
			@zip(p.substr(0, i)) # if so, break off the front
				.zap(p.substr(i+1), v) # and recurse
			# accept /v/ as an array of values
			: Object.IsArray(v) ? @each (x) ->
				# re-use i as an index into the v array
				# i starts at -1 (since we didnt recurse)
				x[p] = v[++i] # so we increment first, ++i, to start at 0
			# accept a single value v, even if v is undefined
			: @each () -> @[p] = v
			### Example:
				Set a property on all nodes at once.
				> $("pre").zap("style.display", "none")
				Hides all pre's.

				You can pass compound properties.
				> $("pre").zap("style.display", "block")

				You can pass multiple values for one property.

				> $("pre").take(3).zap("style.display",
				>		["block", "inline", "block"])

			###
		,

		take: (n) ->
			# .take([/n/]) - collect the first /n/ elements of _this_.
			# if n >= @length, returns a shallow copy of the whole bling
			n = Math_min n|0, @len()
			a = $()
			a.context = @context
			a.selector = @selector
			for i in [0...n]
				a[i] = @[i]
			a
			### Example:
				> $("p").take(3).length == 3

				> $([1, 2, 3, 4, 5, 6]).take(2)
				> == $([1, 2])
			###
		,

		skip: (n) ->
			# .skip([/n/]) - collect all but the first /n/ elements of _this_.
			# if n == 0, returns a shallow copy of the whole bling
			n = Math_min(@len(), Math_max(0, (n|0)))
			nn = @len() - n
			a = $()
			a.context = @context
			a.selector = @selector
			for i in [0...nn]
				a[i] = @[i+n]
			a
			### Example:
				> $([1, 2, 3, 4, 5, 6]).skip(2)
				> == $([3, 4, 5, 6])
			###
		,

		first: (n = 1) ->
			# .first([/n/]) - collect the first [/n/] element[s] from _this_.
			# if n is not passed, returns just the item (no bling)
			@take(n)
			### Example:
				> $([1, 2, 3, 4]).first()
				> == 1

				> $([1, 2, 3, 4]).first(2)
				> == $([1, 2])

				> $([1, 2, 3, 4]).first(1)
				> == $([1])
			###
		,

		last: (n = 1) ->
			# .last([/n/]) - collect the last [/n/] elements from _this_.
			# if n is not passed, returns just the last item (no bling)
			@skip(@len() - n)
			### Example:
				> $([1, 2, 3, 4, 5]).last()
				> == 5

				> $([1, 2, 3, 4, 5]).last(2)
				> == $([4, 5])
			###
		,

		slice: (start, end) ->
			# .slice(/i/, [/j/]) - get a subset of _this_ including [/i/../j/-1]
			# the j-th item will not be included - slice(0,2) will contain items 0, and 1.
			# negative indices work like in python: -1 is the last item, -2 is second-to-last
			# undefined start or end become 0, or @length, respectively
			b = $(@[start...end])
			b.context = @
			b.selector = 'slice(#{start},#{end})'
			b
			### Example:
				> var a = $([1, 2, 3, 4, 5])
				> a.slice(0,1) == $([1])
				> a.slice(0,-1) == $([1, 2, 3, 4])
				> a.slice(0) == $([1, 2, 3, 4, 5])
				> a.slice(-2) == $([4, 5])
			###
		,

		concat: (b) ->
			# .concat(/b/) - insert all items from /b/ into _this_
			# note: unlike union, concat allows duplicates
			# note: also, does not create a new array, uses _this_ in-place
			i = @len() - 1
			j = -1
			n = (Object.IsFunc(b.len) ? b.len() : b.length)
			while j < n-1
				@[++i] = b[++j]
			@
			### Example:
				> $([1, 2, 3]).concat([3, 4, 5])
				> == $([1, 2, 3, 3, 4, 5])
			###
		,

		push: (b) ->
			# .push(/b/) - override Array.push to return _this_
			Array::push.call(@, b)
			@
		,

		filter: (f) ->
			# .filter(/f/) - collect all /x/ from _this_ where /x/./f/(/x/) is true
			# or if f is a selector string, collects nodes that match the selector
			# or if f is a RegExp, collect nodes where f.test(x) is true
			n = @len()
			b = $()
			b.context = @
			b.selector = f
			j = 0
			for i in [0...n]
				it = @[i]
				if Object.IsFunc(f) and f.call( it, it )
					or Object.IsString(f) and it.matchesSelector?(f)
					or Object.IsType(f, "RegExp") and f.test(it)
					b[j++] = it
			b
			### Example:
				> $([1,2,3,4,5]).filter () ->	@ % 2 == 0
				> == $([2,4,6])

				Or, you can filter by a selector.

				> $("pre").filter(".prettyprint")

				Or, you can filter by a RegExp.

				> $(["text", "test", "foo"].filter(/x/)
				> == $(["text"])

			###
		,

		test: (regex) ->
			# .test(/regex/) - collects regex.test(/x/) for /x/ in _this_
			###

				> $(["text", "test", "foo"]).test(/^t/)
				> == $([true, true, false])
			###
			@map () ->
				regex.test(@)
		,

		matches: (expr) ->
			# .matches(/css/) - collects /x/.matchesSelector(/css/)
			@zip('matchesSelector').call(expr)
			### Example:
				> $("pre").matches(".prettyprint")
				> $([true, false, false, true, etc...])
			###
		,

		weave: (b) ->
			# .weave(/b/) - interleave the items of _this_ and the set _b_
			# to produce: $([ ..., b[i], this[i], ... ])
			# note: the items of b come first
			# note: if b and this are different lengths, the shorter
			# will yield undefineds into the result
			# the result always has 2 * max(length) items
			n = b.len()
			nn = @len()
			c = $()
			i = nn - 1
			c.context = [@,b]
			c.selector = 'weave'
			# first spread out this, from back to front
			for i in [nn-1..0]
				c[(i*2)+1] = @[i]
			# then interleave the source items, from front to back
			for i in [0...n]
				c[i*2] = b[i]
			c
			### Example:
				> var a = $([0, 0, 0, 0])
				> var b = $([1, 1, 1, 1])
				> a.weave(b)
				> == $([1, 0, 1, 0, 1, 0, 1, 0])
			###
		,

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
			b.context = @
			b.selector = ['fold', f] 
			for i in [0...n-1] by 2
				b[j++] = f.call @, @[i], @[i+1]
			# if there is an odd man out, make one last call
			if (n%2) is 1
				b[j++] = f.call @, @[n-1], undefined
			b
			### Example:
				> $([1,2,3,4]).fold (x,y) -> x + y
				> == $([3, 7])
			###
		,

		flatten: () ->
			# .flatten() - collect the union of all sets in _this_
			b = $()
			n = @len()
			k = 0 # insert marker
			b.context = @
			b.selector = 'flatten'
			for i in [0...n]
				c = @[i]
				d = (Object.IsFunc(c.len) ? c.len() : c.length)
				for j in [0...d]
					b[k++] = c[j]
			b
			### Example:
				> $([[1,2], [3,4]]).flatten()
				> == $([1,2,3,4])
			###
		,

		call() ->
			# .call([/args/]) - collect /f/([/args/]) for /f/ in _this_
			@apply(null, arguments)
			### Example:
				> $("pre").zip("getAttribute").call("class")
				> == $([... x.getAttribute("class") for each ...])
			###
		,

		apply(context, args) ->
			# .apply(/context/, [/args/]) - collect /f/.apply(/context/,/args/) for /f/ in _this_
			@map () ->
				Object.IsFunc @
					? @apply(context, args)
					: @
			### Example:
				>	var a = {
				>		x: 1,
				>		getOne: () ->
				>			@x
				>		}
				>	}
				>	var b = {
				>		x: 2,
				>		getTwo: () ->
				>			@x
				>		}
				>	}
				> b.getTwo() == 2
				> a.getOne() == 1
				> $([a.getOne, b.getTwo]).apply(a)
				> == $([1, 1])

				This happens because both functions are called with 'a' as 'this', 
				since it is the context argument to .apply()

				(In other words, it happens because b.getTwo.apply(a) == 1, because a.x == 1)
			###

		,

		toString: () ->
			# .toString() - maps toString across @
			$.symbol
			+"(["
			+@map ()->
				switch @
					when undefined:
						_undefined
					when null:
						_null
					when window:
						"window"
					else
						@toString().replace(object_cruft,_1)
			.join(commasep)
			+"])"
			### Example:
				> $("body").toString()
				> == "$([HTMLBodyElement])"
			###
		,

		delay: (n, f) ->
			# .delay(/n/, /f/) -  continue with /f/ on _this_ after /n/ milliseconds
			if f
				timeoutQueue.schedule Function.Bound(f, @), n
			@
			### Example:
				> $("pre").delay(50, sometimeLater() ->
				> 	console.log(@length)
				> })
				> console.log($("pre").length)

				The same number will log twice, one 50 milliseconds or more after the other.

				See the comments in the source for the full explanation as to why delay() is more powerful than setTimeout on it's own.
			###
		,

		log: (label) ->
			# .log([label]) - console.log([/label/] + /x/) for /x/ in _this_
			len = @len()
			if( label ) _log(label, @, len + " items")
			else _log(@, len + " items")
			@
			### Example:
				$("a + pre").log("example")
				# logs, "example: [...nodes...] (N items)"
			###
		,

		len: () ->
			# .len() - returns the max defined index + 1
			# the .length of an array is more like capacity than length
			# @ counts backward or forward from .length, looking for valid items
			# returns the largest found index + 1
			i = @length
			# scan forward to the end
			while @[i] isnt undefined
				i++
			# scan back to the real end
			while i > -1 and @[i] is undefined
				i--
			return i+1
			### Example:
				If you create an empty array with spare capacity
				> var b = new Array(10)
				> b.length is 10
				But .length isnt where .push, .forEach, etc will operate.
				> b[0] is undefined
				> b.push("foo")
				> b[0] is "foo"
				.len() tells you where .push will insert and how many times .forEach will loop
				> $(b).len() is 1
				> b.length  is 10
			###

	}
})

$.plugin Html() ->

	# insert b before a
	_before = (a,b) ->
		a.parentNode.insertBefore(b, a)
	# insert b after a
	_after = (a,b) ->
		a.parentNode.insertBefore(b, a.nextSibling)
	# convert nearly anything to something node-like for use in the DOM
	toNode = (x) ->
		Object.IsNode(x)
			? x
			: Object.IsBling(x) ? x.toFragment()
			: Object.IsString(x) ? $(x).toFragment()
			: Object.IsFunc(x.toString) ? $(x.toString()).toFragment()
			: undefined

	Element::cloneNode =
		Element::cloneNode.length > 0
		? Element::cloneNode
		: (deep = false) ->
			n = @cloneNode()
			if deep
				for i in @childNodes
					n.appendChild i.cloneNode(true)
			n
	# make a #text node, for escapeHTML
	escaper = null

	getCSSProperty(k) ->
		# window.getComputeStyle is not a normal function
		# (it doesnt support .call() so we can't use it with .map())
		# so define something that does work right for use in .css
		() ->
			window.getComputedStyle(@, null).getPropertyValue(k)

	cssVendors = ['-webkit-', '-moz-', '-o-']

	setCSSProperty(node, k, v) ->
		node.style[k] = v

	return {
		$HTML:
			# $.HTML.* - HTML methods similar to the global JSON object
			parse: (h) ->
				# $.HTML.parse(/h/) - parse the html in string h, a Node.
				node = document.createElement("div")
				node.innerHTML = h
				childNodes = node.childNodes
				n = childNodes.length
				if n is 1
					return node.removeChild(childNodes[0])
				df = document.createDocumentFragment()
				for i in [0...n]
					df.appendChild(node.removeChild(childNodes[0]))
				df
			,
			stringify: (n) ->
				# $.HTML.stringify(/n/) - the _Node_ /n/ in it's html-string form
				n = n.cloneNode(true)
				d = document.createElement("div")
				d.appendChild(n)
				ret = d.innerHTML
				d.removeChild(n) # clean up to prevent leaks
				try { n.parentNode = null }
				catch( err ) { }
				ret
			,
			escape: (h) ->
				# $.HTML.escape(/h/) - accept html string /h/, a string with html-escapes like &amp;
				escaper or= $("<div>&nbsp;</div>").child(1)
				# insert html using the text node's .data property
				ret = escaper.zap('data', h)
					# then get escaped html from the parent's .innerHTML
					.zip("parentNode.innerHTML").first()
				# clean up so escaped content isn't leaked into the DOM
				escaper.zap('data', emptyString)
				ret
		,

		html: (h) ->
			# .html([h]) - get [or set] /x/.innerHTML for each node
			h is undefined ? @zip('innerHTML')
				: Object.IsString(h) ? @zap('innerHTML', h)
				: Object.IsBling(h) ? @html(h.toFragment())
				: Object.IsNode(h) ? @each () ->
					# replace all our children with the new child
					@replaceChild(@childNodes[0], h)
					while( @childNodes.length > 1 )
						@removeChild(@childNodes[1])
				: undefined
		,

		append: (x) ->
			# .append(/n/) - insert /n/ [or a clone] as the last child of each node
			if x?
				x = toNode(x) # parse, cast, do whatever it takes to get a Node or Fragment
				a = @zip('appendChild')
				a.take(1).call(x)
				a.skip(1).each (f) ->
					f(x.cloneNode(true))
			@
		,

		appendTo: (x) ->
			# .appendTo(/n/) - each node [or a fragment] will become the last child of n
			if x?
				$(x).append(@)
			@
		,

		prepend: (x) ->
			# .prepend(/n/) - insert n [or a clone] as the first child of each node
			if x?
				x = toNode(x)
				@take(1).each () ->
					_before @childNodes[0], x
				@skip(1).each(() ->
					_before @childNodes[0], x.cloneNode(true)
			@
		,

		prependTo: (x) ->
			# .prependTo(/n/) - each node [or a fragment] will become the first child of n
			if x?
				$(x).prepend(@)
			@
		,

		before: (x) ->
			# .before(/n/) - insert content n before each node
			if x?
				x = toNode(x)
				@take(1).each () -> _before @, x
				@skip(1).each () -> _before @, x.cloneNode(true)
			@
		,

		after: (x) ->
			# .after(/n/) - insert content n after each node
			if x?
				x = toNode(x)
				@take(1).each () -> _after @, x
				@skip(1).each () -> _after @, x.cloneNode(true)
			@
		,

		wrap: (parent) ->
			# .wrap(/p/) - p becomes the new .parentNode of each node
			# all items of @ will become children of parent
			# parent will take each child's position in the DOM
			parent = toNode(parent)
			if Object.IsFragment(parent)
				throw new Error("cannot wrap with a fragment")
			@map (child) ->
				if Object.IsFragment(child)
					parent.appendChild(child)
				else if Object.IsNode(child)
					p = child.parentNode
					if not p
						parent.appendChild(child)
					else
						# swap out the DOM nodes using a placeholder element
						marker = document.createElement("dummy")
						# put a marker in the DOM, put removed node in new parent
						parent.appendChild( p.replaceChild(marker, child) )
						# replace marker with new parent
						p.replaceChild(parent, marker)
				child
		,

		unwrap: () ->
			# .unwrap() - replace each node's parent with itself
			@each () ->
				if @parentNode and @parentNode.parentNode
					@parentNode.parentNode
						.replaceChild(@, @parentNode)
		,

		replace: (n) ->
			# .replace(/n/) - replace each node with n [or a clone]
			n = toNode(n)
			b = $(), j = -1
			# first node gets the real n
			@take(1).each () ->
				if @parentNode
					@parentNode.replaceChild(n, @)
					b[++j] = n
			# the rest get clones of n
			@skip(1).each(() ->
				if @parentNode
					c = n.cloneNode(true)
					@parentNode.replaceChild(c, @)
					b[++j] = c
			# the set of inserted nodes
			b
		,

		attr: (a,v) ->
			# .attr(a, [v]) - get [or set] an /a/ttribute [/v/alue]
			actor = v is undefined ? "getAttribute"
				: v is null ? "removeAttribute"
				: "setAttribute"
			ret = @zip(actor).call(a,v)
			v ? @ : ret
		,

		addClass: (x) ->
			# .addClass(/x/) - add x to each node's .className
			# remove the node and then add it to avoid dups
			@removeClass(x).each () ->
				c = @className.split(space).filter (y) -> y isnt emptyString
				c.push(x) # since we dont know the len, its still faster to push, rather than insert at len()
				@className = c.join space
		,

		removeClass: (x) ->
			# .removeClass(/x/) - remove class x from each node's .className
			notx = (y)-> y != x
			@each () ->
				@className = @className.split(space).filter(notx).join(space)
		,

		toggleClass: (x) ->
			# .toggleClass(/x/) - add, or remove if present, class x from each node
			notx(y) -> y != x
			@each () ->
				cls = @className.split(space)
				if( cls.indexOf(x) > -1 )
					@className = cls.filter(notx).join(space)
				else
					cls.push(x)
					@className = cls.join(space)
		,

		hasClass: (x) ->
			# .hasClass(/x/) - true/false for each node: whether .className contains x
			# note: different from jQuery, we always sets when possible
			@zip('className.split').call(space)
				.zip('indexOf').call(x)
				.map(Function.IndexFound)
		,

		text: (t) ->
			# .text([t]) - get [or set] each node's .innerText
			t == null
				? @zip('textContent')
				: @zap('textContent', t)
		,

		val: (v) ->
			# .val([v]) - get [or set] each node's .value
			v == null
				? @zip('value')
				: @zap('value', v)
		,

		css: (k,v) ->
			# .css(k, [v]) - get/set css properties for each node
			# called with string k and undefd v -> value of k
			# called with string k and string v -> set property k = v
			# called with object k and undefd v -> set css(x, k[x]) for x in k
			### Example:
			> $("body").css("background-color", "black").css("color", "white")
			> $("body").css({color: "white", "background-color": "black"})
			###
			if v? or Object.IsObject k
				setter = @zip 'style.setProperty'
				nn = setter.len()
				if Object.IsObject k
					for i of k
						setter.call i, k[i], emptyString
				else if Object.IsString v
					setter.call k, v, emptyString
				else if Object.IsArray v
					n = Math_max v.length, nn
					for i in [0...n]
						setter[i%nn] k, v[i%n], emptyString
				return @
			else
				# collect the computed values
				cv = @map getCSSProperty(k)
				# collect the values specified directly on the node
				ov = @zip('style').zip k
				# weave and fold them so that object values override computed values
				return ov.weave(cv).fold (x,y) -> return x ? x : y
		,

		defaultCss: (k, v) ->
			# .defaultCss(k, [v]) - adds an inline style tag to the head for the current selector.
			# If k is an object of k:v pairs, then no second argument is needed.
			# Unlike css() which applies css directly to the style attribute,
			# defaultCss() adds actual css text to the page, based on @selector,
			# so it can still be over-ridden by external css files (such as themes)
			# also, @selector need not match any nodes at the time of the call
			sel = @selector
			style = emptyString
			if Object.IsString(k)
				if Object.IsString(v)
					style += "#{sel} { #{k}: #{v} } "
				else throw Error("defaultCss requires a value with a string key")
			else if Object.IsObject(k)
				style += "#{sel} { "
				style += "#{i}: #{k[i]}; " for i of k
				style += "} "
			$.synth("style").text(style).appendTo("head")
			@
		,

		empty: () ->
			# .empty() - remove all children
			@html emptyString
		,

		rect: () ->
			# .rect() - collect a ClientRect for each node in @
			@zip('getBoundingClientRect').call()
		,
		width: (w) ->
			# .width([/w/]) - get [or set] each node's width value
			 w == null
				? @rect().zip(_width)
				: @css(_width, w)
		,
		height: (h) ->
			# .height([/h/]) - get [or set] each node's height value
			h == null
				? @rect().zip(_height)
				: @css(_height, h)
		,
		top: (y) ->
			# .top([/y/]) - get [or set] each node's top value
			y == null
				? @rect().zip(_top)
				: @css(_top, y)
		,
		left: (x) ->
			# .left([/x/]) - get [or set] each node's left value
			x == null
				? @rect().zip(_left)
				: @css(_left, x)
		,
		bottom: (x) ->
			# .bottom([/x/]) - get [or set] each node's bottom value
			x == null
				? @rect().zip(_bottom)
				: @css(_bottom, x)
		,
		right: (x) ->
			# .right([/x/]) - get [or set] each node's right value
			x == null
				? @rect().zip(_right)
				: @css(_right, x)
		,
		position: (x, y) ->
			# .position([/x/, [/y/]]) - get [or set] each node's top and left values
			# with no args, return the entire current position
			x == null
				? @rect()
				# with just x, just set style.left
				: y == null
					? @css(_left, Number.Px(x))
					# with x and y, set style.top and style.left
					: @css({top: Number.Px(y), left: Number.Px(x)})
		,

		center: (mode ="viewport") ->
			# .center([mode]) - move the elements to the center of the screen
			# mode is "viewport" (default), "horizontal" or "vertical"
			# TODO: "viewport" should probably use window.innerHeight
			# TODO: this is all wrong...
			body = document.body
			vh = body.scrollTop  + (body.clientHeight/2)
			vw = body.scrollLeft + (body.clientWidth/2)
			@each () ->
				t = $(@)
				h = t.height().floats().first()
				w = t.width().floats().first()
				x = mode is "viewport" or mode is "horizontal"
					? vw - (w/2)
					: NaN
				y = mode is "viewport" or mode is "vertical"
					? vh - (h/2)
					: NaN
				t.css { position: _absolute,
					left: Number.Px(x),
					top: Number.Px(y)
				}
		,

		scrollToCenter: () ->
			# .scrollToCenter() - scroll first node to center of viewport
			document.body.scrollTop = @zip('offsetTop')[0] - (window.innerHeight / 2)
			@
		,

		child: (n) ->
			# .child(/n/) - returns the /n/th childNode for each in _this_
			@map () ->
				nn = @childNodes.length
				i = n >= 0 ? n : n + nn
				if i < nn
					@childNodes[i]
				null
		,

		children: () ->
			# .children() - collect all children of each node
			@map () ->
				$(@childNodes, @)
		,

		parent: () ->
			# .parent() - collect .parentNode from each of _this_
			@zip('parentNode')
		,

		parents: () ->
			# .parents() - collects the full ancestry up to the owner
			@map () ->
				b = $()
				j = 0
				p = @
				while p = p.parentNode
					b[j++] = p
				b
		,

		prev: () ->
			# .prev() - collects the chain of .previousSibling nodes
			@map () ->
				b = $()
				j = 0
				p = @
				while p = p.previousSibling
					b[j++] = p
				b
		,

		next: () ->
			# .next() - collect the chain of .nextSibling nodes
			@map () ->
				b = $()
				j = 0
				p = @
				while p = p.nextSibling
					b[j++] = p
				b
		,

		remove: () ->
			# .remove() - removes each node in _this_ from the DOM
			@each ()->
				if @parentNode
					@parentNode.removeChild(@)
		,

		find: (css) ->
			# .find(/css/) - collect nodes matching /css/
			@filter("*") # limit to only nodes
				.map () -> $(css, @)
				.flatten()
		,

		clone: (deep=true) ->
			# .clone(deep=true) - copies a set of DOM nodes
			# note: does not copy event handlers
			@map () ->
				if Object.IsNode @
					@cloneNode deep
				else
					null
		,

		toFragment: () ->
			# .toFragment() - converts a bling of convertible stuff to a Node or DocumentFragment.
			# FOR ADVANCED USERS.
			# (nodes, strings, fragments, blings) into a single Node if well-formed,
			# or a DocumentFragment if not.
			# note: DocumentFragments are a sub-class of Node.
			#   Object.IsNode(fragment) == true
			#   fragment.nodeType == 11
			# This means you can node.appendChild() them directly, like DOM nodes.
			# But, unlike regular DOM nodes, if you insert a fragment, it disappears
			# and it's children are all inserted, and the fragment will be empty.
			# In the other direction, if you insert nodes into a fragment,
			# they are DETACHED from the DOM, and attached to the fragment.
			# So be sure to re-attach them, or save a reference, or you will lose them.
			# explanation:
			#   $("input").length is 2
			#   $("input").toFragment().childNodes.length is 2
			#   $("input").length is 0 // !?
			# Where did the inputs go?!
			# The first search finds 2 nodes.
			# The second search finds 2 nodes and DETACHES them.
			# Both inputs nodes now have .parentNode == the fragment.
			# The third search is searching the document object,
			# to which the inputs are no longer attached, and it finds 0.
			# They are attached to the fragment, whose reference we discarded.
			if @len() is 1
				toNode(@[0])
			df = document.createDocumentFragment()
			@map(toNode).map Function.Bound(df.appendChild, df)
			df
	}

$.plugin(Maths() ->
	{
		floats: () ->
			# .floats() - parseFloat(/x/) for /x/ in _this_
			@map parseFloat

		ints: () ->
			# .ints() - parseInt(/x/) for /x/ in _this_
			@map () -> parseInt @, 10

		px: (delta=0) ->
			# .px([delta]) - collect "NNpx" strings
			@ints().map Function.Px(delta)

		min: () ->
			# .min() - select the smallest /x/ in _this_
			@reduce (a) -> Math_min @, a

		max: () ->
			# .max() - select the largest /x/ in _this_
			@reduce (a) -> Math_max @, a

		average: () ->
			# .average() - compute the average of all /x/ in _this_
			@sum() / @len()

		sum: () ->
			# .sum() - add all /x/ in _this_
			@reduce (a) -> a + @

		squares: ()  ->
			# .squares() - collect /x*x/ for each /x/ in _this_
			@map () -> @ * @

		magnitude: () ->
			# .magnitude() - compute the vector length of _this_
			Math_sqrt n.floats().squares().sum()

		scale: (r) ->
			# .scale(/r/) - /x/ *= /r/ for /x/ in _this_
			@map () -> r * @

		normalize: () ->
			# .normalize() - scale _this_ so that .magnitude() == 1
			@scale(1/@magnitude())
	}

$.plugin(Events() ->
	# support these generic events
	# (click and ready are done separately)
	events = ['mousemove','mousedown','mouseup','mouseover','mouseout','blur','focus',
		'load','unload','reset','submit','keyup','keydown','change',
		'abort','cut','copy','paste','selection','drag','drop','orientationchange',
		'touchstart','touchmove','touchend','touchcancel',
		'gesturestart','gestureend','gesturecancel',
		'hashchange'
	]

	binder = (e) ->
		# carefully create a non-anonymous function
		# using an anonymous one to avoid using eval()
		(new Function('''return function #{e}(f) { 
			// .#{e}([f]) - trigger [or bind] the '#{e}' event
			Object.IsFunc(f) ? this.bind('#{e}',f)
			 : this.trigger('#{e}', f ? f : {}) 
		}''')
		)()

	register_live = (selector, context, e, f, h) ->
		$(context)
			.bind(e, h) # bind the real handler
			.each () ->
				a = (@__alive__ or= {})
				b = (a[selector] or= {})
				c = (b[e] or= {})
				# make a record using the fake handler
				c[f] = h

	unregister_live = (selector, context, e, f) ->
		$c = $(context)
		$c.each () ->
			a = (@__alive__ or= {} ),
			b = (a[selector] or= {}),
			c = (b[e] or= {}),
			h = c[f]
			$c.unbind(e, h)
			delete c[f]

	# detect and fire the document.ready event
	readyTriggered = 0
	readyBound = 0
	triggerReady = () ->
		if( readyTriggered++ )
			return
		$(document).trigger('ready').unbind('ready')
		if( document.removeEventListener )
			document.removeEventListener("DOMContentLoaded", triggerReady, false)
		if( window.removeEventListener )
			window.removeEventListener("load", triggerReady, false)
	bindReady = () ->
		if( readyBound++ )
			return
		if( document.addEventListener )
			document.addEventListener("DOMContentLoaded", triggerReady, false)
		if( window.addEventListener )
			window.addEventListener("load", triggerReady, false)
	bindReady()

	ret = [
		bind(e, f) ->
			# .bind(e, f) - adds handler f for event type e
			# e is a string like 'click', 'mouseover', etc.
			# e can be comma-separated to bind multiple events at once
			var c = (e||emptyString).split(commasep_re),
				n = c.length, i = 0,
				h = (evt) ->
					var ret = f.apply(@, arguments)
					if( ret is false )
						Event.Prevent(evt)
					ret
				}
			@each(() ->
				for(i = 0; i < n; i++)
					@addEventListener(c[i], h, false)
			})
		,

		unbind(e, f) ->
			# .unbind(e, [f]) - removes handler f from event e
			# if f is not present, removes all handlers from e
			var i = 0,
				c = (e||emptyString).split(commasep_re),
				n = c.length
			@each(() ->
				for(; i < n; i++) {
					@removeEventListener(c[i],f,null)
				}
			})
		,

		once(e, f) ->
			# .once(e, f) - adds a handler f that will be called only once
			var i = 0,
				c = (e||emptyString).split(commasep_re),
				n = c.length
			for(; i < n; i++) {
				@bind(c[i], (evt) ->
					f.call(@, evt)
					@unbind(evt.type, arguments.callee)
				})
			}
		,

		cycle(e) ->
			# .cycle(e, ...) - bind handlers for e that trigger in a cycle
			# one call per trigger. when the last handler is executed
			# the next trigger will call the first handler again
			var j = 0,
				funcs = Array.Slice(arguments, 1, arguments.length),
				c = (e||emptyString).split(commasep_re),
				ne = c.length,
				nf = funcs.length
			cycler() ->
				var i = 0
				(evt) ->
					funcs[i].call(@, evt)
					i = ++i % nf
				}
			}
			while( j < ne )
				@bind(c[j++], cycler())
			@
		,

		trigger(evt, args) ->
			# .trigger(e, a) - initiates a fake event
			# evt is the type, 'click'
			# args is an optional mapping of properties to set,
			#   {screenX: 10, screenY: 10}
			# note: not all browsers support manually creating all event types
			var e, i = 0,
				evts = (evt||emptyString).split(commasep_re),
				n = evts.length,
				evt_i = null
			args = Object.Extend({
				bubbles: true,
				cancelable: true
			, args)

			for(; i < n; i++) {
				evt_i = evts[i]
				switch(evt_i) {
					# mouse events
					case "click":
					case "mousemove":
					case "mousedown":
					case "mouseup":
					case "mouseover":
					case "mouseout":
						e = document.createEvent("MouseEvents")
						args = Object.Extend({
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
						, args)
						e.initMouseEvent(evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
							args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.button, args.relatedTarget)
						break

					# UI events
					case "blur":
					case "focus":
					case "reset":
					case "submit":
					case "abort":
					case "change":
					case "load":
					case "unload":
						e = document.createEvent("UIEvents")
						e.initUIEvent(evt_i, args.bubbles, args.cancelable, window, 1)
						break

					# iphone touch events
					case "touchstart":
					case "touchmove":
					case "touchend":
					case "touchcancel":
						e = document.createEvent("TouchEvents")
						args = Object.Extend({
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
						, args)
						e.initTouchEvent(evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
							args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.touches, args.targetTouches, args.changedTouches, args.scale, args.rotation)
						break

					# iphone gesture events
					case "gesturestart":
					case "gestureend":
					case "gesturecancel":
						e = document.createEvent("GestureEvents")
						args = Object.Extend({
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
						, args)
						e.initGestureEvent(evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
							args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.target, args.scale, args.rotation)
						break

					# iphone events that are not supported yet
					# (dont know how to create yet, needs research)
					case "drag":
					case "drop":
					case "selection":

					# iphone events that we cant properly emulate
					# (because we cant create our own Clipboard objects)
					case "cut":
					case "copy":
					case "paste":

					# iphone events that are just plain events
					case "orientationchange":

					# a general event
					default:
						e = document.createEvent("Events")
						e.initEvent(evt_i, args.bubbles, args.cancelable)
						try{ e = Object.Extend(e, args) }
						catch( err ) { }
						# _log('triggering '+evt_i, e, args)
				}
				if( !e ) continue
				else try {
					@each(() ->
						@dispatchEvent(e)
					})
				} catch( err ) {
					_log("dispatchEvent error:",err)
				}
			}

			@
		,

		live(e, f) ->
			# .live(e, f) - handle events for nodes that will exist in the future
			var selector = @selector,
				context = @context
			# wrap f
			_handler(evt) ->
				# when the 'live' event is fired
				# re-execute the selector in the original context
				$(selector, context)
					# then see if the event would bubble into a match
					.intersect($(evt.target).parents().first().union($(evt.target)))
					# then fire the real handler on the matched nodes
					.each(() ->
						evt.target = @
						f.call(@, evt)
					})
			}
			# bind the handler to the context
			$(context).bind(e, _handler)
			# record f so we can 'die' it if needed
			register_live(selector, context, e, f, _handler)
			@
		,

		die(e, f) ->
			# die(e, [f]) - stop f [or all] from living for event e
			var selector = @selector,
				context = @context,
				h = unregister_live(selector, context, e, f)
			$(context).unbind(e, h)
			@
		,

		liveCycle(e) ->
			# .liveCycle(e, ...) - bind each /f/ in /.../ to /e/
			# one call per trigger. when the last handler is executed
			# the next trigger will call the first handler again
			var i = 0,
				funcs = Array.Slice(arguments, 1, arguments.length)
			@live(e, (evt) ->
				funcs[i].call(@, evt)
				i = ++i % funcs.length
			})
		,

		click(f) ->
			# .click([f]) - trigger [or bind] the 'click' event
			# if the cursor is just default then make it look clickable
			if( @css("cursor").intersect(["auto",emptyString]).len() > 0 )
				@css("cursor", "pointer")
			Object.IsFunc(f) ? @bind('click', f)
				: @trigger('click', f ? f : {})
		,

		ready(f) ->
			Object.IsFunc(f) ?
				readyTriggered ? f.call(@)
					: @bind('ready', f)
				: @trigger('ready', f ? f : {})
		}
	]

	# add event binding/triggering shortcuts for the generic events
	events.forEach((x) ->
		ret.push(binder(x))
	})

	ret
})

$.plugin(Transform() ->

	# constant speed names
	var speeds = {
			"slow": 700,
			"medium": 500,
			"normal": 300,
			"fast": 100,
			"instant": 0,
			"now": 0
		,
		# matches all the accelerated css property names
		accel_props_re = /(?:scale(?:3d)*|translate(?:[XYZ]|3d)*|rotate(?:[XYZ]|3d)*)/,
		transformCSS = "-webkit-transform",
		transitionProperty = "-webkit-transition-property",
		transitionDuration = "-webkit-transition-duration",
		transitionTiming = "-webkit-transition-timing-function",
		_ms = "ms",
		_hide = "hide",
		_show = "show",
		updateDelay = 50 # ms to wait for DOM changes to apply

		if( "MozTransform" in CSSStyleDeclaration.prototype ) {
			transformCSS = "-moz-transform"
			transitionProperty = "-moz-transition-property"
			transitionDuration = "-moz-transition-duration"
			transitionTiming = "-moz-transition-timing-function"
		} else if ( document.createElement("div").style.OTransform != undefined) {
			transformCSS = "-o-transform"
			transitionProperty = "-o-transition-property"
			transitionDuration = "-o-transition-duration"
			transitionTiming = "-o-transition-timing-function"
		}

	#/ Transformation Module: provides wrapper for using -webkit-transform ///
	[
		$duration(speed) ->
			# $.duration(/s/) - given a speed description (string|number), a number in milliseconds
			var d = speeds[speed]
			Object.IsDefined(d) ? d : parseFloat(speed)
		,

		# like jquery's animate(), but using only webkit-transition/transform
		transform(end_css, speed, easing, callback) ->
			# .transform(cssobject, [/speed/], [/callback/]) - animate css properties on each node
			# animate css properties over a duration
			# accelerated: scale, translate, rotate, scale3d,
			# ... translateX, translateY, translateZ, translate3d,
			# ... rotateX, rotateY, rotateZ, rotate3d
			# easing values (strings): ease | linear | ease-in | ease-out
			# | ease-in-out | step-start | step-end | steps(number[, start | end ])
			# | cubic-bezier(number, number, number, number)

			if( Object.IsFunc(speed) ) {
				callback = speed
				speed = null
				easing = null
			}
			else if( Object.IsFunc(easing) ) {
				callback = easing
				easing = null
			}
			speed = Object.IsDefined(speed) ? speed : "normal"
			easing = easing or "ease"
			var duration = $.duration(speed),
				props = [], j = 0, i = 0, ii = null,
				# what to send to the -webkit-transform
				trans = emptyString,
				# real css values to be set (end_css without the transform values)
				css = {}
			for( i in end_css )
				# pull all the accelerated values out of end_css
				if( accel_props_re.test(i) ) {
					ii = end_css[i]
					if( ii.join )
						ii = $(ii).px().join(commasep)
					else if( ii.toString )
						ii = ii.toString()
					trans += space + i + "(" + ii + ")"
				}
				else # stick real css values in the css dict
					css[i] = end_css[i]
			# make a list of the properties to be modified
			for( i in css )
				props[j++] = i
			# and include -webkit-transform if we have transform values to set
			if( trans )
				props[j++] = transformCSS

			# duration is always in milliseconds
			duration = duration + _ms
			# sets a list of properties to apply a duration to
			css[transitionProperty] = props
				.join(commasep)
			# apply the same duration to each property
			css[transitionDuration] =
				props.map(() -> duration })
					.join(commasep)
			# apply an easing function to each property
			css[transitionTiming] =
				props.map(() -> easing })
					.join(commasep)

			# apply the transformation
			if( trans )
				css[transformCSS] = trans
			# apply the css to the actual node
			@css(css)
			# queue the callback to be executed at the end of the animation
			# WARNING: NOT EXACT!
			@delay(duration, callback)
		,

		hide(callback) ->
			# .hide() - each node gets display:none
			@each(() ->
				if( @style ) {
					@_display = @style.display is _none ? emptyString : @style.display
					@style.display = _none
				}
			})
			.trigger(_hide)
			.delay(updateDelay, callback)
		,

		show(callback) ->
			# .show() - show each node
			@each(() ->
				if( @style ) {
					@style.display = @_display
					delete @_display
				}
			})
			.trigger(_show)
			.delay(updateDelay, callback)
		,

		visible() ->
			# .visible(): TODO, incomplete
			var y, x = y = null,
				# p is a set of nodes that enforce overflow cutoffs
				p = @parents().map((parents) ->
					var i = -1, n = parents.len();
					while( ++i < n ) {
						var pp = $(parents[i])
						if( pp[0] is document ) {
							x = x or document
							y = y or document
						} else {
							if( pp.css("overflow-x").first() == "hidden" )
								x = pp
							if( pp.css("overflow-y").first() == "hidden" )
								y = pp
							if(x && y)
								break
						}
					}
					$([x,y])
				})
			# TODO: should capture the viewport as well (window size, scrolling, etc)
			p
		,

		toggle(callback) ->
			# .toggle() - show each hidden node, hide each visible one
			@weave(@css("display"))
				.fold((display, node) ->
					if( display is _none ) {
						node.style.display = node._display or emptyString
						delete node._display
						$(node).trigger(_show)
					} else {
						node._display = display
						node.style.display = _none
						$(node).trigger(_hide)
					}
					node
				})
				.delay(updateDelay, callback)
		,

		fadeIn(speed, callback) ->
			# .fadeIn() - fade each node to opacity 1.0
			@
				.css('opacity','0.0')
				.show(()->
					@transform({
						opacity:"1.0",
						translate3d:[0,0,0]
					, speed, callback)
				})
		,
		fadeOut(speed, callback, _x, _y) ->
			# .fadeOut() - fade each node to opacity:0.0
			_x = _x or 0.0
			_y = _y or 0.0
			@transform({
				opacity:"0.0",
				translate3d:[_x,_y,0.0]
			, speed, () -> @hide(callback) })
		,
		fadeLeft(speed, callback)  ->
			# .fadeLeft() - fadeOut and move offscreen to the left
			@fadeOut(speed, callback, "-"+@width().first(), 0.0)
		,
		fadeRight(speed, callback) ->
			# .fadeRight() - fadeOut and move offscreen to the right
			@fadeOut(speed, callback, @width().first(), 0.0)
		,
		fadeUp(speed, callback)    ->
			# .fadeUp() - fadeOut and move off the top
			@fadeOut(speed, callback, 0.0, "-"+@height().first())
		,
		fadeDown(speed, callback)  ->
			# .fadeDown() - fadeOut and move off the bottom
			@fadeOut(speed, callback, 0.0, @height().first())
		}
	]
})

$.plugin(Http() ->
	#/ HTTP Request Module: provides wrappers for making http requests ///

	# static helper to create &foo=bar strings from object properties
	formencode(obj) ->
		var s = [], j = 0, o = JSON.parse(JSON.stringify(obj)) # quickly remove all non-stringable items
		for( var i in o )
			s[j++] = i + "=" + escape(o[i])
		s.join("&")
	}

	[
		$http(url, opts) ->
			# $.http(/url/, [/opts/]) - fetch /url/ using HTTP (method in /opts/)
			var xhr = new XMLHttpRequest()
			if( Object.IsFunc(opts) )
				opts = {success: Function.Bound(opts, xhr)}
			opts = Object.Extend({
				method: "GET",
				data: null,
				state: Function.Empty, # onreadystatechange
				success: Function.Empty, # onload
				error: Function.Empty, # onerror
				async: true,
				timeout: 0, # milliseconds, 0 is forever
				withCredentials: false,
				followRedirects: false,
				asBlob: false
			, opts)
			opts.state = Function.Bound(opts.state, xhr)
			opts.success = Function.Bound(opts.success, xhr)
			opts.error = Function.Bound(opts.error, xhr)
			if( opts.data && opts.method is "GET" )
				url += "?" + formencode(opts.data)
			else if( opts.data && opts.method is "POST" )
				opts.data = formencode(opts.data)
			xhr.open(opts.method, url, opts.async)
			xhr.withCredentials = opts.withCredentials
			xhr.asBlob = opts.asBlob
			xhr.timeout = opts.timeout
			xhr.followRedirects = opts.followRedirects
			xhr.onreadystatechange = onreadystatechange() ->
				if( opts.state ) opts.state()
				if( xhr.readyState is 4 )
					if( xhr.status is 200 )
						opts.success(xhr.responseText)
					else
						opts.error(xhr.status, xhr.statusText)
			}
			xhr.send(opts.data)
			$([xhr])
		,

		$post(url, opts) ->
			# $.post(/url/, [/opts/]) - fetch /url/ with a POST request
			if( Object.IsFunc(opts) )
				opts = {success: opts}
			opts = opts or {}
			opts.method = "POST"
			$.http(url, opts)
		,

		$get(url, opts) ->
			# $.get(/url/, [/opts/]) - fetch /url/ with a GET request
			if( Object.IsFunc(opts) )
				opts = {success: opts}
			opts = opts or {}
			opts.method = "GET"
			$.http(url, opts)
		}
	]
})

$.plugin(Database() ->
	#/ Database Module: provides access to the sqlite database ///

	# static error handler
	SqlError(t, e) -> throw new Error("sql error ["+e.code+"] "+e.message) }

	assert(cond, msg) ->
		if( ! cond ) {
			throw new Error("assert failed: "+msg)
		}
	}

	execute(stmt, values, callback, errors) ->
		# .execute(/sql/, [/values/], [/cb/], [/errcb/]) - shortcut for using transaction
		if( stmt == null ) null
		if( Object.IsFunc(values) ) {
			errors = callback
			callback = values
			values = null
		}
		values = values or []
		callback = callback or Function.Empty
		errors = errors or SqlError
		assert( Object.IsType(@[0], "Database"), "can only call .sql() on a bling of Database" )
		@transaction((t) ->
			t.executeSql(stmt, values, callback, errors)
		})
	}
	transaction( f ) ->
		# .transaction() - provides access to the db's raw transaction() method
		# but, use .execute() instead, its friendlier
		@zip('transaction').call(f)
		@
	}
	[
		$db(fileName, version, maxSize) ->
			# $.db([/file/], [/ver/], [/maxSize/]) - new connection to the local database
			var d = $([window.openDatabase(
				fileName or "bling.db",
				version or "0.0",
				fileName or "bling.db",
				maxSize or 1024)
			])
			d.transaction = transaction
			d.execute = execute
			d
		}
	]
})

$.plugin(Template() ->

	match_forward(text, find, against, start, stop) ->
		var count = 1
		if( stop == null or stop is -1 )
			stop = text.length
		for( var i = start; i < stop; i++ ) {
			if( text[i] is against )
				count += 1
			else if( text[i] is find )
				count -= 1
			if( count is 0 )
				i
		}
		-1
	}

	# the regex for the format specifiers in templates (from python)
	var type_re = /([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/

	compile(text) ->
		var ret = [],
			chunks = text.split(/%[\(\/]/),
			end = -1, i = 1, n = chunks.length,
			key = null, rest = null, match = null
		ret.push(chunks[0])
		for( ; i < n; i++) {
			end = match_forward(chunks[i], ')', '(', 0, -1)
			if( end is -1 )
				"Template syntax error: unmatched '%(' in chunk starting at: "+chunks[i].substring(0,15)
			key = chunks[i].substring(0,end)
			rest = chunks[i].substring(end)
			match = type_re.exec(rest)
			if( match is null )
				"Template syntax error: invalid type specifier starting at '"+rest+"'"
			rest = match[4]
			ret.push(key)
			# the |0 operation coerces to a number, anything that doesnt map becomes 0, so "3" -> 3, "" -> 0, null -> 0, etc.
			ret.push(match[1]|0)
			ret.push(match[2]|0)
			ret.push(match[3])
			ret.push(rest)
		}
		ret
	}
	compile.cache = {}

	$render(text, values) ->
		# $.render(/t/, /v/) - replace markers in string /t/ with values from /v/
		var cache = compile.cache[text] # get the cached version
			# or compile and cache it
			|| (compile.cache[text] = compile(text)),
			# the first block is always just text
			output = [cache[0]],
			# j is an insert marker into output
			j = 1 # (because .push() is slow on an iphone, but inserting at length is fast everywhere)
			# (and because building up @ list is the bulk of what render does)

		# then the rest of the cache items are: [key, pad, fixed, type, text remainder] 5-lets
		for( var i = 1, n = cache.length; i < n-4; i += 5) {
			var key = cache[i],
				# the format in three pieces
				# (\d).\d\w
				pad = cache[i+1],
				# \d.(\d)\w
				fixed = cache[i+2],
				# \d.\d(\w)
				type = cache[i+3],
				# the text remaining after the end of the format
				rest = cache[i+4],
				# the value to render for @ key
				value = values[key]

			# require the value
			if( value == null )
				value = "missing required value: "+key

			# format the value according to the format options
			# currently supports 'd', 'f', and 's'
			switch( type ) {
				case 'd':
					output[j++] = emptyString + parseInt(value, 10)
					break
				case 'f':
					output[j++] = parseFloat(value).toFixed(fixed)
					break
				# output unsupported formats like %s strings
				# TODO: add support for more formats
				case 's':
				default:
					output[j++] = emptyString + value
			}
			if( pad > 0 )
				output[j] = String.PadLeft(output[j], pad)
			output[j++] = rest
		}
		output.join(emptyString)
	}

	# modes for the synth machine
	var TAGMODE = 1, IDMODE = 2, CLSMODE = 3, ATTRMODE = 4, VALMODE = 5, DTEXTMODE = 6, STEXTMODE = 7

	$synth(expr) ->
		# $.synth(/expr/) - given a CSS expression, create DOM nodes that match
		var tagname = emptyString, id = emptyString, cls = emptyString, attr = emptyString, val = emptyString,
			text = emptyString, attrs = {}, parent = null, mode = TAGMODE,
			ret = $([]), i = 0, c = null
		ret.selector = expr
		ret.context = document
		emitText() ->
			# puts a TextNode in the resulting tree
			var node = $.HTML.parse(text)
			if( parent )
				parent.appendChild(node)
			else
				ret.push(node)
			text = emptyString
			mode = TAGMODE
		}
		emitNode() ->
			# puts a Node in the results
			var node = document.createElement(tagname)
			node.id = id ? id : null
			node.className = cls ? cls : null
			for(var k in attrs)
				node.setAttribute(k, attrs[k])
			if( parent )
				parent.appendChild(node)
			else
				ret.push(node)
			parent = node
			tagname = emptyString; id = emptyString; cls = emptyString
			attr = emptyString; val = emptyString; text = emptyString
			attrs = {}
			mode = TAGMODE
		}

		# 'c' steps across the input, one character at a time
		while( (c = expr[i++]) ) {
			if( c is '+' && mode is TAGMODE)
				parent = parent ? parent.parentNode : parent
			else if( c is '#' && (mode is TAGMODE or mode is CLSMODE or mode is ATTRMODE) )
				mode = IDMODE
			else if( c is _dot && (mode is TAGMODE or mode is IDMODE or mode is ATTRMODE) ) {
				if( cls.length > 0 )
					cls += space
				mode = CLSMODE
			}
			else if( c is _dot && cls.length > 0 )
				cls += space
			else if( c is '[' && (mode is TAGMODE or mode is IDMODE or mode is CLSMODE or mode is ATTRMODE) )
				mode = ATTRMODE
			else if( c is '=' && (mode is ATTRMODE))
				mode = VALMODE
			else if( c is '"' && mode is TAGMODE)
				mode = DTEXTMODE
			else if( c is "'" && mode is TAGMODE)
				mode = STEXTMODE
			else if( c is ']' && (mode is ATTRMODE or mode is VALMODE) ) {
				attrs[attr] = val
				attr = emptyString
				val = emptyString
				mode = TAGMODE
			}
			else if( c is '"' && mode is DTEXTMODE )
				emitText()
			else if( c is "'" && mode is STEXTMODE )
				emitText()
			else if( (c is space or c is ',') && (mode isnt VALMODE && mode isnt ATTRMODE) && tagname.length > 0 ) {
				emitNode()
				if( c == ',' )
					parent = null
			}
			else if( mode is TAGMODE )
				tagname += c != space ? c : emptyString
			else if( mode is IDMODE ) id += c
			else if( mode is CLSMODE ) cls += c
			else if( mode is ATTRMODE ) attr += c
			else if( mode is VALMODE ) val += c
			else if( mode is DTEXTMODE or mode is STEXTMODE ) text += c
			else throw new Error("Unknown input/state: '"+c+"'/"+mode)
		}

		if( tagname.length > 0 )
			emitNode()

		if( text.length > 0 )
			emitText()

		ret
	}

	[
		$render,
		$synth,

		template(defaults) ->
			# .template([defaults]) - mark nodes as templates, add optional defaults to .render()
			# if defaults is passed, these will be the default values for v in .render(v)
			@render = (args) ->
				# an over-ride of the basic .render() that applies these defaults
				$render(@map($.HTML.stringify).join(emptyString), Object.Extend(defaults,args))
			}

			@remove() # the template item itself should not be in the DOM
		,

		render(args) ->
			# .render(args) - replace %(var)s-type strings with values from args
			# accepts nodes, returns a string
			$render(@map($.HTML.stringify).join(emptyString), args)
		,

		synth(expr) ->
			# .synth(expr) - create DOM nodes to match a simple css expression
			# supports the following css selectors:
			# tag, #id, .class, [attr=val]
			# and the additional helper "text"
			$synth(expr).appendTo(@)

			###
 Example:
				> $("body").synth("div#one.foo.bar[orb=bro] span + p")
				> == $([<div id="one" class="foo bar" orb="bro"> <span></span> <p></p> </div>])

				And, the new nodes would already be children of "body".

				You can create the nodes on their own by using the global version:

				> $.synth("div#one p")
				> == $([<div id="one"><p></p></div>])

				These will not be attached to anything when they are returned.

				Each expression returns a single node that is the parent of the new tree.
				But, you can pass in a comma-separated list of expressions to get multiple nodes back.

				> $.synth("div#one, div#two")
				> == $([<div id="one"></div>, <div id="two"></div>])

				You can use the new quote selector to add text nodes.

				> $.synth('div#one "hello" + div#two "world"')
				> == $([<div id="one">hello<div id="two">world</div></div>])

				You can use the '+' operator not only for adjacency:

				> $.synth("div h3 'title' + p 'body'")
				> == $([<div><h3>title</h3><p>body</p></div>])

				But, you can also repeat the '+' in order to ascend any number of times.

				> $.synth("ul li h3 'one' + p 'body' ++ li h3 'two' + p 'body'")
				> == $([<ul><li><h3>one</h3><p>body</p><li><h3>two</h3><p>body</p></li></ul>])

				If you ascend higher than the root, you get a list of separate nodes.

				> $.synth("ul li p +++ span")
				> == $([<ul><li><p></p></li></ul>, <span></span>])

			###
		}

	]
})

})()
# vim: ft=coffee
