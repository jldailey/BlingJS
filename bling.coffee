###
 bling.js
# --------
# Named after the bling symbol ($) to which it is bound by default.
# This is a jQuery-like framework.
# Blame: Jesse Dailey <jesse.dailey@gmail.com>
###

if not "querySelectorAll" in document
	alert "This browser is not supported"

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
_log = console.log
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
_ms = "ms"
_hide = "hide"
_show = "show"
_ready = "ready"
_load = "load"

Array::extend = (a) ->
	j = @length
	for i in a
		@[j++] = i
	@

### Bling, the "constructor".
# -----------------------
# Bling (selector, context):
# @param {(string|number|Array|NodeList|Node|Window)=} selector
#		accepts strings, as css expression to select, ("body div + p", etc.)
#			or as html to create (must start with "<")
#		accepts existing Bling
#		accepts arrays of anything
#		accepts a single number, used as the argument in new Array(n), to pre-allocate space
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
	IsType: (o,T) -> # Object.IsType(o,T) - true if object o is of type T (directly or indirectly)
		if o == null
			o is T
		else if o.__proto__ == null
			false
		else if o.__proto__.constructor is T
			true
		else if typeof T is _string
			o.constructor.name is T or Obj_toString.apply(o).replace(object_cruft, _1) is T
		else
			Object.IsType o.__proto__, T # recurse through sub-classes
	Type: (o) ->
		switch true
			when Object.IsString o
				"string"
			when Object.IsNumber o
				"number"
			when Object.IsFragment o
				"fragment"
			when Object.IsNode o
				"node"
			when Object.IsFunc o
				"function"
			when Object.IsArray o
				"array"
			when Object.IsBling o
				"bling"
			when Object.IsType o, "RegExp"
				"regexp"
			when Object.IsObject o
				"object"
	IsString: (o) -> # Object.IsString(a) - true if object a is a string
		o? and (typeof o is _string or Object.IsType(o, String))
	IsNumber: isFinite
	IsFunc: (o) -> # Object.IsFunc(a) - true if object a is a function
		o? and (typeof o is _function or Object.IsType(o, Function)) and o.call?
	IsNode: (o) -> # Object.IsNode(o) - true if object is a DOM node
		o? and o.nodeType > 0
	IsFragment: (o) -> # Object.IsFragment(o) - true if object is a DocumentFragment node
		o? and o.nodeType is 11
	IsArray: (o) -> # Object.IsArray(o) - true if object is an Array (or inherits Array)
		o? and (Object.ToString(o) is _object_Array or Object.IsType(o, Array))
	IsBling: (o) ->
		o? and Object.IsType(o, Bling)
	IsObject: (o) -> # Object.IsObject(o) - true if a is an object
		o? and typeof o is _object
	IsDefined: (o) -> # Object.IsDefined(o) - true if a is not null nor undefined
		o?
	Unbox: (a) -> # Object.Unbox(o) - primitive types can be 'boxed' in an object
		if a? and Object.IsObject(a)
			return a.toString() if Object.IsString a
			return Number(a) if Object.IsNumber a
		a
	ToString: (x) ->
		Obj_toString.apply(x)
}

### Function Extensions
# ------------------- ###
Object.Extend Function, {
	Empty: () -> # the empty function
	Bound: (f, t, args = []) -> # Function.Bound(/f/, /t/) - whenever /f/ is called, _this_ is /t/
		if "bind" of f
			args.splice 0, 0, t
			r = f.bind.apply f, args
		else
			r = (a...) ->
				if args.length > 0
					a = args
				f.apply t, args
		r.toString = () ->
			"bound-method of #{t}.#{f.name}"
		r
	Trace: (f, label, tracer = _log) -> # Function.Trace(/f/, /label/) - log calls to /f/
		r = (a...) ->
			tracer "#{label or emptyString}#{@name or @}.#{f.name}(", a, ")"
			f.apply @, a
		tracer "Function.Trace: #{label or f.name} created."
		r.toString = f.toString
		r
	NotNull: (x) -> x != null
	IndexFound: (x) -> x > -1
	ReduceAnd: (x) -> x and @
	UpperLimit: (x) -> (y) -> Math_min(x, y)
	LowerLimit: (x) -> (y) -> Math_max(x, y)
	Px: (d) -> () -> Number.Px(@,d)
}

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
	Px: (x, d=0) ->
		# Px(/x/, /delta/=0) - convert a number-ish x to pixels
		x? and (parseInt(x,10)+(d|0))+_px
	# mappable versions of max() and min()
	AtLeast: (x) ->
		(y) ->
			Math_max parseFloat(y or 0), x
	AtMost: (x) ->
		(y) ->
			Math_min parseFloat(y or 0), x
}

