###

bling.js
--------
Named after the bling symbol ($) to which it is bound by default.
This is a jQuery-like framework, written in CoffeeScript.
Blame: Jesse Dailey <jesse.dailey@gmail.com>
(Copyright) 2011
(License) released under the MIT License
http://creativecommons.org/licenses/MIT/

###

if not document?.querySelectorAll
	alert "This browser is not supported"
	`return`

# local shortcuts
if console?.log
	log = (a...) ->
		console.log.apply(console, a)
else
	log = (a...) ->
		alert a.join(", ")

# constants
COMMASEP = ", "
EVENTSEP_RE = /,* +/
OBJECT_RE = /\[object (\w+)\]/

Bling = (selector, context = document) ->
	type = Object.Type selector
	if type in ["undefined", "null"]
		set = []
	else if type in ["array", "bling", "nodelist"]
		set = selector
	else if type in ["node", "window", "function"]
		set = [ selector ]
	else if type is "number"
		set = new Array selector
	else if type is "string"
		selector = selector.trimLeft()
		if selector[0] is "<"
			set = [Bling.HTML.parse(selector)]
		else if context.querySelectorAll
			set = context.querySelectorAll(selector)
		else
			throw Error "invalid context: #{context} (type: #{Object.Type context})"
	else
		throw Error "invalid selector: #{selector} (type: #{Object.Type selector})"

	# hijack the prototype of the input object
	set.constructor = Bling
	set.__proto__ = Bling.fn
	set.selector = selector
	set.context = context
	# firefox doesn't set the .length properly when we hijack the prototype
	set.length = set.len()
	return set

# Blings extend from arrays
Bling.fn = new Array # a copy! of the Array prototype

Object.Keys = (o, inherited = false) -> # Object.Keys(/o/, [/inherited/]) - get a list of key names
	# by default, does not include properties inherited from a prototype
	keys = []; j = 0
	for i of o
		if inherited or o.hasOwnProperty(i)
			keys[j++] = i
	keys

Object.Extend = (a, b, k) -> # Object.Extend(a, b, [k]) - merge values from b into a
	# if k is present, it should be an array of property names
	if Object::toString.apply(k) is "[object Array]" # cant use Object.IsArray yet
		for i of k
			a[k[i]] = b[k[i]] unless b[k[i]] is undefined
	else
		for i in (k = Object.Keys(b))
			a[i] = b[i]
	a

Object.Extend Object,
	Type: (o) ->
		switch true
			when o is undefined
				"undefined"
			when o is null
				"null"
			when Object.IsString o
				"string"
			when Object.IsType o, Bling
				"bling"
			when Object.IsArray o
				"array"
			when Object.IsType o, NodeList
				"nodelist"
			when Object.IsNumber o
				"number"
			when Object.IsFragment o
				"fragment"
			when Object.IsNode o
				"node"
			when Object.IsFunc o
				"function"
			when Object.IsType o, "RegExp"
				"regexp"
			when String(o) in ["true", "false"]
				"boolean"
			when Object.IsError o
				"error"
			when Object.IsWindow o
				"window"
			when Object.IsObject o
				"object"
	IsType: (o,T) -> # Object.IsType(o,T) - true if object o is of type T (directly or indirectly)
		if o == null
			o is T
		else if o.constructor is T
			true
		else if typeof T is "string"
			o.constructor.name is T or Object::toString.apply(o).replace(OBJECT_RE, "$1") is T
		else
			Object.IsType o.__proto__, T # recurse through sub-classes
	IsString: (o) -> # Object.IsString(a) - true if object a is a string
		o? and (typeof o is "string" or Object.IsType(o, String))
	IsNumber: (o) ->
		o? and Object.IsType o, Number
	IsBoolean: (o) ->
		typeof o is "boolean"
	IsSimple: (o) ->
		Object.IsString(o) or Object.IsNumber(o) or Object.IsBoolean(o)
	IsFunc: (o) -> # Object.IsFunc(a) - true if object a is a function
		o? and (typeof o is "function" or Object.IsType(o, Function)) and o.call?
	IsNode: (o) -> # Object.IsNode(o) - true if object is a DOM node
		o?.nodeType > 0
	IsFragment: (o) -> # Object.IsFragment(o) - true if object is a DocumentFragment node
		o?.nodeType is 11
	IsWindow: (o) -> # Object.IsWindow(o) - true if this is the global object
		"setInterval" of o # same crude method that jQuery uses
	IsArray: (o) -> # Object.IsArray(o) - true if object is an Array (or inherits Array)
		o? and (Object.ToString(o) is "[object Array]" or Object.IsType(o, Array))
	IsBling: (o) ->
		o? and Object.IsType(o, Bling)
	IsError: (o) ->
		o? and o.constructor?.name is "Error"
	IsObject: (o) -> # Object.IsObject(o) - true if a is an object
		o? and typeof o is "object"
	IsDefined: (o) -> # Object.IsDefined(o) - true if a is not null nor undefined
		o?
	Unbox: (a) -> # Object.Unbox(o) - primitive types can be 'boxed' in an object
		if a? and Object.IsObject(a)
			return a.toString() if Object.IsString a
			return Number(a) if Object.IsNumber a
		a
	ToString: (x) ->
		Object::toString.apply(x)

