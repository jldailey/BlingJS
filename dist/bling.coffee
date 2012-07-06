log = (a...) ->
	try return console.log.apply console, a
	alert a.join(", ")
Object.keys ?= (o) -> (k for k of o)
extend = (a, b) ->
	return a if not b
	for k of b
		v = b[k]
		if v? then a[k] = v
	a
defineProperty = (o,name,opts) ->
	Object.defineProperty o,name, extend({
		configurable: true
		enumerable: true
	}, opts)
	o
isType = (T, o) ->
	if not o? then T in [o,"null","undefined"]
	else o.constructor is T or
		o.constructor.name is T or
		Object::toString.apply(o) is "[object #{T}]" or
		isType T, o.__proto__ # recursive
inherit = (parent, obj) ->
	if typeof parent is "function"
		obj.constructor = parent
		parent = parent:: # so that the obj instance will inherit all of the prototype (but _not a copy_ of it).
	obj.__proto__ = parent
	obj
type = (->
	cache = {}
	base =
		name: 'unknown'
		match: (o) -> true
	order = []
	register = (name, data) ->
		order.unshift name if not (name of cache)
		cache[data.name = name] = if (base isnt data) then (inherit base, data) else data
	_extend = (name, data) ->
		if typeof name is "string"
			cache[name] ?= register name, {}
			cache[name] = extend cache[name], data
		else if typeof name is "object"
			(_extend k, name[k]) for k of name
	lookup = (obj) ->
		for name in order
			if cache[name]?.match.call obj, obj
				return cache[name]
	register "unknown",   base
	register "object",    match: -> typeof @ is "object"
	register "error",     match: -> isType 'Error', @
	register "regexp",    match: -> isType 'RegExp', @
	register "string",    match: -> typeof @ is "string" or isType String, @
	register "number",    match: -> isType Number, @
	register "bool",      match: -> typeof @ is "boolean" or String(@) in ["true","false"]
	register "array",     match: -> Array.isArray?(@) or isType Array, @
	register "function",  match: -> typeof @ is "function"
	register "global",    match: -> typeof @ is "object" and 'setInterval' of @ # Use the same crude method as jQuery for detecting the window, not very safe but it does work in Node and the browser
	register "undefined", match: (x) -> x is undefined
	register "null",      match: (x) -> x is null
	return extend ((o) -> lookup(o).name),
		register: register
		lookup: lookup
		extend: _extend
		is: (t, o) -> cache[t]?.match.call o, o
)()
class Bling
	pipes = {}
	@pipe: (name, args) ->
		p = (pipes[name] or= [])
		if not args
			return {
				prepend: (obj) -> p.unshift(obj); obj
				append: (obj) -> p.push(obj); obj
			}
		for func in p
			args = func.call @, args
		args
	@pipe("bling-init").prepend (args) ->
		[selector, context] = args
		inherit Bling, extend type.lookup(selector).array(selector, context),
			selector: selector
			context: context
	default_context = if document? then document else {}
	constructor: (selector, context = default_context) -> return Bling.pipe("bling-init", [selector, context])
	@plugin: (opts, constructor) ->
		if not constructor?
			constructor = opts; opts = {}
		if "depends" of opts
			return @depends opts.depends, =>
				@plugin { provides: opts.provides }, constructor
		try
			if (plugin = constructor?.call @,@)
				extend @, plugin?.$
				['$','name'].forEach (k) -> delete plugin[k]
				extend @::, plugin
				for key of plugin
					((key) =>
						@[key] or= (a...) => (@::[key].apply $(a[0]), a[1...])
					)(key)
				if opts.provides? then @provide opts.provides
		catch error
			log "failed to load plugin: #{@name} '#{error.message}'"
			throw error
		@
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
		for need in filt(needs)
			done[need] = i = 0
			while i < qu.length
				if (f = qu[i](need)) then (qu.splice i,1; f())
				else i++
		null
	@provides: (needs, f) -> (a...) -> r=f(a...); Bling.provide(needs); r
	type.extend
		unknown:   { array: (o) -> [o] }
		null:      { array: (o) -> [] }
		undefined: { array: (o) -> [] }
		array:     { array: (o) -> o }
		number:    { array: (o) -> Bling.extend new Array(o), length: 0 }
	type.register "bling",
		match:  (o) -> o and isType Bling, o
		array:  (o) -> o.toArray()
		hash:   (o) -> o.map(Bling.hash).sum()
		string: (o) -> Bling.symbol + "([" + o.map((x) -> $.type.lookup(x).string(x)).join(", ") + "])"
		repr: (o) -> Bling.symbol + "([" + o.map((x) -> $.type.lookup(x).repr(x)).join(", ") + "])"