### String Extensions
# ----------------- ###
Object.Extend String, {
	PadLeft: (s, n, c = space) ->
		# String.PadLeft(string, width, fill=" ")
		while s.length < n
			s = c + s
		s
	PadRight: (s, n, c = space) ->
		# String.PadRight(string, width, fill=" ")
		while s.length < n
			s = s + c
		s
	Splice: (s, i, j, n) ->
		# String.Splice(string, start, end, n) - replace a substring with n
		nn = s.length
		end = j
		if end < 0
			end += nn
		start = i
		if start < 0
			start += nn
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
		while (j = @indexOf sep,i) > -1
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

Element::matchesSelector = Array.Coalesce(
	Element::webkitMatchesSelector,
	Element::mozMatchesSelector,
	Element::matchesSelector
)

Element::toString = (precise = false) ->
	if not precise
		Element::toString.apply(@)
	else
		ret = @nodeName.toLowerCase()
		if @id?
			ret += "##{@id}"
		else if @className?
			ret += ".#{@className.split(space).join(_dot)}"
		ret

if Element::cloneNode.length is 0
	Element::cloneNode = (deep = false) ->
		n = @cloneNode()
		if deep
			for i in @childNodes
				n.appendChild i.cloneNode deep
		return n

$.plugin = (constructor) ->
	plugin = constructor.call $,$
	load = (name, func) ->
		if name[0] is Bling.symbol
			Bling[name.substr(1)] = func
		else
			Bling::[name] = func
	for i in Object.Keys(plugin, true)
		if i isnt 'name'
			load(i, plugin[i])
	$.plugins.push(plugin.name)
	$.plugins[plugin.name] = plugin

$.plugin () -> # Core - the functional basis for all other modules
	class TimeoutQueue extends Array
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
				setTimeout @next, n
	timeoutQueue = new TimeoutQueue()

	_getter = (p) -> # used in .zip()
		() ->
			v = @[p]
			return Function.Bound(v, @) if Object.IsFunc v
			return v
	_zipper = (p) -> # used in .zip()
		i = p.indexOf(_dot)
		return @zip(p.substr(0, i)).zip(p.substr(i+1)) if i > -1 # recurse compound names
		return @map _getter(p)

	return {
		name: 'Core'
		eq: (i) -> # .eq(/i/) - a new set containing only the /i/th item
			$([@[i]])

		each: (f) -> # .each(/f/) - apply function /f/ to every item /x/ in _this_.
			for i in @
				f.call(i, i)
			@

		map: (f) -> # .map(/f/) - collect /f/.call(/x/, /x/) for every item /x/ in _this_.
			a = $()
			a.context = @
			a.selector = ['map', f]
			nn = @len()
			for i in [0...nn]
				t = @[i]
				try
					a[i] = f.call t,t
				catch err
					a[i] = err
			a

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

		intersect: (other) ->
			# .intersect(/other/) - collect all /x/ that are in _this_ and _other_.
			ret = $()
			m = 0 # insert marker into ret
			n = @len()
			if Object.IsFunc other.len
				nn = other.len()
			else
				nn = other.length
			ret.context = [@, other]
			ret.selector = 'intersect'
			for i in [0...n]
				for j in [0...nn]
					if @[i] is other[j]
						ret[m++] = @[i]
						break
			ret

		distinct: (strict) ->
			# .distinct() - a copy of _this_ without duplicates.
			@union(@, strict)

		contains: (item, strict) ->
			# .contains(/x/) - true if /x/ is in _this_, false otherwise.
			@count(item, strict) > 0

		count: (item, strict) ->
			# .count(/x/) - returns how many times /x/ occurs in _this_.
			# since we want to be able to search for null values with .count(null)
			# but if you just call .count(), it returns the total length
			if item is undefined
				return @len()
			ret = 0
			@each (t) ->
				if (strict and t is item) or (not strict and t == item)
					ret++
			ret

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
					return _zipper.call(@, a[0])
				else # > 1
					# if more than one argument is passed, new objects
					# with only those properties, will be returned
					master = {}
					nn = @len()
					b = $()
					j = 0
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

		zap: (p, v) ->
			# .zap(p, v) - set /x/./p/ = /v/ for all /x/ in _this_.
			# just like zip, zap("a.b") == zip("a").zap("b")
			# but unlike zip, you cannot assign to many /p/ at once
			i = p.indexOf(_dot)
			if i > -1 # recurse compound names
				@zip(p.substr(0, i)).zap(p.substr(i+1), v)
			else if Object.IsArray(v) # accept /v/ as an array of values
				@each () ->
					@[p] = v[++i]
			else # accept a scalar /v/, even if v is undefined
				@each () ->
					@[p] = v

		take: (n) ->
			# .take([/n/]) - collect the first /n/ elements of _this_.
			# if n >= @length, returns a shallow copy of the whole bling
			n = Math_min n|0, @len()
			a = $()
			a.context = @
			a.selector = ['take',n]
			for i in [0...n]
				a[i] = @[i]
			a

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

		first: (n = 1) ->
			# .first([/n/]) - collect the first [/n/] element[s] from _this_.
			# if n is not passed, returns just the item (no bling)
			@take(n)

		last: (n = 1) ->
			# .last([/n/]) - collect the last [/n/] elements from _this_.
			# if n is not passed, returns just the last item (no bling)
			@skip(@len() - n)

		slice: (start, end) ->
			# .slice(/i/, [/j/]) - get a subset of _this_ including [/i/../j/-1]
			# the j-th item will not be included - slice(0,2) will contain items 0, and 1.
			# negative indices work like in python: -1 is the last item, -2 is second-to-last
			# undefined start or end become 0, or @length, respectively
			b = $(@[start...end])
			b.context = @
			b.selector = 'slice(#{start},#{end})'
			b

		concat: (b) ->
			# .concat(/b/) - insert all items from /b/ into _this_
			# note: unlike union, concat allows duplicates
			# note: also, does not create a new array, uses _this_ in-place
			i = @len() - 1
			j = -1
			if Object.IsFunc b.len
				n = b.len()
			else
				n = b.length
			while j < n-1
				@[++i] = b[++j]
			@

		push: (b) ->
			# .push(/b/) - override Array.push to return _this_
			Array::push.call(@, b)
			@

		filter: (f) ->
			# .filter(/f/) - collect all /x/ from _this_ where /x/./f/(/x/) is true
			# or if f is a selector string, collects nodes that match the selector
			# or if f is a RegExp, collect nodes where f.test(x) is true
			n = @len()
			b = $()
			b.context = @
			b.selector = f
			j = 0
			switch Object.Type(f)
				when "string"
					g = (x) ->
						it.matchesSelector?(x)
				when "regexp"
					g = (x) ->
						f.test(x)
				when "function"
					g = f
			for i in [0...n]
				it = @[i]
				if g.call it, it
					b[j++] = it
			b

		test: (regex) ->
			# .test(/regex/) - collects regex.test(/x/) for /x/ in _this_
			@map () ->
				regex.test(@)

		matches: (expr) ->
			# .matches(/css/) - collects /x/.matchesSelector(/css/)
			@zip('matchesSelector').call(expr)

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

		flatten: () -> # .flatten() - collect the union of all sets in _this_
			b = $()
			n = @len()
			k = 0 # insert marker
			b.context = @
			b.selector = 'flatten'
			for i in [0...n]
				c = @[i]
				if Object.IsFunc c.len
					d = c.len()
				else
					d = c.length
				for j in [0...d]
					b[k++] = c[j]
			b

		call: () -> # .call([/args/]) - collect /f/([/args/]) for /f/ in _this_
			@apply(null, arguments)

		apply: (context, args) -> # .apply(/context/, [/args/]) - collect /f/.apply(/context/,/args/) for /f/ in _this_
			@map () ->
				if Object.IsFunc @
					@apply(context, args)
				else
					@

		toString: () -> # .toString() - maps toString across @
			$.symbol + "([" + @map () ->
				switch @
					when undefined
						return _undefined
					when null
						return _null
					when window
						return "window"
					else
						return @toString().replace(object_cruft,_1)
			.join(commasep) + "])"

		delay: (n, f) -> # .delay(/n/, /f/) -  continue with /f/ on _this_ after /n/ milliseconds
			if f
				timeoutQueue.schedule Function.Bound(f, @), n
			@

		log: (label) -> # .log([label]) - console.log([/label/] + /x/) for /x/ in _this_
			n = @len()
			if label
				_log(label, @, n + " items")
			else
				_log(@, n + " items")
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
	}

$.plugin () -> # Html Module
	before = (a,b) -> # insert b before a
		a.parentNode.insertBefore b, a

	after = (a,b) -> # insert b after a
		a.parentNode.insertBefore b, a.nextSibling

	toNode = (x) -> # convert nearly anything to something node-like for use in the DOM
		switch Object.Type x
			when "node"
				return x
			when "bling"
				return x.toFragment()
			when "string"
				return $(x).toFragment()
			when "function"
				return $(x.toString()).toFragment()

	escaper = null

	getCSSProperty = (k) ->
		# window.getComputedStyle is not a normal function
		# (it doesnt support .call() so we can't use it with .map())
		# so define something that does work right for use in .css
		() ->
			window.getComputedStyle(@, null).getPropertyValue(k)

	return {
		name: 'Html'

		$HTML: # $.HTML.* - HTML methods similar to the global JSON object
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
				df
			stringify: (n) -> # $.HTML.stringify(/n/) - the _Node_ /n/ in it's html-string form
				n = n.cloneNode(true)
				d = document.createElement("div")
				d.appendChild(n)
				ret = d.innerHTML
				d.removeChild(n) # clean up to prevent leaks
				try
					n.parentNode = null
				catch err
				ret
			escape: (h) -> # $.HTML.escape(/h/) - accept html string /h/, a string with html-escapes like &amp;
				escaper or= $("<div>&nbsp;</div>").child(1)
				# insert html using the text node's .data property
				# then get escaped html from the parent's .innerHTML
				ret = escaper.zap('data', h).zip("parentNode.innerHTML").first()
				# clean up so escaped content isn't leaked into the DOM
				escaper.zap('data', emptyString)
				ret

		html: (h) -> # .html([h]) - get [or set] /x/.innerHTML for each node
			switch Object.Type h
				when "undefined"
					return @zip('innerHTML')
				when "string"
					return @zap('innerHTML', h)
				when "bling"
					return @html(h.toFragment())
				when "node"
					return @each () -> # replace all our children with the new child
						@replaceChild @childNodes[0], h
						while @childNodes.length > 1
							@removeChild @childNodes[1]

		append: (x) -> # .append(/n/) - insert /n/ [or a clone] as the last child of each node
			if x?
				x = toNode(x) # parse, cast, do whatever it takes to get a Node or Fragment
				a = @zip('appendChild')
				a.take(1).call(x)
				a.skip(1).each (f) ->
					f(x.cloneNode(true))
			@

		appendTo: (x) -> # .appendTo(/n/) - each node [or a fragment] will become the last child of n
			if x?
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

		before: (x) -> # .before(/n/) - insert content n before each node
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

		unwrap: () -> # .unwrap() - replace each node's parent with itself
			@each () ->
				if @parentNode and @parentNode.parentNode
					@parentNode.parentNode
						.replaceChild(@, @parentNode)

		replace: (n) -> # .replace(/n/) - replace each node with n [or a clone]
			n = toNode(n)
			b = $()
			j = 0
			# first node gets the real n
			@take(1).each () ->
				if @parentNode
					@parentNode.replaceChild(n, @)
					b[j++] = n
			# the rest get clones of n
			@skip(1).each () ->
				if @parentNode
					c = n.cloneNode(true)
					@parentNode.replaceChild(c, @)
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

		addClass: (x) -> # .addClass(/x/) - add x to each node's .className
			@removeClass(x).each () ->
				c = @className.split(space).filter (y) ->
					y isnt emptyString
				c.push(x) # since we dont know the len, its still faster to push, rather than insert at len()
				@className = c.join space

		removeClass: (x) -> # .removeClass(/x/) - remove class x from each node's .className
			notx = (y)->
				y != x
			@each () ->
				@className = @className.split(space).filter(notx).join(space)

		toggleClass: (x) -> # .toggleClass(/x/) - add, or remove if present, class x from each node
			notx = (y) ->
				y != x
			@each () ->
				cls = @className.split(space)
				if( cls.indexOf(x) > -1 )
					@className = cls.filter(notx).join(space)
				else
					cls.push(x)
					@className = cls.join(space)

		hasClass: (x) -> # .hasClass(/x/) - true/false for each node: whether .className contains x
			@zip('className.split').call(space).zip('indexOf').call(x).map Function.IndexFound

		text: (t) -> # .text([t]) - get [or set] each node's .innerText
			if t == null
				return @zip('textContent')
			return @zap('textContent', t)

		val: (v) -> # .val([v]) - get [or set] each node's .value
			if v == null
				return @zip('value')
			return @zap('value', v)

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
				ov.weave(cv).fold (x,y) ->
					x or y

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

		empty: () -> # .empty() - remove all children
			@html emptyString

		rect: () -> # .rect() - collect a ClientRect for each node in @
			@zip('getBoundingClientRect').call()

		width: (w) -> # .width([/w/]) - get [or set] each node's width value
			if w == null
				return @rect().zip(_width)
			return @css(_width, w)

		height: (h) -> # .height([/h/]) - get [or set] each node's height value
			if h == null
				return @rect().zip(_height)
			return @css(_height, h)

		top: (y) -> # .top([/y/]) - get [or set] each node's top value
			if y == null
				return @rect().zip(_top)
			return @css(_top, y)

		left: (x) -> # .left([/x/]) - get [or set] each node's left value
			if x == null
				return @rect().zip(_left)
			return @css(_left, x)

		bottom: (x) -> # .bottom([/x/]) - get [or set] each node's bottom value
			if x == null
				return @rect().zip(_bottom)
			return @css(_bottom, x)

		right: (x) -> # .right([/x/]) - get [or set] each node's right value
			if x == null
				return @rect().zip(_right)
			return @css(_right, x)

		position: (x, y) -> # .position([/x/, [/y/]]) - get [or set] each node's top and left values
			if x == null
				return @rect()
			# with just x, just set style.left
			if y == null
				return @css(_left, Number.Px(x))
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
					position: _absolute,
					left: Number.Px(x),
					top: Number.Px(y)
				}

		scrollToCenter: () -> # .scrollToCenter() - scroll first node to center of viewport
			document.body.scrollTop = @zip('offsetTop')[0] - (window.innerHeight / 2)
			@

		child: (n) -> # .child(/n/) - returns the /n/th childNode for each in _this_
			@map () ->
				nn = @childNodes.length
				i = n
				if n < 0
					i += nn
				if i < nn
					@childNodes[i]
				null

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
				.map () -> $(css, @)
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
				@map(toNode).map Function.Bound(df.appendChild, df)
				return df
			return toNode(@[0])
	}