Object.Extend Function,
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
	Trace: (f, label, tracer = log) -> # Function.Trace(/f/, /label/) - log calls to /f/
		r = (a...) ->
			tracer "#{@name or Object.Type(@)}.#{label or f.name}(", a, ")"
			f.apply @, a
		tracer "Function.Trace: #{label or f.name} created."
		r.toString = f.toString
		r
	NotNull: (x) -> x != null
	NotEmpty: (x) -> x not in ["", null]
	IndexFound: (x) -> x > -1
	ReduceAnd: (x) -> x and @
	UpperLimit: (x) -> (y) -> Math.min(x, y)
	LowerLimit: (x) -> (y) -> Math.max(x, y)
	Px: (d) -> () -> Number.Px(@,d)

Object.Extend String,
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
		@clear    = ( ) => items = []; @length = 0
		@toString = ( ) => items.join("")
		@

Object.Extend Array,
	Coalesce: (a...) -> # Array.Coalesce - returns the first non-null argument
		if Object.IsArray(a[0])
			Array.Coalesce a[0]...
		else
			for i in a
				return i if i?
	Extend: (a, b) -> # Array.Extend - pushes each item from b into a
		j = a.length
		for i in b
			a[j++] = i
		a
	Compact: (a, buffer = new String.Builder(), into = [], topLevel = true) -> # Array.Compact reduces /a/ by joining adjacent stringy items
		if not Object.IsArray(a)
			return a
		for i in a
			switch true
				when not Object.IsDefined(i) then continue
				when Object.IsSimple(i) then buffer.append(i)
				when Object.IsArray(i) then Array.Compact(i, buffer, into, false)
				else
					into.push buffer.toString() if buffer.length > 0
					into.push i
					buffer.clear()
		if into.length is 0
			return buffer.toString()
		if buffer.length > 0 and topLevel
			into.push buffer.toString()
			buffer.clear()
		return into

Object.Extend Number,
	Px: (x, d=0) -> # Px(/x/, /delta/=0) - convert a number-ish x to pixels
		x? and (parseInt(x,10)+(d|0))+"px"
	AtLeast: (x) -> # mappable version of max()
		(y) ->
			Math.max parseFloat(y or 0), x
	AtMost: (x) -> # mappable version of min()
		(y) ->
			Math.min parseFloat(y or 0), x


Object.Extend Event,
	Cancel: (evt) ->
		evt.stopPropagation()
		evt.preventDefault()
		evt.cancelBubble = true
		evt.returnValue = false
	Prevent: (evt) ->
		evt.preventDefault()
	Stop: (evt) ->
	 evt.stopPropagation()
	 evt.cancelBubble = true

