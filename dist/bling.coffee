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
	glob = if window? then window else global
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
		depends: "function"
		provides: "delay"
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
		depends: "function"
		provides: "string"
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
						$.publish e, args
						func.apply @, args
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
			inherit obj,
				emit:               (e, a...) -> (f.apply(@, a) for f in list(e)); null
				addListener:        (e, h) -> list(e).push(h); @emit('newListener', e, h)
				on:                 (e, h) -> @addListener e, h
				removeListener:     (e, h) -> (list(e).splice i, 1) if (i = list(e).indexOf h) > -1
				removeAllListeners: (e) -> listeners[e] = []
				setMaxListeners:    (n) -> # who really needs this in the core API?
				listeners:          (e) -> list(e).slice 0
	if glob.document?
		$.plugin
			depends: "function"
			provides: "dom"
		, ->
			$.type.register "nodelist",
				match:  (o) -> o? and $.isType "NodeList", o
				hash:   (o) -> $($.hash(i) for i in x).sum()
				array:  $.identity
				string: (o) -> "{Nodelist:["+$(o).select('nodeName').join(",")+"]}"
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
				node:   (h) ->
					(node = document.createElement('div')).innerHTML = h
					if n = (childNodes = node.childNodes).length is 1
						return node.removeChild(childNodes[0])
					df = document.createDocumentFragment()
					df.appendChild(node.removeChild(childNodes[0])) for i in [0...n] by 1
					df
				array:  (o,c) -> $.type.lookup(h = Bling.HTML.parse o).array h, c
				string: (o) -> "'#{o}'"
				repr:   (o) -> '"' + o + '"'
			$.type.extend
				unknown:  { node: -> null }
				bling:    { node: (o) -> o.toFragment() }
				node:     { html: (n) ->
					d = document.createElement "div"
					d.appendChild (n = n.cloneNode true)
					ret = d.innerHTML
					d.removeChild n # break links to prevent leaks
					ret
				}
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
			escaper = false
			parser = false
			computeCSSProperty = (k) -> -> window.getComputedStyle(@, null).getPropertyValue(k)
			getOrSetRect = (p) -> (x) -> if x? then @css(p, x) else @rect().select(p)
			selectChain = (prop) -> -> @map (p) -> $( p while p = p[prop] )
			return {
				$:
					HTML:
						parse: (h) -> $.type.lookup(h).node(h)
						stringify: (n) -> $.type.lookup(n).html(n)
						escape: (h) ->
							escaper or= $("<div>&nbsp;</div>").child(0)
							ret = escaper.zap('data', h).select("parentNode.innerHTML").first()
							escaper.zap('data', '')
							ret
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
									parent.appendChild( p.replaceChild(marker, child) )
									p.replaceChild(parent, marker)
				unwrap: -> # .unwrap() - replace each node's parent with itself
					@each ->
						if @parentNode and @parentNode.parentNode
							@parentNode.parentNode.replaceChild(@, @parentNode)
						else if @parentNode
							@parentNode.removeChild(@)
				replace: (n) -> # .replace(/n/) - replace each node with n [or a clone]
					n = toNode(n)
					clones = @map(-> n.cloneNode true)
					for i in [0...clones.length] by 1
						@[i].parentNode?.replaceChild clones[i], @[i]
					clones
				attr: (a,v) -> # .attr(a, [v]) - get [or set] an /a/ttribute [/v/alue]
					return switch v
						when undefined then @select("getAttribute").call(a, v)
						when null then @select("removeAttribute").call(a, v)
						else
							@select("setAttribute").call(a, v)
							@
				data: (k, v) -> @attr "data-#{$.dashize(k)}", v
				addClass: (x) -> # .addClass(/x/) - add x to each node's .className
					notempty = (y) -> y isnt ""
					@removeClass(x).each ->
						c = @className.split(" ").filter notempty
						c.push(x)
						@className = c.join " "
				removeClass: (x) -> # .removeClass(/x/) - remove class x from each node's .className
					notx = (y) -> y != x
					@each ->
						c = @className.split(" ").filter(notx).join(" ")
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
				css: (k,v) ->
					if v? or $.is "object", k
						setter = @select 'style.setProperty'
						if $.is "object", k then setter.call i, k[i], "" for i of k
						else if $.is "string", v then setter.call k, v, ""
						else if $.is "array", v
							setter[i%nn] k, v[i%n], "" for i in [0...n = Math.max v.length, nn = setter.len()] by 1
						return @
					else
						cv = @map computeCSSProperty(k)
						ov = @select('style').select k
						ov.weave(cv).fold (x,y) -> x or y
				defaultCss: (k, v) ->
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
				rect: -> @select('getBoundingClientRect').call()
				width: getOrSetRect("width")
				height: getOrSetRect("height")
				top: getOrSetRect("top")
				left: getOrSetRect("left")
				bottom: getOrSetRect("bottom")
				right: getOrSetRect("right")
				position: (left, top) ->
					switch true
						when not left? then @rect()
						when not top? then @css("left", $.px(left))
						else @css({top: $.px(top), left: $.px(left)})
				scrollToCenter: ->
					document.body.scrollTop = @[0].offsetTop - (window.innerHeight / 2)
					@
				child: (n) -> @select('childNodes').map -> @[ if n < 0 then (n+@length) else n ]
				parents: selectChain('parentNode')
				prev: selectChain('previousSibling')
				next: selectChain('nextSibling')
				remove: -> @each -> @parentNode?.removeChild(@)
				find: (css) ->
					@filter("*")
						.map( -> $(css, @) )
						.flatten()
				clone: (deep=true) -> @map -> (@cloneNode deep) if $.is "node", @
				toFragment: ->
					if @length > 1
						df = document.createDocumentFragment()
						(@map toNode).map $.bound df, df.appendChild
						return df
					return toNode @[0]
			}
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
		accel_props_re = /(?:scale(?:3d)*|translate(?:[XYZ]|3d)*|rotate(?:[XYZ]|3d)*)/
		updateDelay = 30 # ms to wait for DOM changes to apply
		testStyle = document.createElement("div").style
		transformProperty = "transform"
		transitionProperty = "transition-property"
		transitionDuration = "transition-duration"
		transitionTiming = "transition-timing-function"
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
				duration: (speed) ->
					d = speeds[speed]
					return d if d?
					return parseFloat speed
			transform: (end_css, speed, easing, callback) ->
				if $.is("function",speed)
					callback = speed
					speed = easing = null
				else if $.is("function",easing)
					callback = easing
					easing = null
				speed ?= "normal"
				easing or= "ease"
				duration = $.duration(speed) + "ms"
				props = []
				trans = ""
				css = {}
				for i of end_css
					if accel_props_re.test(i)
						ii = end_css[i]
						if ii.join
							ii = $(ii).px().join COMMASEP
						else if ii.toString
							ii = ii.toString()
						trans += " " + i + "(" + ii + ")"
					else css[i] = end_css[i]
				(props.push i) for i of css
				if trans
					props.push transformProperty
				css[transitionProperty] = props.join COMMASEP
				css[transitionDuration] = props.map(-> duration).join COMMASEP
				css[transitionTiming] = props.map(-> easing).join COMMASEP
				if trans
					css[transformProperty] = trans
				@css css
				@delay duration, callback
			hide: (callback) -> # .hide() - each node gets display:none
				@each ->
					if @style
						@_display = "" # stash the old display
						if @style.display is not "none"
							@_display = @syle.display
						@style.display = "none"
				.trigger "hide"
				.delay updateDelay, callback
			show: (callback) -> # .show() - show each node
				@each ->
					if @style
						@style.display = @_display
						delete @_display
				.trigger "show"
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
	$.plugin
		depends: "dom"
		provides: "http"
	, ->
		formencode = (obj) -> # create &foo=bar strings from object properties
			o = JSON.parse(JSON.stringify(obj)) # quickly remove all non-stringable items
			("#{i}=#{escape o[i]}" for i of o).join "&"
		$.type.register "http",
			match: (o) -> $.isType 'XMLHttpRequest', o
			array: (o) -> [o]
		return {
			$:
				http: (url, opts = {}) ->
					xhr = new XMLHttpRequest()
					if $.is "function", opts
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
				post: (url, opts = {}) ->
					if $.is("function",opts)
						opts = success: opts
					opts.method = "POST"
					$.http(url, opts)
				get: (url, opts = {}) ->
					if( $.is("function",opts) )
						opts = success: opts
					opts.method = "GET"
					$.http(url, opts)
		}
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
		]
		binder = (e) -> (f) -> @bind(e, f) if $.is "function", f else @trigger(e, f)
		register_live = (selector, context, evt, f, h) ->
			$(context).bind(evt, h)
				.each -> (((@__alive__ or= {})[selector] or= {})[evt] or= {})[f] = h
		unregister_live = (selector, context, e, f) ->
			$c = $(context)
			$c.each ->
				a = (@__alive__ or= {})
				b = (a[selector] or= {})
				c = (b[e] or= {})
				$c.unbind(e, c[f])
				delete c[f]
		triggerReady = $.once ->
			$(document).trigger("ready").unbind("ready")
			document.removeEventListener?("DOMContentLoaded", triggerReady, false)
			window.removeEventListener?("load", triggerReady, false)
		bindReady = $.once ->
			document.addEventListener?("DOMContentLoaded", triggerReady, false)
			window.addEventListener?("load", triggerReady, false)
		bindReady()
		ret = {
			bind: (e, f) ->
				c = (e or "").split(EVENTSEP_RE)
				h = (evt) ->
					ret = f.apply @, arguments
					if ret is false
						evt.preventAll()
					ret
				@each -> (@addEventListener i, h, false) for i in c
			unbind: (e, f) ->
				c = (e or "").split EVENTSEP_RE
				@each -> (@removeEventListener i, f, null) for i in c
			trigger: (evt, args = {}) ->
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
							target: null,
							scale: 1.0,
							rotation: 0.0
						}, args
						e.initGestureEvent evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
							args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.target, args.scale, args.rotation
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
			live: (e, f) ->
				selector = @selector
				context = @context
				handler = (evt) ->
					$(selector, context)
						.intersect($(evt.target).parents().first().union($(evt.target)))
						.each -> f.call(evt.target = @, evt)
				register_live selector, context, e, f, handler
				@
			die: (e, f) ->
				$(@context).unbind e, unregister_live(@selector, @context, e, f)
				@
			click: (f = {}) ->
				if @css("cursor") in ["auto",""]
					@css "cursor", "pointer"
				if $.is "function", f then @bind 'click', f
				else @trigger 'click', f
				@
			ready: (f) ->
				return (f.call @) if triggerReady.exhausted
				@bind "ready", f
		}
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