$.plugin () -> # Math Module
	return {
		name: 'Maths'
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
			Math_sqrt @floats().squares().sum()

		scale: (r) ->
			# .scale(/r/) - /x/ *= /r/ for /x/ in _this_
			@map () -> r * @

		normalize: () ->
			# .normalize() - scale _this_ so that .magnitude() == 1
			@scale(1/@magnitude())
	}

$.plugin () -> # Events Module
	events = ['mousemove','mousedown','mouseup','mouseover','mouseout','blur','focus',
		'load','unload','reset','submit','keyup','keydown','change',
		'abort','cut','copy','paste','selection','drag','drop','orientationchange',
		'touchstart','touchmove','touchend','touchcancel',
		'gesturestart','gestureend','gesturecancel',
		'hashchange'
	]

	binder = (e) ->
		(f = {}) ->
			return this.bind(e, f) if Object.IsFunc f
			return this.trigger(e, f)

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
			a = (@__alive__ or= {} )
			b = (a[selector] or= {})
			c = (b[e] or= {})
			$c.unbind(e, c[f])
			delete c[f]

	# detect and fire the document.ready event
	readyTriggered = 0
	readyBound = 0
	triggerReady = () ->
		if not readyTriggered++
			$(document).trigger(_ready).unbind(_ready)
			document.removeEventListener?("DOMContentLoaded", triggerReady, false)
			window.removeEventListener?(_load, triggerReady, false)
	bindReady = () ->
		if not readyBound++
			document.addEventListener?("DOMContentLoaded", triggerReady, false)
			window.addEventListener?(_load, triggerReady, false)
	bindReady()

	ret = {
		name: 'Events'
		bind: (e, f) ->
			# .bind(e, f) - adds handler f for event type e
			# e is a string like 'click', 'mouseover', etc.
			# e can be comma-separated to bind multiple events at once
			c = (e or emptyString).split(commasep_re)
			h = (evt) ->
				ret = f.apply @, arguments
				if ret is false
					Event.Prevent evt
				ret
			@each () ->
				for i in c
					@addEventListener i, h, false

		unbind: (e, f) ->
			# .unbind(e, [f]) - removes handler f from event e
			# if f is not present, removes all handlers from e
			c = (e or emptyString).split(commasep_re)
			@each () ->
				for i in c
					@removeEventListener(i, f, null)

		once: (e, f) ->
			# .once(e, f) - adds a handler f that will be called only once
			c = (e or emptyString).split(commasep_re)
			for i in c
				@bind i, (evt) ->
					f.call(@, evt)
					@removeEventListener(evt.type, arguments.callee, null)

		cycle: (e, funcs...) ->
			# .cycle(e, ...) - bind handlers for e that trigger in a cycle
			# one call per trigger. when the last handler is executed
			# the next trigger will call the first handler again
			c = (e or emptyString).split(commasep_re)
			nf = funcs.length
			cycler = () ->
				i = 0
				(evt) ->
					funcs[i].call(@, evt)
					i = ++i % nf
			for j in c
				@bind j, cycler()
			@

		trigger: (evt, args) ->
			# .trigger(e, a) - initiates a fake event
			# evt is the type, 'click'
			# args is an optional mapping of properties to set,
			#		{screenX: 10, screenY: 10}
			# note: not all browsers support manually creating all event types
			evts = (evt or emptyString).split(commasep_re)
			args = Object.Extend {
				bubbles: true,
				cancelable: true
			}, args

			for evt_i in evts
				# mouse events
				if evt_i in ["click", "mousemove", "mousedown", "mouseup", "mouseover", "mouseout"]
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

				# UI events
				else if evt_i in ["blur", "focus", "reset", "submit", "abort", "change", "load", "unload"]
					e = document.createEvent "UIEvents"
					e.initUIEvent evt_i, args.bubbles, args.cancelable, window, 1

				# touch events
				else if evt_i in ["touchstart", "touchmove", "touchend", "touchcancel"]
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

				# gesture events
				else if evt_i in ["gesturestart", "gestureend", "gesturecancel"]
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
						@each () ->
							@dispatchEvent e
					catch err
						_log("dispatchEvent error:",err)
			@

		live: (e, f) ->
			# .live(e, f) - handle events for nodes that will exist in the future
			selector = @selector
			context = @context
			# wrap f
			_handler = (evt) ->
				# when the 'live' event is fired
				# re-execute the selector in the original context
				$(selector, context)
					# then see if the event would bubble into a match
					.intersect($(evt.target).parents().first().union($(evt.target)))
					# then fire the real handler on the matched nodes
					.each () ->
						evt.target = @
						f.call(@, evt)
			# bind the handler to the context
			$(context).bind e, _handler
			# record f so we can 'die' it if needed
			register_live selector, context, e, f, _handler
			@

		die: (e, f) ->
			# die(e, [f]) - stop f [or all] from living for event e
			selector = @selector
			context = @context
			h = unregister_live selector, context, e, f
			$(context).unbind e, h
			@

		liveCycle: (e, funcs...) ->
			# .liveCycle(e, ...) - bind each /f/ in /.../ to /e/
			# one call per trigger. when the last handler is executed
			# the next trigger will call the first handler again
			i = 0
			@live e, (evt) ->
				funcs[i].call @, evt
				i = ++i % funcs.length

		click: (f = {}) ->
			# .click([f]) - trigger [or bind] the 'click' event
			# if the cursor is just default then make it look clickable
			if @css("cursor").intersect(["auto",emptyString]).len() > 0
				@css "cursor", "pointer"
			if Object.IsFunc f
				@bind 'click', f
			else
				@trigger 'click', f

		ready: (f = {}) ->
			if Object.IsFunc f
				if readyTriggered
					f.call @
				else
					@bind _ready, f
			else
				@trigger _ready, f
	}

	# add event binding/triggering shortcuts for the generic events
	events.forEach (x) ->
		ret[x] = binder(x)
	ret