(($) -> # protected name space

	$.plugins = []

	$.plugin = (constructor) ->
		try
			name = constructor.name
			plugin = constructor.call $,$
			name = name or plugin.name
			if not name
				throw Error "plugin requires a 'name'"
			$.plugins.push(name)
			$.plugins[name] = plugin
			delete plugin.name
			# if a plugin defines globals, extend Bling
			if plugin[Bling.symbol]
				Object.Extend(Bling, plugin[Bling.symbol])
				# clear off the globals
				delete plugin[Bling.symbol]
			# everything else about the plugin extends the prototype
			Object.Extend(Bling.fn, plugin)
		catch error
			log "failed to load plugin #{name}"
			# log error.message
			throw error

	$.plugin () -> # Symbol - allow to safely use something other than $ by assigning to Bling.symbol
		symbol = null
		preserve = {}
		$.__defineSetter__ "symbol", (v) ->
			if symbol of preserve
				window[symbol] = preserve[symbol]
			if v of window
				preserve[v] = window[v]
			symbol = v
			window[v] = Bling
		$.__defineGetter__ "symbol", () -> symbol
		$.symbol = "$"
		window["Bling"] = Bling

		return {
			name: "Symbol"
		}

	$.plugin () -> # Compat - compatibility patches
		leftSpaces_re = /^\s+/
		String::trimLeft = Array.Coalesce(
			String::trimLeft,
			() -> @replace(leftSpaces_re, "")
		)

		String::split = Array.Coalesce(
			String::split,
			(sep) ->
				a = []; n = 0; i = 0
				while (j = @indexOf sep,i) > -1
					a[n++] = @substring(i+1,j+1)
					i = j + 1
				a
		)

		Array::join = Array.Coalesce(
			Array::join,
			(sep = '') ->
				n = @length
				return "" if n is 0
				s = @[n-1]
				while --n > 0
					s = @[n-1] + sep + s
				s
		)

		Element::matchesSelector = Array.Coalesce(
			Element::webkitMatchesSelector,
			Element::mozMatchesSelector,
			Element::matchesSelector
		)

		oldToString = Element::toString
		Element::toString = (css_mode) ->
			if css_mode
				name = @nodeName.toLowerCase()
				if @id?
					name += "##{@id}"
				else if @className?
					name += ".#{@className.split(" ").join(".")}"
				name
			else
				oldToString.apply @

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
		class TimeoutQueue extends Array # (new TimeoutQueue).schedule(f, 10);
			# TimeoutQueue works like setTimeout but enforces strictness on the order
			# (still has the same basic timing inaccuracy, but will always fire
			# callbacks in the order they were originally scheduled.)
			constructor: () ->
				next = () => # next() consumes the next handler on the queue
					if @length > 0
						@shift()() # shift AND call
				@schedule = (f, n) => # schedule(f, n) sets f to run after n or more milliseconds
					if not Object.IsFunc(f)
						throw Error "function expected, got: #{typeof f}"
					nn = @length
					f.order = n + new Date().getTime()
					if nn is 0 or f.order > @[nn-1].order # short-cut the common-case: f belongs after the end
						@push(f)
					else
						for i in [0...nn]
							if @[i].order > f.order
								@splice(i, 0, f)
								break
					setTimeout next, n
					return @
				@cancel = (f) =>
					if not Object.IsFunc(f)
						throw Error "function expected, got #{Object.Type(f)}"
					for i in [0...@length]
						if @[i] == f
							@splice(i, 1)
							break
		timeoutQueue = new TimeoutQueue

		getter = (prop) -> # used in .zip()
			() ->
				v = @[prop]
				if Object.IsFunc v
					return Function.Bound(v, @)
				return v
		zipper = (prop) -> # used in .zip()
			i = prop.indexOf(".")
			if i > -1
				return @zip(prop.substr(0, i)).zip(prop.substr(i+1))
			return @map getter(prop)

		return {
			name: 'Core'

			$:
				log: log
				delay: (n, f) ->
					if f
						timeoutQueue.schedule(f, n)
					# return an actor that can cancel
					return { cancel: () -> timeoutQueue.cancel(f) }

			eq: (i) -> # .eq(/i/) - a new set containing only the /i/th item
				a = $([@[i]])
				a.context = @
				a.selector = () -> a.context.eq(i)
				a

			each: (f) -> # .each(/f/) - apply function /f/ to every item /x/ in _this_.
				for i in @
					f.call(i, i)
				@

			map: (f) -> # .map(/f/) - collect /f/.call(/x/, /x/) for every item /x/ in _this_.
				a = $()
				a.context = @
				a.selector = () -> a.context.map(f)
				nn = @len()
				for i in [0...nn]
					t = @[i]
					# try
					a[i] = f.call t,t
					# catch err
					# a[i] = err
				a

			reduce: (f, init) ->
				# .reduce(/f/, [/init/]) - accumulate a = /f/(a, /x/) for /x/ in _this_.
				# along with respecting the context, we pass only the accumulation and one argument
				# so you can use functions like Math.min directly $([1,2,3]).reduce(Math.min)
				# this fails with the ECMA reduce, since Math.min(a,x,i,items) is NaN
				a = init
				t = @
				if not init?
					a = @[0]
					t = @skip(1)
				t.each () ->
					a = f.call(@, a, @)
				a

			union: (other, strict = true) ->
				# .union(/other/) - collect all /x/ from _this_ and /y/ from _other_.
				# no duplicates, use .concat() if you want to preserve dupes
				# 'strict' forces === comparison
				ret = $()
				x = i = j = 0
				ret.context = @
				ret.selector = () -> ret.context.union(other, strict)
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
				ret.context = @
				ret.selector = () -> ret.context.intersect(other)
				for i in [0...n]
					for j in [0...nn]
						if @[i] is other[j]
							ret[m++] = @[i]
							break
				ret

			distinct: (strict = true) ->
				# .distinct() - a copy of _this_ without duplicates.
				# 'strict' forces === comparison
				@union(@, strict)

			contains: (item, strict = true) ->
				# .contains(/x/) - true if /x/ is in _this_, false otherwise.
				# 'strict' forces === comparison
				for t in @
					if (strict and t is item) or (not strict and t == item)
						return true
				return false

			count: (item, strict = true) ->
				# .count(/x/) - returns how many times /x/ occurs in _this_.
				# since we want to be able to search for null values with .count(null)
				# but if you just call .count(), it returns the total length
				# 'strict' forces === comparison
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
						return zipper.call(@, a[0])
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
				else if Object.IsFunc(v)
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
				a.context = @
				a.selector = () -> a.context.take(n)
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
				a.context = @
				a.selector = () -> a.context.skip(n)
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
				b.context = @
				b.selector = () -> b.context.slice(start, end)
				for i in [start...end]
					b[j++] = @[i]
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
				b = $()
				b.context = @
				b.selector = () -> b.context.filter(f)
				switch Object.Type f
					when "string"
						g = (x) -> x.matchesSelector(f)
					when "regexp"
						g = (x) -> f.test(x)
					when "function"
						g = f
					else
						throw new Error("unsupported type passed to filter: #{Object.Type(f)}")
				j = 0
				for it in @
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
				c.context = @
				c.selector = () -> c.context.weave(b)
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
				b.selector = () -> b.context.fold(f)
				for i in [0...n-1] by 2
					b[j++] = f.call @, @[i], @[i+1]
				# if there is an odd man out, make one last call
				if (n%2) is 1
					b[j++] = f.call @, @[n-1], undefined
				b

			flatten: () -> # .flatten() - collect the union of all sets in _this_
				b = $()
				b.context = @
				b.selector = () -> b.context.flatten()
				n = @len()
				k = 0 # insert marker
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
					t = Object.Type(@)
					if t in ["undefined","null","window"]
						t
					else
						@toString().replace(OBJECT_RE,"$1")
				.join(COMMASEP) + "])"

			delay: (n, f) -> # .delay(/n/, /f/) -  continue with /f/ on _this_ after /n/ milliseconds
				if f
					g = Function.Bound(f, @)
					timeoutQueue.schedule g, n
					@.cancel = () -> timeoutQueue.cancel g
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
		}

	$.plugin () -> # Html plugin
		before = (a,b) -> # insert b before a
			# create a fragment if parent node is null
			if not a.parentNode?
				df = document.createDocumentFragment()
				df.appendChild(a)
			a.parentNode.insertBefore b, a

		after = (a,b) -> # insert b after a
			if not a.parentNode?
				df = document.createDocumentFragment()
				df.appendChild(a)
			a.parentNode.insertBefore b, a.nextSibling

		toNode = (x) -> # convert nearly anything to something node-like for use in the DOM
			switch Object.Type x
				when "fragment" then x
				when "node" then x
				when "bling" then x.toFragment()
				when "string" then $(x).toFragment()
				when "function" then $(x.toString()).toFragment()
				else
					throw new Error "toNode called with invalid argument: #{x} (type: #{Object.Type x})"

		escaper = null

		getCSSProperty = (k) ->
			# window.getComputedStyle is not a normal function
			# (it doesnt support .call() so we can't use it with .map())
			# so define something that does work properly for use in .css
			() ->
				window.getComputedStyle(@, null).getPropertyValue(k)

		# get some ordinal constants and give them safe names
		ord_A = "A".charCodeAt(0)
		ord_Z = "Z".charCodeAt(0)
		ord_a = "a".charCodeAt(0)

		# convert between dash-names and camelNames
		dashName = (name) ->
			ret = ""
			for i in [0...(name?.length|0)]
				c = name.charCodeAt i
				if ord_Z >= c >= ord_A # is upper case
					c = (c - ord_A) + ord_a # shift to lower
					ret += '-'
				ret += String.fromCharCode(c)
			return ret
		camelName = (name) ->
			i = name?.indexOf('-')
			while i > -1
				name = String.Splice(name, i, i+2, name[i+1].toUpperCase())
				i = name.indexOf('-')

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
				dashName: dashName
				camelName: camelName

			html: (h) -> # .html([h]) - get [or set] /x/.innerHTML for each node
				switch Object.Type h
					when "undefined"
						return @zip 'innerHTML'
					when "string"
						return @zap 'innerHTML', h
					when "bling"
						return @html h.toFragment()
					when "node"
						return @each () -> # replace all our children with the new child
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
				k = "data-#{dashName(k)}"
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
					@className = @className?.split(" ").filter(notx).join(" ")

			toggleClass: (x) -> # .toggleClass(/x/) - add, or remove if present, class x from each node
				notx = (y) -> y != x
				@each () ->
					cls = @className.split(" ")
					if( cls.indexOf(x) > -1 )
						@className = cls.filter(notx).join(" ")
					else
						cls.push(x)
						@className = cls.filter(Function.NotEmpty).join(" ")

			hasClass: (x) -> # .hasClass(/x/) - true/false for each node: whether .className contains x
				@zip('className.split').call(" ").zip('indexOf').call(x).map Function.IndexFound

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
				style = ""
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

	$.plugin () -> # Math plugin
		name: 'Maths'
		$:
			range: (start, end, step = 1) ->
				i = start
				if step == 0 or (step > 0 and start > end) or (step < 0 and start < end)
					return []
				while (start > end and i > end) or ( start < end and i < end )
					a = i
					i += step
					a
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
			@reduce (a) -> Math.min @, a

		max: () ->
			# .max() - select the largest /x/ in _this_
			@reduce (a) -> Math.max @, a

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
			Math.sqrt @floats().squares().sum()

		scale: (r) ->
			# .scale(/r/) - /x/ *= /r/ for /x/ in _this_
			@map () -> r * @

		normalize: () ->
			# .normalize() - scale _this_ so that .magnitude() == 1
			@scale(1/@magnitude())

	$.plugin () -> # Events plugin
		events = ['mousemove','mousedown','mouseup','mouseover','mouseout','blur','focus',
			'load','unload','reset','submit','keyup','keydown','change',
			'abort','cut','copy','paste','selection','drag','drop','orientationchange',
			'touchstart','touchmove','touchend','touchcancel',
			'gesturestart','gestureend','gesturecancel',
			'hashchange'
		] # 'click' is handled specially

		binder = (e) ->
			(f = {}) ->
				return @bind(e, f) if Object.IsFunc f
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
			bind: (e, f) ->
				# .bind(e, f) - adds handler f for event type e
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

			unbind: (e, f) ->
				# .unbind(e, [f]) - removes handler f from event e
				# if f is not present, removes all handlers from e
				c = (e or "").split(EVENTSEP_RE)
				@each () ->
					for i in c
						@removeEventListener(i, f, null)

			once: (e, f) ->
				# .once(e, f) - adds a handler f that will be called only once
				c = (e or "").split(EVENTSEP_RE)
				for i in c
					@bind i, (evt) ->
						f.call(@, evt)
						@removeEventListener(evt.type, arguments.callee, null)

			cycle: (e, funcs...) ->
				# .cycle(e, ...) - bind handlers for e that trigger in a cycle
				# one call per trigger. when the last handler is executed
				# the next trigger will call the first handler again
				c = (e or "").split(EVENTSEP_RE)
				nf = funcs.length
				cycler = () ->
					i = 0
					(evt) ->
						funcs[i].call(@, evt)
						i = ++i % nf
				for j in c
					@bind j, cycler()
				@

			trigger: (evt, args = {}) ->
				# .trigger(e, a) - initiates a fake event
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
							@each () ->
								@dispatchEvent e
						catch err
							log("dispatchEvent error:",err)
				@

			live: (e, f) ->
				# .live(e, f) - handle events for nodes that will exist in the future
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
				selector = @selector
				context = @context
				h = unregister_live selector, context, e, f
				$(context).unbind e, h
				@

			liveCycle: (e, funcs...) ->
				# .liveCycle(e, ...) - bind each /f/ in /funcs/ to handle /e/
				# one call per trigger. when the last handler is executed
				# the next trigger will call the first handler again
				i = 0
				@live e, (evt) ->
					funcs[i].call @, evt
					i = ++i % funcs.length

			click: (f = {}) ->
				# .click([f]) - trigger [or bind] the 'click' event
				# if the cursor is just default then make it look clickable
				if @css("cursor").intersect(["auto",""]).len() > 0
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
						@bind "ready", f
				else
					@trigger "ready", f
		}

		# add event binding/triggering shortcuts for the generic events
		events.forEach (x) ->
			ret[x] = binder(x)
		return ret

	$.plugin () -> # Transform plugin, for accelerated animations
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
				duration: (speed) ->
					# $.duration(/s/) - given a speed description (string|number), a number in milliseconds
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
			fadeLeft: (speed, callback) -> # .fadeLeft() - fadeOut and move offscreen to the left
				@fadeOut(speed, callback, "-"+@width().first(), 0.0)
			fadeRight: (speed, callback) -> # .fadeRight() - fadeOut and move offscreen to the right
				@fadeOut(speed, callback, @width().first(), 0.0)
			fadeUp: (speed, callback) -> # .fadeUp() - fadeOut and move off the top
				@fadeOut(speed, callback, 0.0, "-"+@height().first())
			fadeDown: (speed, callback)  -> # .fadeDown() - fadeOut and move off the bottom
				@fadeOut(speed, callback, 0.0, @height().first())
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

				post: (url, opts = {}) -> # $.post(/url/, [/opts/]) - fetch /url/ with a POST request
					if Object.IsFunc(opts)
						opts = {success: opts}
					opts.method = "POST"
					$.http(url, opts)

				get: (url, opts = {}) -> # $.get(/url/, [/opts/]) - fetch /url/ with a GET request
					if( Object.IsFunc(opts) )
						opts = {success: opts}
					opts.method = "GET"
					$.http(url, opts)
			}
		}

	$.plugin () -> # Hash plugin
		return {
			name: "Hash"
			$:
				hash: (x) -> # .hash() - return a hash-code for the set
					h = 0
					for i in x
						h += switch Object.Type(i)
							when "string" then String.Checksum(i)
							when "number" then String.Checksum(String(i))
							when "bling" then $.hash(i)
							when "array" then $.hash(i)
							when "nodelist" then $.hash(i)
							when "object" then String.Checksum(i.toString())
		}

	$.plugin () -> # Memoize plugin, depends on Hash plugin
		return {
			name: "Memoize"
			$:
				memoize: (f) ->
					cache = {}
					(a...) ->
						cache[$.hash(a)] ?= f.apply @, a
		}

	$.plugin () -> # StateMachine plugin
		class StateMachine
			constructor: (stateTable) ->
				@reset()
				@table = stateTable
				@.__defineGetter__ "modeline", () -> @table[@_mode]
				@.__defineSetter__ "mode", (m) ->
					@_lastMode = @_mode
					@_mode = m
					if @_mode isnt @_lastMode and 'enter' of @modeline
						ret = @modeline['enter'].call @
						while Object.IsFunc(ret)
							ret = ret.call @
				@.__defineGetter__ "mode", () -> @_mode

			reset: () ->
				@_mode = null
				@_lastMode = null

			# static and instance versions of a state-changer factory
			GO: (m) -> () -> @mode = m
			@GO: (m) -> () -> @mode = m

			run: (input) ->
				@mode = 0
				for c in input
					row = @modeline
					if c of row
						ret = row[c]
					else if 'def' of row
						ret = row['def']
					while Object.IsFunc(ret)
						ret = ret.call @, c
				if 'eof' of @modeline
					ret = @modeline['eof'].call @
				while Object.IsFunc(ret)
					ret = ret.call @
				@reset()
				return @
		return {
			name: "StateMachine"
			$:
				StateMachine: StateMachine
		}

	$.plugin () -> # Synth plugin, depends on StateMachine
		class SynthMachine extends $.StateMachine
			@STATE_TABLE = [
				{ # 0: START
					enter: () ->
						@tag = @id = @cls = @attr = @val = @text = ""
						@attrs = {}
						@GO(1)
				},
				{ # 1: read a tag name
					'"': @GO(6), "'": @GO(7), "#": @GO(2), ".": @GO(3), "[": @GO(4), " ": @GO(9), "+": @GO(11), ",": @GO(10),
					def: (c) -> @tag += c
					eof: @GO(13)
				},
				{ # 2: read an #id
					".": @GO(3), "[": @GO(4), " ": @GO(9), "+": @GO(11), ",": @GO(10),
					def: (c) -> @id += c
					eof: @GO(13)
				},
				{ # 3: read a .class name
					enter: () -> @cls += " " if @cls.length > 0
					"#": @GO(2), ".": @GO(3), "[": @GO(4), " ": @GO(9), "+": @GO(11), ",": @GO(10),
					def: (c) -> @cls += c
					eof: @GO(13)
				},
				{ # 4: read an attribute name (left-side)
					"=": @GO(5)
					"]": () -> @attrs[@attr] = @val; @GO(1)
					def: (c) -> @attr += c
					eof: @GO(12)
				},
				{ # 5: read an attribute value (right-side)
					"]": () -> @attrs[@attr] = @val; @GO(1)
					def: (c) -> @val += c
					eof: @GO(12)
				},
				{ # 6: read d-quoted text
					'"': @GO(8)
					def: (c) -> @text += c
					eof: @GO(12)
				},
				{ # 7: read s-quoted text
					"'": @GO(8)
					def: (c) -> @text += c
					eof: @GO(12)
				},
				{ # 8: emit text and continue
					enter: () ->
						@emitText()
						@GO(0)
				},
				{ # 9: emit node and descend
					enter: () ->
						@emitNode()
						@GO(0)
				},
				{ # 10: emit node and start a new tree
					enter: () ->
						@emitNode()
						@parent = null
						@GO(0)
				},
				{ # 11: emit node and step sideways to create a sibling
					enter: () ->
						@emitNode()
						@parent = @parent?.parentNode
						@GO(0)
				},
				{ # 12: ERROR
					enter: () -> $.log "Error in synth expression: #{@input}"
				},
				{ # 13: FINALIZE
					enter: () ->
						@emitNode() if @tag.length
						@emitText() if @text.length
				}
			]
			constructor: () ->
				super(SynthMachine.STATE_TABLE)
				@fragment = @parent = document.createDocumentFragment()
			emitNode: () ->
				node = document.createElement(@tag)
				node.id = @id or null
				node.className = @cls or null
				for k of @attrs
					node.setAttribute k, @attrs[k]
				@parent.appendChild node
				@parent = node
			emitText: () ->
				@parent.appendChild $.HTML.parse(@text)
				@text = ""

		return {
			name: "Synth"
			$:
				synth: (expr) ->
					# .synth(expr) - create DOM nodes to match a simple css expression
					s = new SynthMachine()
					s.run(expr)
					if s.fragment.childNodes.length == 1
						$(s.fragment.childNodes[0])
					else
						$(s.fragment)
		}

	$.plugin () -> # Pub/Sub plugin
		subscribers = {} # a mapping of channel name to a list of subscribers
		archive = {} # archive published events here, so they can be replayed if necessary
		archive_limit = 1000 # maximum number of events (per type) to archive
		archive_trim = 100 # how much to trim all at once if we go over the maximum

		publish = (e, args = []) ->
			$.log "published: #{e}", args
			archive[e] ?= []
			archive[e].push(args)
			if archive[e].length > archive_limit
				archive[e].splice(0, archive_trim)
			for func in subscribers[e]
				func.apply null, args
			@

		subscribe = (e, func, replay = true) ->
			subscribers[e] ?= []
			subscribers[e].push(func)
			if replay # replay the publish archive
				for args in archive[e]
					$.log "replayed: #{e}", args
					func.apply null, args
			func

		unsubscribe = (e, func) ->
			if not func?
				subscribers[e] = []
			else
				i = subscribers[e]?.indexOf(func)
				if i > -1
					subscribers[e].splice(i,i)

		# expose these for advanced users
		publish.__defineSetter__ 'limit', (n) ->
			archive_limit = n
			# enforce the new limit immediately
			for e of archive
				if archive[e].length > archive_limit
					archive[e].splice(0, archive_trim)
		publish.__defineSetter__ 'trim', (n) ->
			archive_trim = n

		return {
			name: "PubSub"
			$:
				publish: publish
				subscribe: subscribe
				unsubscribe: unsubscribe
		}

	$

)(Bling)
# vim: ft=coffee