Bling.prototype = []
(($) ->
	$.global = glob = if window? then window else global
	$.plugin
		provides: "type"
	, ->
		$:
			inherit: inherit
			extend: extend
			defineProperty: defineProperty
			isType: isType
			type: type
			is: type.is
			isSimple: (o) -> type(o) in ["string", "number", "bool"]
			isEmpty: (o) -> o in ["", null, undefined]
	$.plugin
		provides: "symbol"
		depends: "type"
	, ->
		symbol = null
		cache = {}
		glob.Bling = $
		$.type.extend "bling",
			string: (o) -> symbol + "(["+ o.map($.toString).join(", ") + "])"
		defineProperty $, "symbol",
			set: (v) ->
				glob[symbol] = cache[symbol]
				cache[symbol = v] = glob[v]
				glob[v] = Bling
			get: -> symbol
		return $: symbol: "$"
	$.plugin ->
		String::trimLeft or= -> @replace(/^\s+/, "")
		String::split or= (sep) ->
			a = []; i = 0
			while (j = @indexOf sep,i) > -1
				a.push @substring(i,j)
				i = j + 1
			a
		String::lastIndexOf or= (s, c, i = -1) ->
			j = -1
			j = i while (i = s.indexOf c, i+1) > -1
			j
		Array::join or= (sep = '') ->
			n = @length
			return "" if n is 0
			s = @[n-1]
			while --n > 0
				s = @[n-1] + sep + s
			s
		if Event?
			Event::preventAll = () ->
				@preventDefault()
				@stopPropagation()
				@cancelBubble = true
		if Element?
			Element::matchesSelector = Element::webkitMatchesSelector or
				Element::mozMatchesSelector or
				Element::matchesSelector
			if Element::cloneNode.length is 0
				oldClone = Element::cloneNode
				Element::cloneNode = (deep = false) ->
					n = oldClone.call(@)
					if deep
						for i in @childNodes
							n.appendChild i.cloneNode true
					return n
		return { }
	$.plugin
		provides: "delay"
		depends: "function"
	, ->
		$:
			delay: (->
				timeoutQueue = $.extend [], (->
					next = (a) -> -> a.shift()() if a.length
					add: (f, n) ->
						f.order = n + $.now
						for i in [0..@length]
							if i is @length or @[i].order > f.order
								@splice i,0,f
								break
						setTimeout next(@), n
						@
					cancel: (f) ->
						for i in [0...@length]
							if @[i] == f
								@splice i, 1
								break
						@
				)()
				(n, f) ->
					if $.is("function",f) then timeoutQueue.add(f, n)
					cancel: -> timeoutQueue.cancel(f)
			)()
		delay: (n, f, c=@) ->
			$.delay n, $.bound(c, f)
	$.plugin
		provides: "core"
		depends: "type"
	, ->
		defineProperty $, "now",
			get: -> +new Date
		index = (i, o) ->
			i += o.length while i < 0
			Math.min i, o.length
		return {
			$:
				log: log
				assert: (c, m="") -> if not c then throw new Error("assertion failed: #{m}")
				coalesce: (a...) -> $(a).coalesce()
			eq: (i) -> $([@[index i, @]])
			each: (f) -> (f.call(t,t) for t in @); @
			map: (f) -> $(f.call(t,t) for t in @)
			reduce: (f, a) ->
				i = 0; n = @length
				a = @[i++] if not a?
				(a = f.call @[x], a, @[x]) for x in [i...n] by 1
				return a
			union: (other, strict = true) ->
				ret = $()
				ret.push(x) for x in @ when not ret.contains(x, strict)
				ret.push(x) for x in other when not ret.contains(x, strict)
				ret
			distinct: (strict = true) -> @union @, strict
			intersect: (other) -> $(x for x in @ when x in other) # another very beatiful expression
			contains: (item, strict = true) -> ((strict and t is item) or (not strict and t == item) for t in @).reduce ((a,x) -> a or x), false
			count: (item, strict = true) -> $(1 for t in @ when (item is undefined) or (strict and t is item) or (not strict and t == item)).sum()
			coalesce: ->
				for i in @
					if $.type(i) in ["array","bling"] then i = $(i).coalesce()
					if i? then return i
				null
			swap: (i,j) ->
				i = index i, @
				j = index j, @
				if i isnt j
					[@[i],@[j]] = [@[j],@[i]]
				@
			shuffle: ->
				i = @length-1
				while i >= 0
					@swap --i, Math.floor(Math.random() * i)
				@
			select: (->
				getter = (prop) -> -> if $.is("function",v = @[prop]) then $.bound(@,v) else v
				select = (p) ->
					if (i = p.indexOf '.') > -1 then @select(p.substr 0,i).select(p.substr i+1)
					else @map(getter p)
			)()
			or: (x) -> @[i] or= x for i in [0...@length]; @
			zap: (p, v) ->
				i = p.lastIndexOf "."
				if i > 0
					head = p.substr 0,i
					tail = p.substr i+1
					@select(head).zap tail, v
					return @
				switch $.type(v)
					when "array","bling" then @each -> @[p] = v[++i % v.length]
					when "function" then @zap p, @select(p).map(v)
					else @each -> @[p] = v
				@
			take: (n = 1) ->
				end = Math.min n, @length
				$( @[i] for i in [0...end] )
			skip: (n = 0) ->
				start = Math.max 0, n|0
				$( @[i] for i in [start...@length] )
			first: (n = 1) -> if n is 1 then @[0] else @take(n)
			last: (n = 1) -> if n is 1 then @[@length - 1] else @skip(@length - n)
			slice: (start=0, end=@length) ->
				start = index start, @
				end = index end, @
				$( @[i] for i in [start...end] )
			extend: (b) -> @.push(i) for i in b; @
			push: (b) -> Array::push.call(@, b); @
			filter: (f) ->
				g = switch $.type f
					when "string" then (x) -> x.matchesSelector(f)
					when "regexp" then (x) -> f.test(x)
					when "function" then f
					else
						throw new Error("unsupported type passed to filter: #{$.type(f)}")
				$( Array::filter.call @, g )
			matches: (expr) -> @select('matchesSelector').call(expr)
			querySelectorAll: (expr) ->
				@filter("*")
				.reduce (a, i) ->
					a.extend i.querySelectorAll expr
				, $()
			weave: (b) ->
				c = $()
				for i in [@length-1..0] by -1
					c[(i*2)+1] = @[i]
				for i in [0...b.length] by 1
					c[i*2] = b[i]
				c
			fold: (f) ->
				n = @length
				b = $( f.call @, @[i], @[i+1] for i in [0...n-1] by 2 )
				if (n%2) is 1
					b.push( f.call @, @[n-1], undefined )
				b
			flatten: ->
				b = $()
				(b.push(j) for j in i) for i in @
				b
			call: -> @apply(null, arguments)
			apply: (context, args) ->
				@map -> if $.is "function", @ then @apply(context, args) else @
			log: (label) ->
				if label
					$.log(label, @toString(), @length + " items")
				else
					$.log(@toString(), @length + " items")
				@
			toArray: -> (@.__proto__ = Array::); @ # no copies, yay?
		}
	$.plugin
		provides: "math"
		depends: "core"
	, ->
		$:
			range: (start, end, step = 1) ->
				if not end? then (end = start; start = 0)
				step *= -1 if end < start and step > 0 # force step to have the same sign as start->end
				$( (start + (i*step)) for i in [0...Math.ceil( (end - start) / step )] )
			zeros: (n) -> $( 0 for i in [0...n] )
			ones: (n) -> $( 1 for i in [0...n] )
		floats: -> @map parseFloat
		ints: -> @map -> parseInt @, 10
		px: (delta) -> @ints().map -> $.px @,delta
		min: -> @filter( isFinite ).reduce Math.min
		max: -> @filter( isFinite ).reduce Math.max
		mean: -> @sum() / @length
		sum: -> @filter( isFinite ).reduce (a) -> a + @
		product: -> @filter( isFinite ).reduce (a) -> a * @
		squares: -> @map -> @ * @
		magnitude: -> Math.sqrt @floats().squares().sum()
		scale: (r) -> @map -> r * @
		add: (d) -> switch $.type(d)
			when "number" then @map -> d + @
			when "bling","array" then $( @[i]+d[i] for i in [0...Math.min(@length,d.length)] )
		normalize: -> @scale(1/@magnitude())
	$.plugin
		provides: "string"
		depends: "function"
	, ->
		$.type.extend
			unknown:
				string: (o) -> o.toString?() ? String(o)
				repr: (o) -> $.type.lookup(o).string(o)
			null: { string: -> "null" }
			undefined: { string: -> "undefined" }
			string:
				string: $.identity
				repr:   (s) -> "'#{s}'"
			array:  { string: (a) -> "[" + ($.toString(x) for x in a).join(",") + "]" }
			object: { string: (o) -> "{" + ("#{k}:#{$.toString(v)}" for k,v of o).join(", ") + "}" }
			number:
				repr:   (n) -> String(n)
				string: (n) ->
					switch true
						when n.precision? then n.toPrecision(n.precision)
						when n.fixed? then n.toFixed(n.fixed)
						else String(n)
		return {
			$:
				toString: (x) ->
					if not x? then "function Bling(selector, context) { [ ... ] }"
					else $.type.lookup(x).string(x)
				toRepr: (x) -> $.type.lookup(x).repr(x)
				px: (x, delta=0) -> x? and (parseInt(x,10)+(delta|0))+"px"
				capitalize: (name) -> (name.split(" ").map (x) -> x[0].toUpperCase() + x.substring(1).toLowerCase()).join(" ")
				dashize: (name) ->
					ret = ""
					for i in [0...(name?.length|0)]
						c = name.charCodeAt i
						if 91 > c > 64
							c += 32
							ret += '-'
						ret += String.fromCharCode(c)
					ret
				camelize: (name) ->
					name.split('-')
					while (i = name?.indexOf('-')) > -1
						name = $.stringSplice(name, i, i+2, name[i+1].toUpperCase())
					name
				padLeft: (s, n, c = " ") ->
					while s.length < n
						s = c + s
					s
				padRight: (s, n, c = " ") ->
					while s.length < n
						s = s + c
					s
				stringCount: (s, x, i = 0, n = 0) ->
					if (j = s.indexOf x,i) > i-1
						$.stringCount s, x, j+1, n+1
					else n
				stringSplice: (s, i, j, n) ->
					nn = s.length
					end = j
					if end < 0
						end += nn
					start = i
					if start < 0
						start += nn
					s.substring(0,start) + n + s.substring(end)
				checksum: (s) ->
					a = 1; b = 0
					for i in [0...s.length]
						a = (a + s.charCodeAt(i)) % 65521
						b = (b + a) % 65521
					(b << 16) | a
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
			toRepr: -> $.toRepr @
		}
	$.plugin
		provides: "function"
		depends: "hash"
	, ->
		$:
			identity: (o) -> o
			not: (f) -> -> not f.apply @, arguments
			compose: (f,g) -> (x) -> f.call(y, (y = g.call(x,x)))
			and: (f,g) -> (x) -> g.call(@,x) and f.call(@,x)
			once: (f, n=1) ->
				$.defineProperty (-> (f.apply @,arguments) if n-- > 0),
					"exhausted",
						get: -> n <= 0
			cycle: (f...) ->
				i = -1
				-> f[i = ++i % f.length].apply @, arguments
			bound: (t, f, args = []) ->
				if $.is "function", f.bind
					args.splice 0, 0, t
					r = f.bind.apply f, args
				else
					r = (a...) -> f.apply t, (args if args.length else a)
				$.extend r, { toString: -> "bound-method of #{t}.#{f.name}" }
			memoize: (f) ->
				cache = {}
				(a...) -> cache[$.hash(a)] ?= f.apply @, a # BUG: skips cache if f returns null on purpose
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
			hash: () -> $.hash @
		}
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
	$.plugin
		provides: "EventEmitter"
	, ->
		$: EventEmitter: $.pipe("bling-init").append (obj) ->
			listeners = {}
			list = (e) -> (listeners[e] or= [])
			return inherit obj,
				emit:               (e, a...) -> (f.apply(@, a) for f in list(e)); null
				addListener:        (e, h) -> list(e).push(h); @emit('newListener', e, h)
				on:                 (e, h) -> @addListener e, h
				removeListener:     (e, h) -> (list(e).splice i, 1) if (i = list(e).indexOf h) > -1
				removeAllListeners: (e) -> listeners[e] = []
				setMaxListeners:    (n) -> # who really needs this in the core API?
				listeners:          (e) -> list(e).slice 0
)(Bling, @)