$.plugin () -> # Transform Module
	speeds = # constant speed names
		"slow": 700
		"medium": 500
		"normal": 300
		"fast": 100
		"instant": 0
		"now": 0
	# matches all the accelerated css property names
	accel_props_re = /(?:scale(?:3d)*|translate(?:[XYZ]|3d)*|rotate(?:[XYZ]|3d)*)/
	updateDelay = 50 # ms to wait for DOM changes to apply
	testStyle = document.createElement("div").style

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

	delete testStyle

	return {
		name: 'Transform'
		$duration: (speed) ->
			# $.duration(/s/) - given a speed description (string|number), a number in milliseconds
			d = speeds[speed]
			return d if d?
			return parseFloat speed

		# like jquery's animate(), but using only webkit-transition/transform
		transform: (end_css, speed, easing, callback) ->
			# .transform(cssobject, [/speed/], [/callback/]) - animate css properties on each node
			# animate css properties over a duration
			# accelerated: scale, translate, rotate, scale3d,
			# ... translateX, translateY, translateZ, translate3d,
			# ... rotateX, rotateY, rotateZ, rotate3d
			# easing values (strings): ease | linear | ease-in | ease-out
			# | ease-in-out | step-start | step-end | steps(number[, start | end ])
			# | cubic-bezier(number, number, number, number)

			if Object.IsFunc(speed)
				callback = speed
				speed = null
				easing = null
			else if Object.IsFunc(easing)
				callback = easing
				easing = null
			if not speed?
				speed = "normal"
			easing or= "ease"
			# duration is always in milliseconds
			duration = $.duration(speed) + _ms
			props = []
			p = 0 # insert marker for props
			# what to send to the -webkit-transform
			trans = emptyString
			# real css values to be set (end_css without the transform values)
			css = {}
			for i of end_css
				# pull all the accelerated values out of end_css
				if accel_props_re.test(i)
					ii = end_css[i]
					if ii.join
						ii = $(ii).px().join(commasep)
					else if ii.toString
						ii = ii.toString()
					trans += space + i + "(" + ii + ")"
				else # stick real css values in the css dict
					css[i] = end_css[i]
			# make a list of the properties to be modified
			for i of css
				props[p++] = i
			# and include -webkit-transform if we have transform values to set
			if trans
				props[p++] = transformProperty

			# sets a list of properties to apply a duration to
			css[transitionProperty] = props.join(commasep)
			# apply the same duration to each property
			css[transitionDuration] =
				props.map(() -> duration)
					.join(commasep)
			# apply an easing function to each property
			css[transitionTiming] =
				props.map(() -> easing)
					.join(commasep)

			# apply the transformation
			if( trans )
				css[transformProperty] = trans
			# apply the css to the actual node
			@css(css)
			# queue the callback to be executed at the end of the animation
			# WARNING: NOT EXACT!
			@delay(duration, callback)

		hide: (callback) ->
			# .hide() - each node gets display:none
			@each () ->
				if @style
					@_display = emptyString
					if @style.display is not _none
						@_display = @syle.display
					@style.display = _none
			.trigger(_hide)
			.delay(updateDelay, callback)

		show: (callback) ->
			# .show() - show each node
			@each () ->
				if @style
					@style.display = @_display
					delete @_display
			.trigger(_show)
			.delay(updateDelay, callback)

		toggle: (callback) ->
			# .toggle() - show each hidden node, hide each visible one
			@weave(@css("display"))
				.fold (display, node) ->
					if display is _none
						node.style.display = node._display or emptyString
						delete node._display
						$(node).trigger(_show)
					else
						node._display = display
						node.style.display = _none
						$(node).trigger(_hide)
					node
				.delay(updateDelay, callback)

		fadeIn: (speed, callback) ->
			# .fadeIn() - fade each node to opacity 1.0
			@.css('opacity','0.0')
				.show () ->
					@transform {
						opacity:"1.0",
						translate3d: [0,0,0]
					}, speed, callback
		fadeOut: (speed, callback, _x = 0.0, _y = 0.0) ->
			# .fadeOut() - fade each node to opacity:0.0
			@transform {
				opacity:"0.0",
				translate3d:[_x,_y,0.0]
			}, speed, () -> @hide(callback)
		fadeLeft: (speed, callback) ->
			# .fadeLeft() - fadeOut and move offscreen to the left
			@fadeOut(speed, callback, "-"+@width().first(), 0.0)
		fadeRight: (speed, callback) ->
			# .fadeRight() - fadeOut and move offscreen to the right
			@fadeOut(speed, callback, @width().first(), 0.0)
		fadeUp: (speed, callback) ->
			# .fadeUp() - fadeOut and move off the top
			@fadeOut(speed, callback, 0.0, "-"+@height().first())
		fadeDown: (speed, callback)  ->
			# .fadeDown() - fadeOut and move off the bottom
			@fadeOut(speed, callback, 0.0, @height().first())
	}

$.plugin () -> # HTTP Request Module: provides wrappers for making http requests
	formencode = (obj) -> # create &foo=bar strings from object properties
		s = []
		j = 0 # insert marker into s
		o = JSON.parse(JSON.stringify(obj)) # quickly remove all non-stringable items
		for i of o
			s[j++] = "#{i}=#{escape o[i]}"
		s.join("&")

	return {
		name: 'Http'
		$http: (url, opts = {}) -> # $.http(/url/, [/opts/]) - fetch /url/ using HTTP (method in /opts/)
			xhr = new XMLHttpRequest()
			if Object.IsFunc(opts)
				opts = {success: Function.Bound(opts, xhr)}
			opts = Object.Extend {
				method: "GET"
				data: null
				state: Function.Empty # onreadystatechange
				success: Function.Empty # onload
				error: Function.Empty # onerror
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

		$post: (url, opts = {}) -> # $.post(/url/, [/opts/]) - fetch /url/ with a POST request
			if Object.IsFunc(opts)
				opts = {success: opts}
			opts.method = "POST"
			$.http(url, opts)

		$get: (url, opts = {}) -> # $.get(/url/, [/opts/]) - fetch /url/ with a GET request
			if( Object.IsFunc(opts) )
				opts = {success: opts}
			opts.method = "GET"
			$.http(url, opts)
	}

$.plugin () -> # Template Module
	match_forward = (text, find, against, start, stop) ->
		count = 1
		if stop == null or stop is -1
			stop = text.length
		for i in [start...stop]
			if text[i] is against
				count += 1
			else if text[i] is find
				count -= 1
			if count is 0
				return i
		return -1

	# the regex for the format specifiers in templates (from python)
	type_re = /([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/
	chunk_re = /%[\(\/]/

	compile = (text) ->
		chunks = text.split chunk_re
		n = chunks.length
		ret = [chunks[0]]
		j = 1 # insert marker into ret
		for i in [1...n]
			end = match_forward chunks[i], ')', '(', 0, -1
			if end is -1
				return "Template syntax error: unmatched '%(' starting at: #{chunks[i].substring(0,15)}"
			key = chunks[i].substring(0, end)
			rest = chunks[i].substring(end)
			match = type_re.exec(rest)
			if match is null
				return "Template syntax error: invalid type specifier starting at '#{rest}'"
			rest = match[4]
			ret[j++] = key
			# the |0 operation coerces to a number,
			# anything that doesnt map becomes 0,
			# so "3" -> 3, "" -> 0, null -> 0, etc.
			ret[j++] = match[1]|0
			ret[j++] = match[2]|0
			ret[j++] = match[3]
			ret[j++] = rest
		return ret
	compile.cache = {}

	render = (text, values) -> # $.render(/t/, /v/) - replace markers in string /t/ with values from /v/
		cache = compile.cache[text] # get the cached version
		if not cache?
			cache = compile.cache[text] = compile(text) # or compile and cache it
		output = [cache[0]] # the first block is always just text
		j = 1 # insert marker into output
		n = cache.length

		# then the rest of the cache items are: [key, pad, fixed, type, text remainder] 5-lets
		for i in [1...n-4] by 5
			key = cache[i]
			# the format in three pieces
			# (\d).\d\w
			pad = cache[i+1]
			# \d.(\d)\w
			fixed = cache[i+2]
			# \d.\d(\w)
			type = cache[i+3]
			# the text remaining after the end of the format
			rest = cache[i+4]
			# the value to render for @ key
			value = values[key]

			# require the value
			if not value?
				value = "missing value: #{key}"

			# format the value according to the format options
			# currently supports 'd', 'f', and 's'
			switch type
				when 'd'
					output[j++] = emptyString + parseInt(value, 10)
				when 'f'
					output[j++] = parseFloat(value).toFixed(fixed)
				# output unsupported formats like %s strings
				# TODO: add support for more formats
				when 's'
					output[j++] = emptyString + value
				else
					output[j++] = emptyString + value
			if pad > 0
				output[j] = String.PadLeft output[j], pad
			output[j++] = rest
		output.join emptyString

	# modes for the synth machine
	TAGMODE = 1
	IDMODE = 2
	CLSMODE = 3
	ATTRMODE = 4
	VALMODE = 5
	DTEXTMODE = 6
	STEXTMODE = 7

	synth = (expr) -> # $.synth(/expr/) - given a CSS expression, create DOM nodes that match
		parent = null
		tagname = emptyString
		id = emptyString
		cls = emptyString
		attr = emptyString
		val = emptyString
		text = emptyString
		attrs = {}
		mode = TAGMODE
		ret = $([])
		i = 0 # i is a marker to read from expr
		ret.selector = expr
		ret.context = document
		emitText = () -> # puts a TextNode in the results
			node = $.HTML.parse text
			if parent
				parent.appendChild node
			else
				ret.push node
			text = emptyString
			mode = TAGMODE
		emitNode = () -> # puts a Node in the results
			node = document.createElement(tagname)
			node.id = id or null
			node.className = cls or null
			for k of attrs
				node.setAttribute k, attrs[k]
			if parent
				parent.appendChild node
			else
				ret.push node
			parent = node
			tagname = emptyString
			id = emptyString
			cls = emptyString
			attr = emptyString
			val = emptyString
			text = emptyString
			attrs = {}
			mode = TAGMODE

		# 'c' steps across the input, one character at a time
		while c = expr[i++]
			if c is '+' and mode is TAGMODE
				if parent
					parent = parent.parentNode
			else if c is '#' and mode in [TAGMODE, CLSMODE, ATTRMODE]
				mode = IDMODE
			else if c is _dot and mode in [TAGMODE, IDMODE, ATTRMODE]
				if cls.length > 0
					cls += space
				mode = CLSMODE
			else if c is _dot and cls.length > 0
				cls += space
			else if c is '[' and mode in [TAGMODE, IDMODE, CLSMODE, ATTRMODE]
				mode = ATTRMODE
			else if c is '=' and mode is ATTRMODE
				mode = VALMODE
			else if c is '"' and mode is TAGMODE
				mode = DTEXTMODE
			else if c is "'" and mode is TAGMODE
				mode = STEXTMODE
			else if c is ']' and mode in [ATTRMODE, VALMODE]
				attrs[attr] = val
				attr = emptyString
				val = emptyString
				mode = TAGMODE
			else if c is '"' and mode is DTEXTMODE
				emitText()
			else if c is "'" and mode is STEXTMODE
				emitText()
			else if c in [space, ','] and mode not in [VALMODE, ATTRMODE] and tagname.length > 0
				emitNode()
				if c is ','
					parent = null
			else if mode is TAGMODE
				if c isnt space
					tagname += c
			else if mode is IDMODE
				id += c
			else if mode is CLSMODE
				cls += c
			else if mode is ATTRMODE
				attr += c
			else if mode is VALMODE
				val += c
			else if mode in [DTEXTMODE, STEXTMODE]
				text += c
			else throw new Error "Unknown input/state: '#{c}'/#{mode}"

		emitNode() if tagname.length > 0
		emitText() if text.length > 0
		return ret

	return {
		name: 'Template'
		$render: render
		$synth: synth

		template: (defaults) ->
			# .template([defaults]) - mark nodes as templates, add optional defaults to .render()
			# if defaults is passed, these will be the default values for v in .render(v)
			@render = (args) ->
				# an over-ride of the basic .render() that applies these defaults
				render(@map($.HTML.stringify).join(emptyString), Object.Extend(defaults,args))
			@remove() # the template item itself should not be in the DOM

		render: (args) ->
			# .render(args) - replace %(var)s-type strings with values from args
			# accepts nodes, returns a string
			render(@map($.HTML.stringify).join(emptyString), args)

		synth: (expr) ->
			# .synth(expr) - create DOM nodes to match a simple css expression
			# supports the following css selectors:
			# tag, #id, .class, [attr=val]
			# and the additional helper "text"
			synth(expr).appendTo @
	}

# vim: ft=coffee
