Object.keys or= (o) -> (k for k of o)
Object.values or= (o) -> (o[k] for k of o)
extend = (a, b...) ->
	for obj in b when obj
		a[k] = v for k,v of obj # when v?
	a
class Bling # extends (new Array)
	"Bling:nomunge"
	constructor: (args...) ->
		if args.length is 1
			args = $.type.lookup(args[0]).array(args[0])
		b = $.inherit Bling, args
		if args.length is 0 and args[0] isnt undefined
			i = 0
			i++ while args[i] isnt undefined
			b.length = i
		if 'init' of Bling # See: plugins/hook.coffee
			return Bling.init(b)
		return b
$ = Bling
$:: = []
$::constructor = $
$.global = do -> @
$.plugin = (opts, constructor) ->
	if not constructor
		constructor = opts
		opts = {}
	if "depends" of opts
		return @depends opts.depends, =>
			@plugin { provides: opts.provides }, constructor
	try
		if typeof (plugin = constructor?.call @,@) is "object"
			extend @, plugin?.$
			delete plugin.$
			extend @prototype, plugin
			for key of plugin then do (key) =>
				@[key] or= (a...) => (@::[key].apply $(a[0]), a[1...])
			if opts.provides? then @provide opts.provides
	catch error
		console.log "failed to load plugin: #{@name} #{error.message}: #{error.stack}"
	@
extend $, do ->
	waiting = []
	complete = {}
	commasep = /, */
	not_complete = (x) -> not (x of complete)
	incomplete = (n) ->
		(if (typeof n) is "string" then n.split commasep else n)
		.filter not_complete
	depend = (needs, func) ->
		if (needs = incomplete needs).length is 0 then func()
		else
			waiting.push (need) ->
				(needs.splice i, 1) if (i = needs.indexOf need) > -1
				return (needs.length is 0 and func)
		func
	depend: depend
	depends: depend # alias
	provide: (needs, data) ->
		caught = null
		for need in incomplete needs
			complete[need] = i = 0
			while i < waiting.length
				if (ready = waiting[i] need)
					waiting.splice i,1
					try ready data
					catch err then caught = err
					i = 0 # start over in case a nested dependency removed stuff 'behind' i
				else i++
		if caught then throw caught
		data
$.plugin
	depends: "core"
	provides: "async,series,parallel"
, ->
	return {
		series: (fin = $.identity) ->
			try return @
			finally
				ret = $()
				todo = @length
				unless todo > 0
					fin.apply ret, ret
				else
					done = 0
					finish_one = (index) -> -> # create a callback to finish an ordered element
						ret[index] = arguments # typically capture [err, result]; but by convention only
						if ++done >= todo then fin.apply ret, ret # if we are done, call the final callback
						else next done
						null
					do next = (i=0) => $.immediate => @[i] finish_one i
		parallel: (fin = $.identity) ->
			try return @
			finally
				ret = $()
				todo = @length
				unless todo > 0
					fin.apply ret, ret
				else
					done = 0
					finish_one = (index) -> -> # see the comments in .series: collate the output
						ret[index] = arguments
						if ++done >= todo
							fin.apply ret, ret
						null
					for i in [0...todo] by 1
						@[i] finish_one i
	}
$.plugin
	provides: "cache, Cache"
	depends: "core, sortBy"
, ->
	class EffCache
		log = $.logger "[LRU]"
		constructor: (@capacity = 1000, @defaultTtl = Infinity) ->
			@capacity = Math.max 0, @capacity
			@evictCount = Math.max 3, Math.floor @capacity * .1
			index = Object.create null
			order = []
			eff = (o) -> -o.r / o.w
			autoEvict = =>
				return unless @capacity > 0
				if order.length >= @capacity
					while order.length + @evictCount - 1 >= @capacity
						delete index[k = order.pop().k]
				null
			reIndex = (i, j) ->
				for x in [i..j] when 0 <= x < order.length
					index[order[x].k] = x
				null
			rePosition = (i) ->
				obj = order[i]
				j = $.sortedIndex order, obj, eff
				if j isnt i
					order.splice i, 1
					order.splice j, 0, obj
					reIndex i, j
				null
			noValue	= v: undefined
			$.extend @,
				has: (k) -> k of index
				del: (k) ->
					if k of index
						i = index[k]
						order.splice i, 1
						delete index[k]
						reIndex i, order.length - 1
				set: (k, v, ttl = @defaultTtl) =>
					return v unless @capacity > 0
					if k of index
						d = order[i = index[k]]
						d.v = v
						d.w += 1
						rePosition i
					else
						autoEvict()
						item = { k, v, r: 0, w: 1 }
						i = $.sortedIndex order, item, eff
						order.splice i, 0, item
						reIndex i, order.length - 1
					if ttl < Infinity
						$.delay ttl, =>
							@del(k)
					v
				get: (k) ->
					ret = noValue
					if k of index
						i = index[k]
						ret = order[i]
						ret.r += 1
						rePosition i
					ret.v
				clear: ->
					for k of index # just break all the links to allow GC to cleanup
						order[index[k]] = null
					index = Object.create(null)
					order = []
	return $: Cache: $.extend EffCache, new EffCache(10000)
$.plugin
	provides: "cartesian"
, ->
	$:
		cartesian: (sets...) ->
			n = sets.length
			ret = []
			helper = (cur, i) ->
				(return ret.push cur) if ++i >= n
				for x in sets[i]
					helper (cur.concat x), i
				null
			helper [], -1
			return $(ret)
$.plugin
	provides: "compat, trimLeft, split, lastIndexOf, join, preventAll, matchesSelector, isBuffer"
, ->
	$.global.Buffer or= { isBuffer: -> false }
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
	return { }
$.plugin
	provides: 'config'
	depends: 'core'
, ->
	get = (name, def) -> switch arguments.length
		when 0 then $.extend {}, process.env
		else process.env[name] ? def
	set = (name, val) -> switch arguments.length
		when 1 then $.extend process.env, arguments[0]
		when 2 then process.env[name] = val
	parse = (data) ->
		ret = {}
		$(data.toString("utf8").split "\n") \
			.filter($.isEmpty, false) \
			.filter(/^#/, false) \
			.map(-> @replace(/^\s+/,'').split '=') \
			.each (kv) -> if kv[0]?.length then ret[kv[0]] = kv[1] \
				.replace(/^["']/,'') \
				.replace(/['"]$/,'')
		ret
	watch = (name, func) ->
		prev = process.env[name]
		$.interval 1003, ->
			if (cur = process.env[name]) isnt prev
				func prev, cur
				prev = cur
	$: config: $.extend get, {get, set, parse, watch}
$.plugin
	provides: "core,eq,each,map,filterMap,tap,replaceWith,reduce,union,intersect,distinct," +
		"contains,count,coalesce,swap,shuffle,select,or,zap,clean,take,skip,first,last,slice," +
		"push,filter,matches,weave,fold,flatten,call,apply,log,toArray,clear,indexWhere"
	depends: "string"
, ->
	$.defineProperty $, "now",
		get: -> +new Date
	index = (i, o) ->
		i += o.length while i < 0
		Math.min i, o.length
	baseTime = 0
	return {
		$:
			log: $.extend((a...) ->
				prefix = "+#{$.padLeft String($.now - baseTime), $.log.prefixSize, '0'}:"
				if baseTime is 0 or prefix.length > $.log.prefixSize + 2
					prefix = $.date.format(baseTime = $.now, "dd/mm/YY HH:MM:SS:", "ms")
				if a.length and $.is "string", a[0]
					a[0] = "#{prefix} #{a[0]}"
				else
					a.unshift prefix
				$.log.out a...
				return a[a.length-1] if a.length
			, {
				out: -> console.log.apply console, arguments
				prefixSize: 5
			})
			logger: (prefix) -> (m...) -> m.unshift(prefix); $.log m...
			assert: (c, m="") -> if not c then throw new Error("assertion failed: #{m}")
			coalesce: (a...) -> $(a).coalesce()
			keysOf: (o, own=false) ->
				if own then $(k for own k of o)
				else $(k for k of o)
			valuesOf: (o, own=false) -> $.keysOf(o, own).map (k)->
				return try o[k] catch err then err
		eq: (i) -> $([@[index i, @]])
		each: (f) -> (f.call(t,t) for t in @); @
		map: (f) ->
			b = $()
			i = 0
			(b[i++] = f.call t,t) for t in @
			return b
		filterMap: (f) ->
			b = $()
			for t in @
				v = f.call t,t
				if v?
					b.push v
			b
		tap: (f) -> f.call @, @
		replaceWith: (array) ->
			for i in [0...array.length] by 1
				@[i] = array[i]
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
		contains: (item, strict = true) ->
			if strict
				return @indexOf(item) > -1
			else for t in @ when `t == item`
				return true
			false
		count: (item, strict = true) ->
			$(1 for t in @ \
				when (item is undefined) \
				or (strict and t is item) \
				or (not strict and `t == item`)
			).sum()
		coalesce: ->
			for i in @
				if $.is('array',i) or $.is('bling',i) then i = $(i).coalesce()
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
		select: do ->
			getter = (prop) ->
				->
					if $.is("function",v = @[prop]) then $.bound(@,v) else v
			selectOne = (p) ->
				switch type = $.type p
					when 'regexp' then selectMany.call @, p
					when 'string'
						if p is "*" then @flatten()
						else if (i = p.indexOf '.') > -1 then @select(p.substr 0,i).select(p.substr i+1)
						else @map(getter p)
					else $()
			selectMany = (a...) ->
				n = @length
				lists = Object.create(null)
				for p in a
					if $.is 'regexp', p
						for match in $.keysOf(@[0]).filter(p)
							lists[match] = @select(match)
					else lists[p] = @select(p)
				i = 0
				@map ->
					obj = Object.create(null)
					for p of lists
						key = p.split('.').pop()
						val = lists[p][i]
						unless val is undefined
							obj[key] = val
					i++
					obj
			return ->
				switch arguments.length
					when 0 then @
					when 1 then selectOne.apply @, arguments
					else selectMany.apply @, arguments
		or: (x) -> @[i] or= x for i in [0...@length]; @
		zap: (p, v) ->
			if ($.is 'object', p) and not v?
				@zap(k,v) for k,v of p
				return @
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
		clean: (props...) ->
			@each ->
				for prop in props
					switch $.type prop
						when 'string','number' then delete @[prop]
						when 'regexp'
							for key in Object.keys(@) when prop.test key
								delete @[key]
				null
		take: (n = 1) ->
			end = Math.min n, @length
			$( @[i] for i in [0...end] by 1 )
		skip: (n = 0) ->
			start = Math.max 0, n|0
			$( @[i] for i in [start...@length] by 1 )
		first: (n = 1) -> if n is 1 then @[0] else @take(n)
		last: (n = 1) -> if n is 1 then @[@length - 1] else @skip(@length - n)
		slice: (start=0, end=@length) ->
			start = index start, @
			end = index end, @
			$( @[i] for i in [start...end] )
		extend: (b) -> @.push(i) for i in b; @
		push: (b) -> Array::push.call(@, b); @
		filter: (f, limit, positive) ->
			if $.is "bool", limit
				[positive, limit] = [limit, positive]
			if $.is "number", positive
				[limit, positive] = [positive, limit]
			limit ?= @length
			positive ?= true
			g = switch $.type f
				when "object" then (x) -> $.matches f,x
				when "string" then (x) -> x?.matchesSelector?(f) ? false
				when "regexp" then (x) -> f.test(x)
				when "function" then f
				else throw new Error "unsupported argument to filter: #{$.type f}"
			a = $()
			for it in @
				if (!! g.call it,it) is positive
					if --limit < 0
						break
					a.push it
			a
		matches: (expr) ->
			switch $.type expr
				when "string" then @select('matchesSelector').call(expr)
				when "regexp" then @map (x) -> expr.test x
				else throw new Error "unsupported argument to matches: #{$.type expr}"
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
			for item, i in @
				if ($.is 'array', item) or ($.is 'bling', item) or ($.is 'arguments', item) or ($.is 'nodelist', item)
					for j in item then b.push(j)
				else b.push(item)
			b
		call: -> @apply(null, arguments)
		apply: (context, args) ->
			@filterMap ->
				if $.is 'function', @ then @apply(context, args)
				else null
		log: (label) ->
			if label
				$.log(label, @toString(), @length + " items")
			else
				$.log(@toString(), @length + " items")
			@
		toArray: ->
			@__proto__ = Array::
			@ # no copies, yay?
		clear: -> @splice 0, @length
		indexWhere: (f) ->
			for x,i in @
				return i if (f.call x,x)
			return -1
	}
$.plugin
	provides: "css,CSS"
	depends: "type"
, ->
	flatten = (o, prefix, into) ->
		unless prefix of into
			into[prefix] = []
		for k,v of o
			switch typeof v
				when "string","number"
					nk = k.replace(/([a-z]+)([A-Z]+)/g, "$1-$2").toLowerCase()
					into[prefix].push "#{nk}: #{v};"
				when "object"
					nk = if prefix then (prefix + k) else k
					flatten(v, nk, into)
				else throw new Error("unexpected type in css: #{typeof v}")
		return into
	trim = (str) -> str.replace(/^\s+/, '').replace(/\s+$/, '')
	stripComments = (str) ->
		while (i = str.indexOf "/*") > -1
			if (j = str.indexOf "*/", i) is -1
				break # Unclosed comments
			str = str.substring(0,i) + str.substring(j+2)
		str
	parse = (str, into) ->
		if m = str.match /([^{]+){/
			selector = trim m[1]
			rest = str.substring m[0].length
			into[selector] or= {}
			if m = rest.match /([^}]+)}/
				body = m[1].split ';'
				rest = rest.substring m[0].length
				for rule in body
					colon = rule.indexOf ':'
					continue unless key = rule.substring(0,colon)
					key = trim key
					value = trim rule.substring(colon+1)
					into[selector][key] = value
			if rest.length > 0
				return parse(rest, into)
		return into
	specialOps = '>+~'
	compact = (obj) ->
		ret = {}
		for selector, rules of obj
			for op in specialOps
				selector = selector.replace op, " #{op} "
			parts = selector.split(/\s+/)
			switch parts.length
				when 0 then continue
				when 1 then $.extend (ret[selector] or= {}), rules
				else
					cur = ret
					first = true
					for part in parts
						unless first then part = " " + part
						cur = cur[part] or= {}
						first = false
					$.extend cur, rules
		phaseTwo = (cur) ->
			modified = false
			for key, val of cur
				if $.is 'object', val
					subkeys = Object.keys(val)
					switch subkeys.length
						when 0
							delete cur[key]
						else
							if subkeys.length is 1 and $.is 'object', val[subkeys[0]]
								cur[key + subkeys[0]] = val[subkeys[0]] # lift sub-value up into a merged key
								delete cur[key] # delete old key
								phaseTwo cur # restart recursion from the top, in case we need to keep folding up into the root
					phaseTwo val
			cur
		return phaseTwo ret
	return {
		$:
			CSS:
				parse: (str, packed=false) ->
					ret = parse stripComments(str), {}
					return if packed then compact ret else ret
				stringify: (obj) ->
					return ("#{x} { #{y.join ' '} }" for x,y of flatten(obj, "", {}) when y.length > 0).join ' '
	}
$.plugin
	provides: 'date,midnight,stamp,unstamp,dateFormat,dateParse'
	depends: 'type'
, ->
	[ms,s,m,h,d] = [1,1000,1000*60,1000*60*60,1000*60*60*24]
	units = {
		ms, s, m, h, d,
		sec: s
		second: s
		seconds: s
		min: m
		minute: m
		minutes: m
		hr: h
		hour: h
		hours: h
		day: d
		days: d
	}
	shortDays = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
	longDays = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
	formats =
		yyyy: Date::getUTCFullYear
		YY: fYY = -> String(@getUTCFullYear()).substr(2)
		yy: fYY
		mm: -> @getUTCMonth() + 1
		dd: Date::getUTCDate
		dw: Date::getUTCDay # day of the week, 1=monday
		dW: -> shortDays[parseInt(@getUTCDay(), 10) - 1]
		DW: -> longDays[parseInt(@getUTCDay(), 10) - 1]
		HH: Date::getUTCHours
		MM: Date::getUTCMinutes
		SS: Date::getUTCSeconds
		MS: Date::getUTCMilliseconds
	format_keys = Object.keys(formats).sort().reverse()
	parsers =
		YYYY: pYYYY =Date::setUTCFullYear
		yyyy: pYYYY
		YY: pYY = (x) -> @setUTCFullYear (if x > 50 then 1900 else 2000) + x
		yy: pYY
		mm: (x) -> @setUTCMonth(x - 1)
		dd: Date::setUTCDate
		HH: Date::setUTCHours
		MM: Date::setUTCMinutes
		SS: Date::setUTCSeconds
		MS: Date::setUTCMilliseconds
	parser_keys = Object.keys(parsers).sort().reverse()
	floor = Math.floor
	$.type.register "date",
		is: (o) -> $.isType Date, o
		array: (o) -> [o]
		string: (o, fmt, unit) -> $.date.format o, fmt, unit
		number: (o, unit) -> $.date.stamp o, unit
	$.type.extend 'string', date: (s, fmt = $.date.defaultFormat) -> new Date $.date.parse s, fmt, "ms"
	$.type.extend 'number', date: (n, unit = $.date.defaultUnit) -> $.date.unstamp n, unit
	adder = (key) ->
		(stamp, delta, stamp_unit = $.date.defaultUnit) ->
			date = $.date.unstamp(stamp, stamp_unit)
			parsers[key].call date, (formats[key].call date) + delta
			$.date.stamp date, stamp_unit
	$:
		date:
			defaultUnit: "s"
			defaultFormat: "yyyy-mm-dd HH:MM:SS"
			stamp: (date = new Date, unit = $.date.defaultUnit) ->
				floor (date / units[unit])
			unstamp: (stamp, unit = $.date.defaultUnit) ->
				new Date floor(stamp * units[unit])
			convert: (stamp, from = $.date.defaultUnit, to = $.date.defaultUnit) ->
				if $.is "date", stamp then stamp = $.date.stamp(stamp, from)
				(floor stamp * units[from] / units[to])
			midnight: (stamp, unit = $.date.defaultUnit) ->
				$.date.convert ($.date.convert stamp, unit, "d"), "d", unit
			format: (stamp, fmt = $.date.defaultFormat, unit = $.date.defaultUnit) ->
				if $.is "date", stamp then stamp = $.date.stamp(stamp, unit)
				date = $.date.unstamp stamp, unit
				for k in format_keys
					fmt = fmt.replace k, ($.padLeft ""+formats[k].call(date), k.length, "0")
				fmt
			parse: (dateString, fmt = $.date.defaultFormat, to = $.date.defaultUnit) ->
				date = new Date(0)
				i = 0
				while i < fmt.length
					for k in parser_keys
						if fmt.indexOf(k, i) is i
							try
								parsers[k].call date,
									parseInt dateString[i...i+k.length], 10
							catch err
								throw new Error("Invalid date ('#{dateString}') given format mask: #{fmt} (failed at position #{i})")
							i += k.length - 1
							break
					i += 1
				$.date.stamp date, to
			addMilliseconds: adder("MS")
			addSeconds: adder("SS")
			addMinutes: adder("MM")
			addHours: adder("HH")
			addDays: adder("dd")
			addMonths: adder("mm")
			addYears: adder("yyyy")
			range: (from, to, interval=1, interval_unit="dd", stamp_unit = $.date.defaultUnit) ->
				add = adder(interval_unit)
				ret = [from]
				while (cur = ret[ret.length-1]) < to
					ret.push add(cur, interval, stamp_unit)
				ret
	midnight: (unit = $.date.defaultUnit) -> @map(-> $.date.midnight @, unit)
	unstamp: (unit = $.date.defaultUnit) -> @map(-> $.date.unstamp @, unit)
	stamp: (unit = $.date.defaultUnit) -> @map(-> $.date.stamp @, unit)
	dateFormat: (fmt = $.date.defaultFormat, unit = $.date.defaultUnit) -> @map(-> $.date.format @, fmt, unit)
	dateParse: (fmt = $.date.defaultFormat, unit = $.date.defaultUnit) -> @map(-> $.date.parse @, fmt, unit)
$.plugin
	provides: "delay,immediate,interval"
	depends: "is,select,extend,bound"
, ->
	$:
		delay: do ->
			timeoutQueue = $.extend [], do ->
				next = (a) -> -> (do a.shift()) if a.length; null
				add: (f, n) ->
					$.extend f,
						order: n + $.now
						timeout: setTimeout next(@), n
					for i in [0..@length] by 1
						if i is @length or @[i].order > f.order
							@splice i,0,f
							break
					@
				cancel: (f) ->
					if (i = @indexOf f) > -1
						@splice i, 1
						clearTimeout f.timeout
					@
			(n, f) -> switch
				when $.is 'object', n
					b = $($.delay(k,v) for k,v of n)
					{
						cancel: -> b.select('cancel').call()
						unref: -> b.select('unref').call()
						ref: -> b.select('ref').call()
					}
				when $.is 'function', f
					timeoutQueue.add f, parseInt(n,10)
					{
						cancel: -> timeoutQueue.cancel(f)
						unref: (f) -> f.timeout?.unref()
						ref: (f) -> f.timeout?.ref()
					}
				else throw new Error "Bad arguments to $.delay (expected: int,function given: #{$.type n},#{$.type f})"
		immediate: do -> switch
			when 'setImmediate' of $.global then $.global.setImmediate
			when process?.nextTick? then process.nextTick
			else (f) -> setTimeout(f, 0)
		interval: (n, f) ->
			paused = false
			ret = $.delay n, g = ->
				unless paused then do f
				$.delay n, g
			$.extend ret,
				pause: (p=true) -> paused = p
				resume: (p=true) -> paused = not p
	delay: (n, f) ->
		$.delay n, $.bound @, f
		@
$.plugin
	depends: "inherit,reduce"
	provides: "diff,stringDistance,stringDiff"
, ->
	lev_memo = Object.create null
	min = Math.min
	lev = (s,i,n,t,j,m,dw,iw,sw) ->
		return lev_memo[[s,i,n,t,j,m,dw,iw,sw]] ?= lev_memo[[t,j,m,s,i,n,dw,iw,sw]] ?= do -> switch
			when m <= 0 then n
			when n <= 0 then m
			else min(
				dw + lev(s,i+1,n-1, t,j,m,dw,iw,sw),
				iw + lev(s,i,n, t,j+1,m-1,dw,iw,sw),
				(sw * (s[i] isnt t[j])) + lev(s,i+1,n-1, t,j+1,m-1,dw,iw,sw)
			)
	collapse = (ops) -> # combines similar operations in a sequence
		$.inherit {
			toHTML: ->
				@reduce(((a,x) ->
					a += switch x.op
						when 'ins' then "<ins>#{x.v}</ins>"
						when 'del' then "<del>#{x.v}</del>"
						when 'sub' then "<del>#{x.v}</del><ins>#{x.w}</ins>"
						when 'sav' then x.v
				), "")
		}, ops.reduce(((a,x) ->
			if x.op is 'sub' and x.v is x.w # replacing with the same thing is just preserving
				x.op = 'sav'
				delete x.w
			unless a.length
				a.push x
			else
				if (last = a.last()).op is x.op
					last.v += x.v
					if last.op is 'sub'
						last.w += x.w
				else
					a.push x
			return a
		), $())
	diff_memo = Object.create null
	del = (c) -> {op:'del',v:c}
	ins = (c) -> {op:'ins',v:c}
	sub = (c,d) -> {op:'sub',v:c,w:d}
	diff = (s,i,n,t,j,m,dw,iw,sw) ->
		return diff_memo[[s,i,n,t,j,m,dw,iw,sw]] ?= collapse do -> switch
			when m <= 0 then (del c) for c in s.substr i,n
			when n <= 0 then (ins c) for c in t.substr j,m
			else
				sw *= (s[i] isnt t[j])
				args =
					del: [s+0,i+1,n-1,t+0,j+0,m+0,  1.00,1.50,1.50]
					ins: [s+0,i+0,n+0,t+0,j+1,m-1,  1.50,1.00,1.50]
					sub: [s+0,i+1,n-1,t+0,j+1,m-1,  1.00,1.00,1.00]
				costs =
					del: dw + lev args.del...
					ins: iw + lev args.ins...
					sub: sw + lev args.sub...
				switch min costs.del, costs.ins, costs.sub
					when costs.del then $(del s[i]).concat diff args.del...
					when costs.ins then $(ins t[j]).concat diff args.ins...
					when costs.sub then $(sub s[i],t[j]).concat diff args.sub...
	$:
		stringDistance: (s, t) -> lev s,0,s.length, t,0,t.length,1,1,1
		stringDiff: (s, t) -> diff s,0,s.length, t,0,t.length,1,1,1.5
if $.global.document?
	$.plugin
		provides: "dom,HTML,html,append,appendText,appendTo,prepend,prependTo," +
			"before,after,wrap,unwrap,replace,attr,data,addClass,removeClass,toggleClass," +
			"hasClass,text,val,css,defaultCss,rect,width,height,top,left,bottom,right," +
			"position,scrollToCenter,child,parents,next,prev,remove,find,querySelectorAll," +
			"clone,toFragment"
		depends: "function,type,string"
	, ->
		bNodelistsAreSpecial = false
		$.type.register "nodelist",
			is:			(o) -> o? and $.isType "NodeList", o
			hash:		(o) -> $($.hash(i) for i in o).sum()
			array:	do ->
				try # probe to see if this browsers allows modification of a NodeList's prototype
					document.querySelectorAll("xxx").__proto__ = {}
					return $.identity
				catch err # if we can't patch directly, we have to copy into a real array :(
					bNodelistsAreSpecial = true
					return (o) -> (node for node in o)
			string: (o) -> "{Nodelist:["+$(o).select('nodeName').join(",")+"]}"
			node:		(o) -> $(o).toFragment()
		$.type.register "node",
			is:  (o) -> o?.nodeType > 0
			hash:		(o) -> $.checksum(o.nodeName) + $.hash(o.attributes) + $.checksum(o.innerHTML)
			string: (o) -> o.toString()
			node:		$.identity
		$.type.register "fragment",
			is:  (o) -> o?.nodeType is 11
			hash:		(o) -> $($.hash(x) for x in o.childNodes).sum()
			string: (o) -> o.toString()
			node:		$.identity
		$.type.register "html",
			is:  (o) -> typeof o is "string" and (s=o.trimLeft())[0] == "<" and s[s.length-1] == ">"
			node:		(h) ->
				(node = document.createElement('div')).innerHTML = h
				if (n = (childNodes = node.childNodes).length) is 1
					return node.removeChild(childNodes[0])
				df = document.createDocumentFragment()
				df.appendChild(node.removeChild(childNodes[0])) for i in [0...n] by 1
				df
			array:	(o) -> $.type.lookup(h = $.HTML.parse o).array h
			string: (o) -> "'#{o}'"
			repr:		(o) -> '"' + o + '"'
		$.type.extend
			unknown:	{ node: -> null }
			bling:		{ node: (o) -> o.toFragment() }
			node:			{ html: (n) ->
				d = document.createElement "div"
				d.appendChild (n = n.cloneNode true)
				ret = d.innerHTML
				d.removeChild n # break links to prevent leaks
				ret
			}
			string:
				node:  (o) -> $(o).toFragment()
				array: do ->
					if bNodelistsAreSpecial
						(o) -> $.type.lookup(nl = document.querySelectorAll o).array(nl)
					else
						(o) -> document.querySelectorAll o
			function: { node: (o) -> $(o.toString()).toFragment() }
		toFrag  = (a) ->
			unless a.parentNode
				document.createDocumentFragment().appendChild a
			a
		before  = (a,b) -> toFrag(a).parentNode.insertBefore b, a
		after   = (a,b) -> toFrag(a).parentNode.insertBefore b, a.nextSibling
		toNode  = (x) -> $.type.lookup(x).node x
		escaper = false
		parser  = false
		$.computeCSSProperty = (k) -> -> $.global.getComputedStyle(@, null).getPropertyValue k
		getOrSetRect = (p) -> (x) -> if x? then @css(p, x) else @rect().select p
		selectChain = (prop) -> -> @map (p) -> $( p while p = p[prop] )
		return {
			$:
				HTML:
					parse: (h) -> $.type.lookup(h).node h
					stringify: (n) -> $.type.lookup(n).html n
					escape: (h) ->
						escaper or= $("<div>&nbsp;</div>").child 0
						ret = escaper.zap('data', h).select("parentNode.innerHTML").first()
						escaper.zap('data', '')
						ret
			html: (h) ->
				return switch $.type h
					when "undefined","null" then @select 'innerHTML'
					when "string","html" then @zap 'innerHTML', h
					when "bling" then @html h.toFragment()
					when "node"
						@each -> # replace all our children with the new child
							@replaceChild @childNodes[0], h
							while @childNodes.length > 1
								@removeChild @childNodes[1]
			append: (x) -> # .append(/n/) - insert /n/ [or a clone] as the last child of each node
				x = toNode(x) # parse, cast, do whatever it takes to get a Node or Fragment
				return unless x?
				@each (n) -> n?.appendChild? x.cloneNode true
			appendText: (text) ->
				x = document.createTextNode(text)
				return unless x?
				@each (n) -> n?.appendChild? x.cloneNode true
			appendTo: (x) -> # .appendTo(/n/) - each node [or fragment] will become the last child of x
				clones = @map( -> @cloneNode true)
				i = 0
				$(x).each -> @appendChild clones[i++]
				clones
			prepend: (x) -> # .prepend(/n/) - insert n [or a clone] as the first child of each node
				if x?
					x = toNode x
					@take(1).each -> switch
						when @childNodes.length > 0 then before @childNodes[0], x
						else @appendChild x
					@skip(1).each -> switch
						when @childNodes.length then before @childNodes[0], x.cloneNode true
						else @appendChild x.cloneNode true
				@
			prependTo: (x) -> # .prependTo(/n/) - each node [or a fragment] will become the first child of x
				if x?
					$(x).prepend(@)
				@
			before: (x) -> # .before(/x/) - insert content x before each node
				if x?
					x = toNode x
					@take(1).each -> before @, x
					@skip(1).each -> before @, x.cloneNode true
				@
			after: (x) -> # .after(/n/) - insert content n after each node
				if x?
					x = toNode x
					@take(1).each -> after @, x
					@skip(1).each -> after @, x.cloneNode true
				@
			wrap: (parent) -> # .wrap(/parent/) - parent becomes the new .parentNode of each node
				parent = toNode parent
				if $.is "fragment", parent
					throw new Error("cannot call .wrap() with a fragment as the parent")
				@each (child) ->
					if ($.is "fragment", child) or not child.parentNode
						return parent.appendChild child
					grandpa = child.parentNode
					marker = document.createElement "dummy"
					parent.appendChild grandpa.replaceChild marker, child
					grandpa.replaceChild parent, marker
			unwrap: -> # .unwrap() - replace each node's parent with itself
				@each ->
					if @parentNode and @parentNode.parentNode
						@parentNode.parentNode.replaceChild(@, @parentNode)
					else if @parentNode
						@parentNode.removeChild(@)
			replace: (n) -> # .replace(/n/) - replace each node with a clone of n
				if $.is 'regexp', n
					r = arguments[1]
					return @map (s) -> s.replace(n, r)
				n = toNode n
				clones = @map(-> n.cloneNode true)
				for i in [0...clones.length] by 1
					@[i].parentNode?.replaceChild clones[i], @[i]
				clones
			attr: (a,v) -> # .attr(a, [v]) - get [or set] an /a/ttribute [/v/alue]
				if $.is 'object', a
					@attr(k,v) for k,v of a
				else switch v
					when undefined
						return @select("getAttribute").call(a, v)
					when null
						@select("removeAttribute").call(a, v)
					else
						@select("setAttribute").call(a, v)
				@
			data: (k, v) -> @attr "data-#{$.dashize(k)}", v
			addClass: (x) -> # .addClass(/x/) - add x to each node's .className
				notempty = (y) -> y isnt ""
				@removeClass(x).each ->
					c = @className.split(" ").filter notempty
					c.push x
					@className = c.join " "
			removeClass: (x) -> # .removeClass(/x/) - remove class x from each node's .className
				notx = (y) -> y isnt x
				@each ->
					@className = @className.split(" ").filter(notx).join(" ")
					if @className.length is 0
						@removeAttribute('class')
			toggleClass: (x) -> # .toggleClass(/x/) - add, or remove if present, class x from each node
				notx = (y) -> y isnt x
				@each ->
					cls = @className.split(" ")
					filter = $.not $.isEmpty
					if (cls.indexOf x) > -1
						filter = $.and notx, filter
					else
						cls.push x
					@className = cls.filter(filter).join(" ")
					if @className.length is 0
						@removeAttribute 'class'
			hasClass: (x) -> # .hasClass(/x/) - true/false for each node: whether .className contains x
				@select('className.split').call(" ").select('indexOf').call(x).map (x) -> x > -1
			text: (t) -> # .text([t]) - get [or set] each node's .textContent
				return @zap('textContent', t) if t?
				return @select('textContent')
			val: (v) -> # .val([v]) - get [or set] each node's .value
				return @zap('value', v) if v?
				return @select('value')
			css: (key,v) ->
				if v? or $.is('object', key)
					setters = @select 'style.setProperty'
					if $.is "object", key then setters.call k, v, "" for k,v of key
					else if $.is "array", v
						for i in [0...n = Math.max v.length, nn = setters.length] by 1
							setters[i%nn](key, v[i%n], "")
					else if $.is 'function', v
						values = @select("style.#{key}") \
							.weave(@map $.computeCSSProperty key) \
							.fold($.coalesce) \
							.weave(setters) \
							.fold (setter, value) -> setter(key, v.call value, value)
					else setters.call key, v, ""
					return @
				else @select("style.#{key}") \
					.weave(@map $.computeCSSProperty key) \
					.fold($.coalesce)
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
			rect: -> @map (item) -> switch item
				when window then {
					width: window.innerWidth
					height: window.innerHeight
					top: 0
					left: 0
					right: window.innerWidth
					bottom: window.innerHeight
				}
				else item.getBoundingClientRect()
			width: getOrSetRect("width")
			height: getOrSetRect("height")
			top: getOrSetRect("top")
			left: getOrSetRect("left")
			bottom: getOrSetRect("bottom")
			right: getOrSetRect("right")
			position: (left, top) ->
				switch
					when not left? then @rect()
					when not top? then @css("left", $.px(left))
					else @css({top: $.px(top), left: $.px(left)})
			scrollToCenter: ->
				document.body.scrollTop = @[0].offsetTop - ($.global.innerHeight / 2)
				@
			child: (n) -> @select('childNodes').map -> @[ if n < 0 then (n+@length) else n ]
			parents: selectChain('parentNode')
			prev: selectChain('previousSibling')
			next: selectChain('nextSibling')
			remove: -> @each -> @parentNode?.removeChild(@)
			find: (css, limit = 0) ->
				@filter("*")
					.map(
						switch limit
							when 0 then (-> @querySelectorAll css)
							when 1 then (-> $ @querySelector css)
							else (-> $(@querySelectorAll css).take(limit) )
					)
					.flatten()
			querySelectorAll: (expr) ->
				@filter("*")
				.reduce (a, i) ->
					a.extend i.querySelectorAll expr
				, $()
			clone: (deep=true, count=1) ->
				c = (n) -> if $.is "node", n then (n.cloneNode deep)
				@map -> switch count
					when 1 then c @
					else (c(@) for _ in [0...count] by 1)
			toFragment: ->
				if @length > 1
					df = document.createDocumentFragment()
					(@map toNode).map (node) -> df.appendChild(node)
					return df
				return toNode @[0]
		}
$.plugin
	provides: "EventEmitter"
	depends: "type,hook"
, ->
	$: EventEmitter: $.init.append (obj = {}) ->
		listeners = Object.create null
		list = (e) -> (listeners[e] or= [])
		$.inherit {
			emit:               (e, a...) -> (f.apply(@, a) for f in list(e)); @
			on: add = (e, f) ->
				switch $.type e
					when 'object' then @addListener(k,v) for k,v of e
					when 'string'
						list(e).push(f)
						@emit('newListener', e, f)
				return @
			addListener: add
			removeListener:     (e, f) -> (l.splice i, 1) if (i = (l = list e).indexOf f) > -1
			removeAllListeners: (e) -> listeners[e] = []
			setMaxListeners:        -> # who really needs this in the core API?
			listeners:          (e) -> list(e).slice 0
		}, obj
$.plugin
	depends: "dom,function,core"
	provides: "event,bind,unbind,trigger,delegate,undelegate,click,ready"
, ->
	EVENTSEP_RE = /,* +/
	events = ['mousemove','mousedown','mouseup','mouseover','mouseout','blur','focus',
		'load','unload','reset','submit','keyup','keydown','keypress','change',
		'abort','cut','copy','paste','selection','drag','drop','orientationchange',
		'touchstart','touchmove','touchend','touchcancel',
		'gesturestart','gestureend','gesturecancel',
		'hashchange'
	]
	binder = (e) -> (f) ->
		if $.is "function", f then @bind e, f
		else @trigger e, f
	_get = (self, keys...) ->
		return if keys.length is 0 then self
		else _get (self[keys[0]] or= Object.create null), keys.slice(1)...
	triggerReady = $.once ->
		$(document).trigger("ready").unbind("ready")
		document.removeEventListener?("DOMContentLoaded", triggerReady, false)
		$.global.removeEventListener?("load", triggerReady, false)
	document.addEventListener?("DOMContentLoaded", triggerReady, false)
	$.global.addEventListener?("load", triggerReady, false)
	_b = (funcName) -> (e, f) ->
		c = (e or "").split EVENTSEP_RE
		@each -> (@[funcName] i, f, true) for i in c
	ret = {
		bind: _b "addEventListener"
		unbind: _b "removeEventListener"
		trigger: (evt, args = {}) ->
			args = $.extend
				bubbles: true
				cancelable: true
			, args
			for evt_i in (evt or "").split(EVENTSEP_RE)
				switch evt_i
					when "click", "mousemove", "mousedown", "mouseup", "mouseover", "mouseout" # mouse events
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
						e.initMouseEvent evt_i, args.bubbles, args.cancelable, $.global, args.detail,
							args.screenX, args.screenY, args.clientX, args.clientY,
							args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.button, args.relatedTarget
					when "blur", "focus", "reset", "submit", "abort", "change", "load", "unload" # UI events
						e = document.createEvent "UIEvents"
						e.initUIEvent evt_i, args.bubbles, args.cancelable, $.global, 1
					when "touchstart", "touchmove", "touchend", "touchcancel" # touch events
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
						e.initTouchEvent evt_i, args.bubbles, args.cancelable, $.global, args.detail,
							args.screenX, args.screenY, args.clientX, args.clientY,
							args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.touches, args.targetTouches, args.changedTouches, args.scale, args.rotation
					when "gesturestart", "gestureend", "gesturecancel" # gesture events
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
						e.initGestureEvent evt_i, args.bubbles, args.cancelable, $.global,
							args.detail, args.screenX, args.screenY, args.clientX, args.clientY,
							args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.target, args.scale, args.rotation
					when  "keydown", "keypress", "keyup"
						e = document.createEvent "KeyboardEvents"
						args = $.extend {
							view: null,
							ctrlKey: false,
							altKey: false,
							shiftKey: false,
							metaKey: false,
							keyCode: 0,
							charCode: 0
						}, args
						e.initKeyboardEvent evt_i, args.bubbles, args.cancelable, $.global,
							args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.keyCode, args.charCode
					else
						e = document.createEvent "Events"
						e.initEvent evt_i, args.bubbles, args.cancelable
						e = $.extend e, args
				continue unless e
				@each ->
					try @dispatchEvent e
					catch err then $.log "dispatchEvent error:", err
			@
		delegate: (selector, e, f) ->
			h = (evt) => # Create the delegate handler
				t = $(evt.target)
				@find(selector)
					.intersect(t.parents().first().union t)
					.each -> f.call evt.target = @, evt
			@bind(e, h) # Bind the delegate handler
				.each -> _get(@,'__alive__',selector,e)[f] = h # Save a reference for undelegate
		undelegate: (selector, e, f) ->
			context = @
			context.each ->
				c = _get(@,'__alive__',selector,e) # Find the saved reference to h
				try context.unbind e, c[f] # Unbind h from everything in the context
				finally delete c[f] # Remove the saved reference to f so we don't leak it.
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
	events.forEach (x) -> ret[x] = binder x
	return ret
$.plugin
	provides: "function,identity,compose,once,cycle,bound,partial"
	depends: "extend,is,defineProperty,map"
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
			return $.identity unless f?
			if $.is "function", f.bind
				args.splice 0, 0, t
				r = f.bind.apply f, args
			else
				r = (a...) -> f.apply t, (if args.length then args else a)
			$.extend r, { toString: -> "bound-method of #{t}.#{f.name}" }
		partial: (f, a...) -> (b...) -> f a..., b...
	partial: (a...) -> @map (f) -> $.partial f, a...
$.plugin
	provides: "groupBy"
	depends: "type"
, ->
	groupBy: (key) ->
		groups = {}
		switch $.type key
			when 'array','bling'
				@each ->
					c = (@[k] for k in key).join ","
					(groups[c] or= $()).push @
			else @each -> (groups[@[key]] or= $()).push @
		return $.valuesOf groups
$.plugin
	provides: "hash"
	depends: "type"
, ->
	maxHash = Math.pow(2,32)
	array_hash = (d) -> (o) -> d + $($.hash(x) for x in o).reduce(((a,x) -> ((a*a)+(x|0))%maxHash), 1)
	$.type.extend
		unknown:   { hash: (o) -> $.checksum $.toString o }
		object:    { hash: (o) -> 1970931729 + $($.hash(k) + $.hash(v) for k,v of o).sum() }
		array:     { hash: array_hash(1816922041) }
		arguments: { hash: array_hash(298517431) }
		bling:     { hash: array_hash(92078573) }
		bool:      { hash: (o) -> parseInt(1 if o) }
		regexp:    { hash: (o) -> 148243084 + $.checksum $.toString o }
	return {
		$: { hash: (x) -> $.type.lookup(x).hash(x) }
		hash: -> $.hash @
	}
$.plugin ->
	$:
		histogram: (data, bucket_width=1, output_width=60) ->
			buckets = $()
			len = 0
			min = Infinity
			mean = 0
			max = 0
			total = 0
			for x in data
				min = Math.min x, min
				max = Math.max x, max
				total += x
				i = Math.floor( x / bucket_width )
				if i of buckets
					buckets[i] += 1
				else
					buckets[i] = 1
				len = Math.max(len, i+1)
			buckets.length = len
			mean = total / data.length
			m = buckets.max()
			buckets = buckets.or(0)
				.scale(1/m)
				.scale(output_width)
			sum = buckets.sum()
			ret = ""
			pct_sum = 0
			for n in [0...len] by 1
				end = (n+1) * bucket_width
				pct = (buckets[n]*100/sum)
				pct_sum += pct
				ret += $.padLeft(pct_sum.toFixed(2)+"%",7) +
					$.padRight(" < #{end.toFixed(2)}", 10) +
					": " + $.repeat("#", buckets[n]) + "\n"
			ret + "N: #{data.length} Min: #{min.toFixed(2)} Max: #{max.toFixed(2)} Mean: #{mean.toFixed(2)}"
	histogram: -> $.histogram @
$.plugin
	provides: "hook"
	depends: "type"
, ->
	hook = ->
		chain = []
		return $.extend ((args) ->
			for func in chain
				args = func.call @, args
			args
		), {
			prepend: (o) -> chain.unshift o; o
			append: (o) -> chain.push o; o
		}
	$.init = hook()
	return $: { hook }
$.plugin
	depends: "dom"
	provides: "http"
, ->
	formencode = (obj) -> # create &foo=bar strings from object properties
		return if $.is 'object', obj
			o = JSON.parse JSON.stringify obj # quickly remove all non-stringable items
			("#{i}=#{escape o[i]}" for i of o).join "&"
		else obj
	$.type.register "http",
		is: (o) -> $.isType 'XMLHttpRequest', o
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
					headers: {}
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
				for k,v of opts.headers
					xhr.setRequestHeader k, v
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
$.depends 'hook', ->
	$.init.append (obj) ->
		map = Object.create(null)
		keyMakers = []
		$.inherit {
			index: (keyFunc) ->
				if keyMakers.indexOf(keyFunc) is -1
					keyMakers.push keyFunc
					map[keyFunc] = Object.create(null)
				@each (x) ->
					map[keyFunc][keyFunc(x)] = x
			query: (criteria) ->
				for keyMaker in keyMakers
					key = keyMaker(criteria)
					return map[keyMaker][key] if key of map[keyMaker]
				null
		}, obj
$.plugin
	provides: "toHTML"
	depends: "type,synth,once"
, ->
	dumpStyles = $.once -> try $("head").append $.synth("style#dump").text """
		table.dump                { border: 1px solid black; }
		table.dump tr.h           { background-color: blue; color: white; cursor: pointer; }
		table.dump tr.h th        { padding: 0px 4px; }
		table.dump tr.h.array     { background-color: purple; }
		table.dump tr.h.bling     { background-color: gold; }
		table.dump td             { padding: 2px; }
		table.dump td.k           { background-color: lightblue; }
		table.dump td.v.string    { background-color: #cfc; }
		table.dump td.v.number    { background-color: #ffc; }
		table.dump td.v.bool      { background-color: #fcf; }
	"""
	dumpScript = $.once -> try $("head").append $.synth("script#dump").text """
		$(document.body).delegate('table.dump tr.h', 'click', function() {
			$(this.parentNode).find("tr.kv").toggle()
		})
	"""
	table = (t, rows) ->
		tab = $.synth "table.dump tr.h.#{t} th[colspan=2] '#{t}'"
		if t in ["array","bling","nodelist"]
			tab.find("th").appendText " [#{rows.length}]"
		tab.append(row) for row in rows
		tab[0]
	tableRow = (k, v, open) ->
		row = $.synth "tr.kv td.k[align=right][valign=top] '#{k}' + td.v"
		td = row.find "td.v"
		switch _t = $.type v = $.toHTML v
			when "string","number","bool","html","null","undefined" then td.appendText String v
			else td.append v
		td.addClass _t
		row.toggle() unless open
		return row
	return { $: {
		toHTML: (obj, open=true) ->
			do dumpStyles
			do dumpScript
			return switch t = $.type obj
				when "string","number","bool","null","undefined","html" then obj
				when "bling","array","nodelist"
					table(t, tableRow(k, v, open) for v,k in obj)
				when "object","array"
					table(t, tableRow(k, v, open) for k,v of obj)
				when "node"
					s = $.HTML.stringify obj
					s.substr(0, s.indexOf('>') + 1) + '...'
				else String(obj)
	} }
$.plugin
	provides: 'keyName,keyNames'
	depends: "math"
, ->
	keyCode =
		"Backspace": 8
		"BS": 8
		"Tab": 9
		'\t': 9
		"Enter": 13
		'\n': 12
		"Shift": 16
		"Ctrl": 17
		"Alt": 18
		"Pause": 19
		"Break": 19
		"Caps": 20
		"Caps Lock": 20
		"Esc": 27
		"Escape": 27
		"Space": 32
		" ": 32
		"PgUp": 33
		"Page Up": 33
		"PgDn": 34
		"End": 35
		"Home": 36
		"Left": 37
		"Up": 38
		"Right": 39
		"Down": 40
		"Insert": 45
		"Del": 46
		"Delete": 46
		"Times": 106
		"*": 106
		"Plus": 107
		"+": 107
		"Minus": 109
		"-": 109
		"Div": 111
		"Divide": 111
		"/": 111
		"Semi-Colon": 186
		";": 187
		"Equal": 187
		"=": 187
		"Comma": 188
		",": 188
		"Dash": 189
		"-": 189
		"Dot": 190
		"Period": 190
		".": 190
		"Forward Slash": 191
		"/": 191
		"Back Slash": 220
		"\\": 220
		"Single Quote": 222
		"'": 222
	for a in "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		keyCode[a] = keyCode[a.toLowerCase()] = a.charCodeAt(0)
	for a in $.range(1,13)
		keyCode["F"+a] = keyCode["f"+a] = 111 + a
	keyName = {}
	for name, code of keyCode
		keyName[code] or= name
	return $:
		keyCode: (name) -> keyCode[name] ? name
		keyName: (code) -> keyName[code] ? code
$.plugin
	depends: "dom,promise"
	provides: "lazy"
, ->
	lazy_load = (elementName, props) ->
		ret = $.Promise()
		document.head.appendChild elem = $.extend document.createElement(elementName), props,
			onload: -> ret.resolve elem
			onerror: -> ret.reject.apply ret, arguments
		ret
	$:
		script: (src) ->
			lazy_load "script", { src: src }
		style: (src) ->
			lazy_load "link", { href: src, rel: "stylesheet" }
$.plugin
	provides: "matches"
, ->
	matches = (pattern, obj) ->
		if pattern is matches.Any
			return true
		obj_type = $.type obj
		switch $.type pattern
			when 'null','undefined' then return (obj is pattern)
			when 'function'
				switch obj_type
					when 'array','bling' then for v in obj when (pattern is v) then return true
					when 'object' then for k,v of obj when (matches pattern, v) then return true
				return false
			when 'regexp'
				switch obj_type
					when 'null','undefined' then return false
					when 'string' then return pattern.test obj
					when 'number' then return pattern.test String(obj)
					when 'array','bling' then for v in obj when pattern.test v then return true
				return false
			when 'object'
				switch obj_type
					when 'null','undefined','string','number' then return false
					when 'array','bling' then for v in obj when matches pattern, v then return true
					when 'object' # dont match if any of the keys dont match
						for k, v of pattern when not matches v, obj[k] then return false
						return true # matches if all keys match
				return false
			when 'array'
				switch obj_type
					when 'null','undefined','string','number','object' then return false
					when 'array','bling'
						for k,v of pattern when not (matches v, obj[k]) then return false
						return true # an empty array matches true against any other array
				return false
			when 'number'
				switch obj_type
					when 'null','undefined','object','string' then return false
					when 'number' then return (obj is pattern)
					when 'array','bling' then for v in obj when matches pattern, v then return true
				return false
			when 'string'
				switch obj_type
					when 'null','undefined','object' then return false
					when 'string' then return (obj is pattern)
					when 'array','bling' then for v in obj when matches pattern, v then return true
				return false
			else return obj is pattern
	class matches.Any # magic token
		@toString: -> "{Any}"
		@inspect:  -> "{Any}"
	return $: matches: matches
$.plugin
	provides: "math"
	depends: "core"
, ->
	$.type.extend
		bool: { number: (o) -> if o then 1 else 0 }
		number: { bool: (o) -> not not o }
	_By = (cmp) ->
		(field) ->
			valueOf = switch $.type field
				when "string" then (o) -> o[field]
				when "function" then field
				else throw new Error ".maxBy first argument should be a string or function"
			x = @first()
			@skip(1).each ->
				if cmp valueOf(@), valueOf(x)
					x = @
			return x
	$:
		range: (start, end, step = 1) ->
			if not end? then (end = start; start = 0)
			step *= -1 if end < start and step > 0 # force step to have the same sign as start->end
			$( (start + (i*step)) for i in [0...Math.ceil( (end - start) / step )] )
		zeros: (n, z = 0) -> $( z for i in [0...n] )
		ones: (n) -> $( 1 for i in [0...n] )
		deg2rad: (n) -> n * Math.PI / 180
		rad2deg: (n) -> n * 180 / Math.PI
	floats: -> @map parseFloat
	ints: -> @map -> parseInt @, 10
	px: (delta) -> @ints().map -> $.px @,delta
	min: -> @filter( isFinite ).reduce Math.min
	max: -> @filter( isFinite ).reduce Math.max
	maxBy: _By (a,b) -> a > b
	minBy: _By (a,b) -> a < b
	mean: mean = -> if not @length then 0 else @sum() / @length
	avg: mean
	sum: -> @filter( isFinite ).reduce(((a) -> a + @), 0)
	product: -> @filter( isFinite ).reduce (a) -> a * @
	squares: -> @pow(2)
	pow: (n) -> @map -> Math.pow @, n
	magnitude: -> Math.sqrt @floats().squares().sum()
	scale: (r) -> @map -> r * @
	add: add = (d) -> switch $.type(d)
		when "number" then @map -> d + @
		when "bling","array" then $( @[i]+d[i] for i in [0...Math.min(@length,d.length)] )
	plus: add
	sub: sub = (d) -> switch $.type d
		when "number" then @map -> @ - d
		when "bling","array" then $( @[i]-d[i] for i in [0...Math.min @length, d.length])
	minus: sub
	dot: (b) ->
		$.sum( @[i]*b[i] for i in [0...Math.min(@length,b.length)] )
	angle: (b) -> Math.acos (@dot(b) / (@magnitude() * b.magnitude()))
	cross: (b) ->
		$ @[1]*b[2] - @[2]*b[1],
			@[2]*b[0] - @[0]*b[2],
			@[0]*b[1] - @[1]*b[0]
	normalize: -> @scale 1 / @magnitude()
	deg2rad: -> @filter( isFinite ).map -> @ * Math.PI / 180
	rad2deg: -> @filter( isFinite ).map -> @ * 180 / Math.PI
$.plugin
	depends: 'function,hash'
	provides: 'memoize'
, ->
	plainCache = ->
		data = {}
		return {
			has: (k) -> k of data
			get: (k) -> data[k]
			set: (k,v) -> data[k] = v
		}
	$:
		memoize: (opts) ->
			if $.is 'function', opts
				opts = f: opts
			if not $.is 'object', opts
				throw new Error "Argument Error: memoize requires either a function or object as first argument"
			opts.cache or= plainCache()
			opts.hash or= $.hash
			return ->
				key = opts.hash arguments
				if opts.cache.has key then opts.cache.get key
				else opts.cache.set key, opts.f.apply @, arguments
$.plugin
	provides: 'middleware',
	depends: 'type'
, ->
	$.type.register 'middleware', is: (o) ->
		try return $.are 'function', o.use, o.unuse, o.invoke
		catch err then return false
	$: middleware: (s = []) ->
		use:    (f)    -> s.push f                                  ; @
		unuse:  (f)    -> s.splice i, 1 while (i = s.indexOf f) > -1; @
		invoke: (a...) -> i = -1; do n = (-> try s[++i] a..., n)    ; @
$.plugin
	depends: "core,function"
	provides: "promise"
, ->
	class NoValue # a named totem
	Promise = (obj = {}) ->
		waiting = []
		err = result = NoValue
		consume_all = (e, v) ->
			while w = waiting.shift()
				consume_one w, e, v
			null
		consume_one = (cb, e, v) ->
			cb.timeout?.cancel()
			try cb e, v
			catch _e
				try cb _e, null
				catch __e
					$.log "Fatal error in promise callback:", \
						__e?.stack ? __e, "caused by:", _e?.stack ? _e
			null
		end = (error, value) =>
			if err is result is NoValue
				if error isnt NoValue
					err = error
				else if value isnt NoValue
					result = value
				switch
					when value is @
						return end new TypeError "cant resolve a promise with itself"
					when $.is 'promise', value then value.wait end
					when error isnt NoValue then consume_all error, null
					when value isnt NoValue then consume_all null, value
			return @
		ret = $.inherit {
			promiseId: $.random.string 6
			wait: (timeout, cb) -> # .wait([timeout], callback) ->
				if $.is 'function', timeout
					[cb, timeout] = [timeout, Infinity]
				if err isnt NoValue
					$.immediate -> consume_one cb, err, null
				else if result isnt NoValue
					$.immediate -> consume_one cb, null, result
				else # this promise hasn't been resolved OR rejected yet
					waiting.push cb # so save this callback for later
					if isFinite parseFloat timeout
						cb.timeout = $.delay timeout, ->
							if (i = waiting.indexOf cb) > -1
								waiting.splice i, 1
								consume_one cb, err = 'timeout', undefined
				@
			then: (f, e) -> @wait (err, x) ->
				if err
					if e? then e(err)
					else throw err
				else f(x)
			finish:  (value) -> end NoValue, value; @
			resolve: (value) -> end NoValue, value; @
			fail:    (error) -> end error, NoValue; @
			reject:  (error) -> end error, NoValue; @
			reset:  -> # blasphemy!
				err = result = NoValue; @
			handler: (err, data) ->
				if err then ret.reject(err) else ret.resolve(data)
			inspect: -> "{Promise[#{@promiseId}] #{getState()}}"
			toString: -> "{Promise[#{@promiseId}] #{getState()}}"
		}, $.EventEmitter(obj)
		getState = -> switch
			when result isnt NoValue then "resolved"
			when err isnt NoValue then "rejected"
			else "pending"
		isFinished = -> result isnt NoValue
		$.defineProperty ret, 'finished', get: isFinished
		$.defineProperty ret, 'resolved', get: isFinished
		isFailed = -> err isnt NoValue
		$.defineProperty ret, 'failed',   get: isFailed
		$.defineProperty ret, 'rejected', get: isFailed
		return ret
	Promise.compose = Promise.parallel = (promises...) ->
		p = $.Progress(1 + promises.length)
		$(promises).select('wait').call (err) ->
			if err then p.reject(err) else p.resolve 1
		p.resolve 1
	Promise.collect = (promises) ->
		ret = []
		p = $.Promise()
		unless promises? then return p.resolve(ret)
		q = $.Progress(1 + promises.length)
		for promise, i in promises then do (i) ->
			promise.wait (err, result) ->
				if err then q.reject(err) # any sub-failure is actual failure
				else q.resolve 1, ret[i] = result # put the results in the correct order
		q.then (->p.resolve ret), p.reject
		q.resolve(1)
		p
	Promise.wrapCall = (f, args...) ->
		try p = $.Promise()
		finally # the last argument to f will be a callback that finishes the promise
			args.push (err, result) -> if err then p.reject(err) else p.resolve(result)
			$.immediate -> f args...
	Progress = (max = 1.0) ->
		cur = 0.0
		return $.inherit {
			progress: (args...) ->
				return cur unless args.length
				cur = args[0] ? cur
				max = (args[1] ? max) if args.length > 1
				item = if args.length > 2 then args[2] else cur
				if cur >= max
					@__proto__.__proto__.resolve(item)
				@emit 'progress', cur, max, item
				@
			resolve: (delta, item = delta) ->
				unless isFinite(delta) then delta = 1
				@progress cur + delta, max, item
			finish: (delta, item) -> @resolve delta, item
			include: (promise) ->
				if $.is 'promise', promise
					@progress cur, max + 1
					promise.wait (err) =>
						if err then @reject err
						else @resolve 1
				return @
			inspect: -> "{Progress[#{@promiseId}] #{cur}/#{max}}"
		}, Promise()
	Promise.xhr = (xhr) ->
		try p = $.Promise()
		finally xhr.onreadystatechange = ->
			if @readyState is @DONE
				if @status is 200
					p.resolve xhr.responseText
				else
					p.resolve "#{@status} #{@statusText}"
	$.depend 'dom', ->
		Promise.image = (src) ->
			try p = $.Promise()
			finally $.extend image = new Image(),
				onerror: (e) -> p.resolve e
				onload: -> p.resolve image
				src: src
	$.depend 'type', ->
		$.type.register 'promise', is: (o) ->
			try return (typeof o is 'object')	and 'promiseId' of o and 'then' of o
			catch err then return false
	return $: { Promise, Progress }
$.plugin
	provides: 'prompt,confirm',
	depends: 'synth,keyName'
, ->
	_prompt_css = ->
		unless $("head .prompt").length
			$("head").append "<style class='prompt'>" + $.CSS.stringify(
				".prompt":
					position: "absolute"
					top: 0, left: 0
					width: "100%", height: "100%"
					zIndex: "999999"
					background: "rgba(0,0,0,.4)"
					fontSize: "12px"
					" input":
						padding: "2px"
						margin: "0px 0px 4px -4px"
						width: "100%"
					" button":
						fontSize: "13px"
						".done":
							fontSize: "14px"
					" > center":
						width: "200px"
						height: "44px"
						margin: "20px auto"
						padding: "16px"
						background: "#ffc"
						borderRadius: "5px"
			) + "</style>"
	_prompt = (label, type, cb) ->
		_prompt_css()
		dialog = $.synth("""
			div.prompt center
				input[type=#{type}][placeholder=#{label}] + br +
				button.cancel 'Cancel' +
				button.done 'Done'
		""").appendTo("body").first()
		input = dialog.querySelector("input")
		input.onkeydown = (evt) ->
			switch $.keyName evt.keyCode
				when "Enter"
					done input.value
				when "Esc"
					done null
		doneButton = dialog.querySelector "button.done"
		cancelButton = dialog.querySelector "button.cancel"
		done = (value) ->
			delete doneButton.onclick
			delete cancelButton.onclick
			dialog.parentNode.removeChild(dialog)
			cb value
		doneButton.onclick = -> done input.value
		cancelButton.onclick = -> done null
		null
	_confirm = (args...) ->
		cb = args.pop()
		label = args.shift()
		if args.length > 0
			buttons = args
		else
			buttons = { Yes: true, No: false }
		_prompt_css()
		dialog = $.synth("""
			div.prompt center
				span '#{label}' + br
		""").appendTo("body")
		center = dialog.find('center')
		switch $.type(buttons)
			when 'array','bling'
				for label in buttons
					$.synth("button[value=#{label}] '#{label}'").appendTo center
			when 'object'
				for label,value of buttons
					$.synth("button[value=#{value}] '#{label}'").appendTo center
		dialog.find("button").bind "click", (evt) ->
			dialog.remove()
			cb evt.target.getAttribute('value')
		null
	return $: { prompt: _prompt, confirm: _confirm }
$.plugin
	depends: "core"
	provides: "pubsub"
, ->
	class Hub
		constructor: ->
			@listeners = {} # a mapping of channel name to a list of listeners
		publish: (channel, args...) ->
			caught = null
			for listener in @listeners[channel] or= []
				if @filter(listener, args...)
					try listener(args...)
					catch err
						caught ?= err
			if caught then throw caught
			switch args.length
				when 0 then null
				when 1 then args[0]
				else args
		filter: (listener, message) ->
			if 'patternObject' of listener
				return $.matches listener.patternObject, message
			return true
		publisher: (channel, func) -> # Use as a function decorator
			t = @ # dont use => because we need both t and @ in the new publisher
			-> t.publish channel, func.apply @, arguments
		subscribe: (channel, args...) ->
			func = args.pop()
			if args.length > 0
				func.patternObject = args.pop()
			(@listeners[channel] or= []).push func
			func
		unsubscribe: (channel, func) ->
			if not func?
				@listeners[channel] = []
			else
				a = (@listeners[channel] or= [])
				if (i = a.indexOf func)  > -1
					a.splice i,1
			func
	return {
		$: $.extend new Hub(), { Hub }
	}
$.plugin
	provides: 'random'
	depends: 'type'
, ->
	englishAlphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".split ""
	uuidAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	$: random: do -> # Mersenne Twister algorithm, from the psuedocode on wikipedia
		MT = new Array(624)
		index = 0
		init_generator = (seed) ->
			index = 0
			MT[0] = seed
			for i in [1..623]
				MT[i] = 0xFFFFFFFF & (1812433253 * (MT[i-1] ^ (MT[i-1] >>> 30)) + i)
		generate_numbers = ->
			for i in [0..623]
				y = ((MT[i] & 0x80000000) >>> 31) + (0x7FFFFFFF & MT[ (i+1) % 624 ])
				MT[i] = MT[ (i+397) % 624 ] ^ (y >>> 1)
				if (y%2) is 1
					MT[i] = MT[i] ^ 2567483615
		a = Math.pow(2,31)
		b = a * 2
		next = ->
			if index is 0
				generate_numbers()
			y = MT[index] ^
				(y >>> 11) ^
				((y << 7) and 2636928640) ^
				((y << 15) and 4022730752) ^
				(y >>> 18)
			index = (index + 1) % 624
			(y + a) / b
		$.defineProperty next, "seed",
			set: (v) -> init_generator(v)
		next.seed = +new Date()
		return $.extend next,
			real: real = (min, max) ->
				if not min?
					[min,max] = [0,1.0]
				if not max?
					[min,max] = [0,min]
				($.random() * (max - min)) + min
			integer: integer = (min, max) -> Math.floor $.random.real(min,max)
			string: string = (len, prefix="", alphabet=englishAlphabet) ->
				prefix += $.random.element(alphabet) while prefix.length < len
				prefix
			coin: coin = (balance=.5) -> $.random() <= balance
			element: (arr, weights) ->
				if weights?
					w = $(weights)
					w = w.scale(1.0/w.sum())
					i = 0
					sorted = $(arr).map((x) -> {v: x, w: w[i++] }).sortBy (x) -> -x.w
					r = $.random.real(0.00001,.999999) # never exactly 0.0 or 1.0
					sum = 0
					for item in sorted
						return item.v if (sum += item.w) >= r
				return arr[$.random.integer 0, arr.length]
			gaussian: gaussian = (mean=0.5, ssig=0.12) -> # paraphrased from Wikipedia
				while true
					u = $.random()
					v = 1.7156 * ($.random() - 0.5)
					x = u - 0.449871
					y = Math.abs(v) + 0.386595
					q = (x*x) + y*(0.19600*y-0.25472*x)
					break unless q > 0.27597 and (q > 0.27846 or (v*v) > (-4*Math.log(u)*u*u))
				return mean + ssig*v/u
			dice: dice = (n, faces) -> # a 2d8 is dice(2,8)
				$( die(faces) for _ in [0...n] by 1 )
			die: die = (faces) ->
				$.random.integer(1,faces+1)
			uuid: ->
				$(8,4,4,4,12).map(-> $.random.string @,'',uuidAlphabet).join '-'
$.plugin
	provides: "render"
	depends: "promise"
, ->
	log = $.logger "[render]"
	consume_forever = (promise, opts, p = $.Promise()) ->
		unless $.is "promise", promise
			return $.Promise().resolve(reduce promise, opts)
		promise.wait (err, result) ->
			if err then return p.reject err
			r = reduce result, opts
			if $.is 'promise', r
				consume_forever r, opts, p
			else p.resolve(r)
		p
	render = (o, opts = {}) ->
		consume_forever r = (reduce [ o ], opts), opts
	object_handlers = {
		text: (o, opts) -> reduce o[opts.lang ? "EN"], opts
	}
	render.register = register = (t, f) -> object_handlers[t] = f
	render.reduce = reduce = (o, opts) -> # all objects become either arrays, promises, or strings
		switch t = $.type o
			when "string","html" then o
			when "null","undefined" then t
			when "promise"
				q = $.Promise()
				o.wait finish_q = (err, result) ->
					return q.reject(err) if err
					if $.is 'promise', r = reduce result, opts
						r.wait finish_q
					else
						q.resolve r
				q
			when "number" then String(o)
			when "array", "bling"
				p = $.Progress m = 1 # always start with one step (creation)
				q = $.Promise() # use a summary promise for public view
				p.wait (err) ->
					if err then q.reject(err) else q.resolve(finalize n, opts)
				n = []
				has_promises = false
				for x, i in o then do (x,i) ->
					n[i] = y = reduce x, opts # recurse here
					if $.is 'promise', y
						has_promises = true
						p.progress null, ++m
						y.wait finish_p = (err, result) -> # recursive promise trampoline
							return p.reject(err) if err
							rp = reduce result, opts
							if $.is 'promise', rp
								rp.wait finish_p
							else
								p.resolve n[i] = rp
				p.resolve(1) # creation is complete
				if has_promises then q
				else finalize n
			when "function" then switch f.length
				when 0,1 then reduce f(opts)
				else $.Promise.wrap f, opts
			when "object"
				if (t = o.t ? o.type) of object_handlers
					object_handlers[t].call o, o, opts
				else "[ no handler for object type: '#{t}' #{JSON.stringify(o).substr 0,20}... ]"
			else "[ cant reduce type: #{t} ]"
	finalize = (o, opts) ->
		return switch t = $.type o
			when "string","html" then o
			when "number" then String(o)
			when "array","bling" then (finalize(x, opts) for x in o).join ''
			when "null","undefined" then t
			else "[ cant finalize type: #{t} ]"
	register 'link', (o, opts) -> [
		"<a"
			[" #{k}='",o[k],"'"] for k in ["href","name","target"] when k of o
		">",reduce(o.content,opts),"</a>"
	]
	register 'let', (o, opts) ->
		save = opts[o.name]
		opts[o.name] = o.value
		try return reduce o.content, opts
		finally
			if save is undefined then delete opts[o.name]
			else opts[o.name] = save
	register 'get', (o, opts) -> reduce opts[o.name], opts
	return $: { render }
$.plugin
	provides: "sendgrid"
	depends: "config"
, ->
	try
		nodemailer = require 'nodemailer'
	catch err
		return
	transport = null
	openTransport = ->
		transport or= nodemailer.createTransport 'SMTP',
			service: 'SendGrid'
			auth:
				user: $.config.get 'SENDGRID_USERNAME'
				pass: $.config.get 'SENDGRID_PASSWORD'
	closeTransport = ->
		transport?.close()
		transport = null
	$:
		sendMail: (mail, callback) ->
			mail.transport ?= openTransport()
			mail.from ?= $.config.get 'EMAILS_FROM'
			mail.bcc ?= $.config.get 'EMAILS_BCC'
			if $.config.get('SENDGRID_ENABLED', 'true') is 'true'
				nodemailer.sendMail mail, (err) ->
					if mail.close
						closeTransport()
					callback(err)
			else
				if mail.close
					closeTransport()
				callback(false) # Reply as if an email was sent
$.plugin
	provides: "sortBy,sortedIndex,sortedInsert"
, ->
	$:
		sortedIndex: (array, item, iterator, lo = 0, hi = array.length) ->
			cmp = switch $.type iterator
				when "string" then (a,b) -> a[iterator] < b[iterator]
				when "function" then (a,b) -> iterator(a) < iterator(b)
				else (a,b) -> a < b
			while lo < hi
				mid = (hi + lo)>>>1
				if cmp array[mid], item
					lo = mid + 1
				else
					hi = mid
			return lo
	sortBy: (iterator) ->
		a = $()
		for item in @
			n = $.sortedIndex a, item, iterator
			a.splice n, 0, item
		a
	sortedInsert: (item, iterator) ->
		@splice ($.sortedIndex @, item, iterator), 0, item
		@
$.plugin
	provides: "StateMachine"
	depends: "type"
, ->
	$: StateMachine: class StateMachine
		constructor: (stateTable) ->
			@debug = false
			@reset()
			@table = stateTable
			Object.defineProperty @, "modeline",
				get: -> @table[@_mode]
			Object.defineProperty @, "mode",
				set: (m) ->
					@_lastMode = @_mode
					@_mode = m
					if @_mode isnt @_lastMode and @modeline? and 'enter' of @modeline
						ret = @modeline['enter'].call @
						while $.is("function",ret)
							ret = ret.call @
					m
				get: -> @_mode
		reset: ->
			@_mode = null
			@_lastMode = null
		GO: go = (m, enter=false) -> ->
			if enter # force enter to trigger
				@_mode = null
			@mode = m
		@GO: go
		tick: (c) ->
			row = @modeline
			if not row?
				ret = null
			else if c of row
				ret = row[c]
			else if 'def' of row
				ret = row['def']
			while $.is "function",ret
				ret = ret.call @, c
			ret
		run: (inputs) ->
			@mode = 0
			for c in inputs
				ret = @tick(c)
			if $.is "function",@modeline?.eof
				ret = @modeline.eof.call @
			while $.is "function",ret
				ret = ret.call @
			@reset()
			return @
$.plugin
	provides: "string"
	depends: "type"
, ->
	safer = (f) -> (a...) ->
		try return f(a...)
		catch err then return "[Error: #{err.message}]"
	escape_single_quotes = (s) -> s.replace(/([^\\]{1})'/g,"$1\\'")
	$.type.extend
		unknown:
			string: safer (o) -> o.toString?() ? String(o)
			repr: safer (o) -> $.type.lookup(o).string(o)
			number: safer (o) -> parseFloat String o
		null:
			string: -> "null"
		undefined:
			string: -> "undefined"
		buffer:
			string: safer (o) -> String(o)
			repr:   safer (o) -> "Buffer(#{JSON.stringify o.toJSON()})"
		string:
			number: safer parseFloat
			repr: (s) -> "'#{escape_single_quotes s}'"
		array:
			string: safer (a) -> "[#{a.map($.toString).join(', ')}]"
			repr:   safer (a) -> "[#{a.map($.toRepr).join(', ')}]"
		arguments:
			string: safer (a) -> "[#{($.toString(x) for x in a).join(', ')}]"
			repr: safer (a) -> "[#{($.toRepr(x) for x in a).join(', ')}]"
		object:
			string: safer (o) ->
				ret = []
				for k of o
					try v = o[k]
					catch err
						v = "[Error: #{err.message}]"
					ret.push "#{k}:#{$.toString v}"
				"{" + ret.join(', ') + "}"
			repr: safer (o) ->
				ret = []
				for k of o
					try v = o[k]
					catch err
						v = "[Error: #{err.message}]"
					ret.push "\"#{k}\": #{$.toRepr v}"
				"{" + ret.join(', ') + "}"
		function:
			repr: (f) -> f.toString()
			string: (f) -> f.toString().replace(/^([^{]*){(?:.|\n|\r)*}$/, '$1{ ... }')
		number:
			repr: (n) -> String(n)
			string: safer (n) -> switch
				when n.precision? then n.toPrecision(n.precision)
				when n.fixed? then n.toFixed(n.fixed)
				else String(n)
	return {
		$:
			toString: (x) ->
				if arguments.length is 0 then "function Bling() { [ ... ] }"
				else
					try
						$.type.lookup(x).string(x)
					catch err
						"[Error: #{err.message}]"
			toRepr: (x) -> $.type.lookup(x).repr(x)
			px: (x, delta=0) -> x? and (parseInt(x,10)+(parseInt(delta)|0))+"px"
			capitalize: (name) ->
				(name.split(" ").map (x) -> x[0].toUpperCase() + x.substring(1).toLowerCase()).join(" ")
			slugize: slugize = (phrase, slug="-") ->
				phrase = switch $.type phrase
					when 'null','undefined' then ""
					when 'object' then ($.slugize(k,slug) + slug + $.slugize(v, slug) for k,v of phrase).join slug
					when 'array','bling' then phrase.map((item)-> $.slugize item, slug).join slug
					else String(phrase)
				phrase.toLowerCase() \
					.replace(/^\s+/, '') \
					.replace(/\s+$/, '') \
					.replace(/\t/g, ' ') \
					.replace(/[^A-Za-z0-9. -]/g, '') \
					.replace(/\s+/g,'-')
			stubize: slugize
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
				name = $.slugize(name)
				name.split('-')
				while (i = name?.indexOf('-')) > -1
					name = $.stringSplice(name, i, i+2, name[i+1].toUpperCase())
				name
			commaize: (num, comma=',',dot='.',currency='') ->
				if $.is('number', num) and isFinite(num)
					s = String(num)
					sign = if (num < 0) then "-" else ""
					[a, b] = s.split '.' # split the whole part from the decimal part
					if a.length > 3 # if the whole part is long enough to need commas
						a = $.stringReverse $.stringReverse(a).match(/\d{1,3}/g).join comma
					return sign + currency + a + (if b? then dot+b else "")
				else if (typeof(num) is 'number' and isNaN(num)) or num in [Infinity, -Infinity]
					return String num
				else return undefined
			padLeft: (s, n, c = " ") ->
				while s.length < n
					s = c + s
				s
			padRight: (s, n, c = " ") ->
				while s.length < n
					s = s + c
				s
			stringTruncate: (s, n, c='...',sep=' ') ->
				return s if s.length <= n
				return c if c.length >= n
				s = s.split(sep) # split into words.
				r = []
				while n > 0
					x = s.shift()
					n -= x.length
					if n >= 0
						r.push x
				r.join(sep) + c
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
			stringReverse: (s) -> s.split('').reverse().join('')
			checksum: (s) ->
				a = 1; b = 0
				for i in [0...s.length]
					a = (a + s.charCodeAt(i)) % 65521
					b = (b + a) % 65521
				(b << 16) | a
			repeat: (x, n=2) -> switch
				when n is 1 then x
				when n < 1 then ""
				when $.is "string", x then $.zeros(n, x).join ''
				else $.zeros(n, x)
			stringBuilder: do ->
				len = (s) -> s?.toString().length | 0
				->
					if $.is("global", @) then return new $.stringBuilder()
					items = []
					$.extend @,
						length: 0
						append:  (s) => items.push s; @length += len s
						prepend: (s) => items.splice 0,0,s; @length += len s
						clear:       => ret = @toString(); items = []; @length = 0; ret
						toString:    -> items.join("")
		toString: -> $.toString @
		toRepr: -> $.toRepr @
		replace: (patt, repl) ->
			@map (s) -> s.replace(patt, repl)
		indexOf: (target, offset=0) ->
			if $.is 'regexp', target
				for i in [offset...@length] by 1
					if target.test @[i]
						return i
				return -1
			else Array::indexOf.apply @, arguments
	}
$.plugin
	provides: "symbol"
	depends: "type"
, ->
	symbol = null
	cache = {}
	g = $.global
	g['Bling'] = $
	if module?
		module.exports = $
	$.defineProperty $, "symbol",
		set: (v) ->
			g[symbol] = cache[symbol]
			cache[symbol = v] = g[v]
			g[v] = Bling
		get: -> symbol
	return $:
		symbol: "$"
		noConflict: ->
			$.symbol = "Bling"
			Bling
$.plugin
	provides: "synth"
	depends: "StateMachine, type"
, ->
	class SynthMachine extends $.StateMachine
		basic =
			"#": @GO 2
			".": @GO 3, true
			"[": @GO 4
			'"': @GO 6
			"'": @GO 7
			" ": @GO 8
			"\t": @GO 8
			"\n": @GO 8
			"\r": @GO 8
			",": @GO 10
			"+": @GO 11
			eof: @GO 13
		@STATE_TABLE = [
			{ # 0: START
				enter: ->
					@tag = @id = @cls = @attr = @val = @text = ""
					@attrs = {}
					@GO 1
			},
			$.extend({ # 1: read a tag name
				def: (c) -> @tag += c
			}, basic),
			$.extend({ # 2: read an #id
				def: (c) -> @id += c
			}, basic),
			$.extend({ # 3: read a .class name
				enter: -> @cls += " " if @cls.length > 0
				def: (c) -> @cls += c
			}, basic),
			{ # 4: read an attribute name (left-side)
				"=": @GO 5
				"]": -> @attrs[@attr] = @val; @attr = @val = ""; @GO 1
				def: (c) -> @attr += c
				eof: @GO 12
			},
			{ # 5: read an attribute value (right-side)
				"]": -> @attrs[@attr] = @val; @attr = @val = ""; @GO 1
				def: (c) -> @val += c
				eof: @GO 12
			},
			{ # 6: read double-quoted text
				'"': @GO 8
				def: (c) -> @text += c
				eof: @GO 12
			},
			{ # 7: read single-quoted text
				"'": @GO 8
				def: (c) -> @text += c
				eof: @GO 12
			},
			{ # 8: emit text and continue
				enter: ->
					@emitNode() if @tag
					@emitText() if @text
					@GO 0
			},
			{}, # 9: empty
			{ # 10: emit node and start a new tree
				enter: ->
					@emitNode()
					@cursor = null
					@GO 0
			},
			{ # 11: emit node and step sideways to create a sibling
				enter: ->
					@emitNode()
					@cursor = @cursor?.parentNode
					@GO 0
			},
			{ # 12: ERROR
				enter: -> throw new Error "Error in synth expression: #{@input}"
			},
			{ # 13: FINALIZE
				enter: ->
					@emitNode() if @tag
					@emitText() if @text
			}
		]
		constructor: ->
			super(SynthMachine.STATE_TABLE)
			@fragment = @cursor = document.createDocumentFragment()
		emitNode: ->
			if @tag
				node = document.createElement @tag
				if @id then node.id = @id
				if @cls then node.className = @cls
				for k of @attrs
					node.setAttribute k, @attrs[k]
				@cursor.appendChild node
				@cursor = node
		emitText: ->
			@cursor.appendChild $.type.lookup("<html>").node(@text)
			@text = ""
	return {
		$:
			synth: (expr) ->
				s = new SynthMachine()
				s.run(expr)
				if s.fragment.childNodes.length == 1
					$(s.fragment.childNodes[0])
				else
					$(s.fragment)
	}
$.plugin
	depends: "StateMachine, function"
	provides: "template"
, -> # Template plugin, pythonic style: %(value).2f
	current_engine = null
	engines = {}
	template = {
		register_engine: (name, render_func) ->
			engines[name] = render_func
			if not current_engine?
				current_engine = name
		render: (text, args) ->
			if current_engine of engines
				engines[current_engine](text, args)
	}
	template.__defineSetter__ 'engine', (v) ->
		if not v of engines
			throw new Error "invalid template engine: #{v} not one of #{Object.Keys(engines)}"
		else
			current_engine = v
	template.__defineGetter__ 'engine', -> current_engine
	template.__defineGetter__ 'engines', -> $.keysOf(engines)
	template.register_engine 'null', do ->
		return $.identity
	match_forward = (text, find, against, start, stop = -1) ->
		count = 1
		if stop < 0
			stop = text.length + 1 + stop
		for i in [start...stop] by 1
			t = text[i]
			if t is against
				count += 1
			else if t is find
				count -= 1
			if count is 0
				return i
		return -1
	template.register_engine 'pythonic', do ->
		type_re = /([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/
		chunk_re = /%[\(\/]/
		compile = (text) ->
			chunks = text.split chunk_re
			n = chunks.length
			ret = [chunks[0]]
			j = 1 # insert marker into ret
			for i in [1...n] by 1
				end = match_forward chunks[i], ')', '(', 0, -1
				if end is -1
					return "Template syntax error: unmatched '%(' starting at: #{chunks[i].substring(0,15)}"
				key = chunks[i].substring 0, end
				rest = chunks[i].substring end
				match = type_re.exec rest
				if match is null
					return "Template syntax error: invalid type specifier starting at '#{rest}'"
				rest = match[4]
				ret[j++] = key
				ret[j++] = match[1]|0
				ret[j++] = match[2]|0
				ret[j++] = match[3]
				ret[j++] = rest
			return ret
		compile.cache = {}
		render = (text, values) -> # replace markers in /text/ with /values/
			cache = compile.cache[text] # get the cached version
			if not cache?
				cache = compile.cache[text] = compile(text) # or compile and cache it
			output = [cache[0]] # the first block is always just text
			j = 1 # insert marker into output
			n = cache.length
			for i in [1..n-5] by 5
				[key, pad, fixed, type, rest] = cache[i..i+4]
				value = values[key]
				if not value?
					value = "missing value: #{key}"
				switch type
					when 'd'
						output[j++] = "" + parseInt(value, 10)
					when 'f'
						output[j++] = parseFloat(value).toFixed(fixed)
					when 's'
						output[j++] = "" + value
					else
						output[j++] = "" + value
				if pad > 0
					output[j] = String.PadLeft output[j], pad
				output[j++] = rest
			output.join ""
		return render
	template.register_engine 'js-eval', do -> # work in progress...
		class TemplateMachine extends $.StateMachine
			@STATE_TABLE = [
				{ # 0: START
					enter: () ->
						@data = []
						@GO(1)
				},
				{ # 1: read anything
				}
			]
		return $.identity
	return $: { template }
$.plugin
	provides: "throttle"
	depends: "core"
, ->
	$:
		throttle: (ms, f) ->
			last = 0
			(a...) ->
				gap = $.now - last
				if gap > ms
					last += gap
					return f.apply @,a
				null
		debounce: (ms, f) ->
			timeout = null
			->
				a = arguments
				clearTimeout timeout
				setTimeout (=>
					f.apply @, a
				), ms
$.plugin
	provides: 'TNET'
	depends: 'type, string, function'
, -> # TnetStrings plugin
	Types =
		"number":
			symbol: "#"
			pack: String
			unpack: Number
		"string":
			symbol: "'"
			pack: $.identity
			unpack: $.identity
		"bool":
			symbol: "!"
			pack: (b) -> String(not not b)
			unpack: (s) -> s is "true"
		"null":
			symbol: "~"
			pack: -> ""
			unpack: -> null
		"undefined":
			symbol: "_"
			pack: -> ""
			unpack: -> undefined
		"array":
			symbol: "]"
			pack: (a) -> (packOne(y) for y in a).join('')
			unpack: (s) ->
				data = []
				while s.length > 0
					[one, s] = unpackOne(s)
					data.push(one)
				data
		"bling":
			symbol: "$"
			pack: (a) -> (packOne(y) for y in a).join('')
			unpack: (s) ->
				data = $()
				while s.length > 0
					[one, s] = unpackOne(s)
					data.push(one)
				data
		"object":
			symbol: "}"
			pack: (o) ->
				(packOne(k)+packOne(v) for k,v of o when k isnt "constructor" and o.hasOwnProperty(k)).join ''
			unpack: (s) ->
				data = {}
				while s.length > 0
					[key, s] = unpackOne(s)
					[value, s] = unpackOne(s)
					data[key] = value
				data
		"function":
			symbol: ")"
			pack: (f) ->
				s = f.toString().replace(/(?:\n|\r)+\s*/g,' ')
				name = ""
				name_re = /function\s*(\w+)\(.*/g
				if name_re.test s
					name = s.replace name_re, "$1"
				[args, body] = s.replace(/function\s*\w*\(/,'')
					.replace(/\/\*.*\*\//g,'')
					.replace(/}$/,'')
					.split(/\) {/)
				args = args.split /, */
				body = body.replace(/^\s+/,'').replace(/\s*$/,'')
				return $( name, args, body ).map(packOne).join ''
			unpack: (s) ->
				[name, rest] = unpackOne(s)
				[args, rest] = unpackOne(rest)
				[body, rest] = unpackOne(rest)
				return makeFunction name, args.join(), body
		"regexp":
			symbol: "/"
			pack: (r) -> String(r).slice(1,-1)
			unpack: (s) -> RegExp(s)
		"class instance":
			symbol: "C"
			pack: (o) ->
				unless 'constructor' of o
					throw new Error("TNET: cant pack non-class as class")
				unless o.constructor of class_index
					throw new Error("TNET: cant pack unregistered class (name: #{o.constructor.name}")
				packOne(class_index[o.constructor]) + packOne(o, "object")
			unpack: (s) ->
				[i, rest] = unpackOne(s)
				[obj, rest] = unpackOne(rest)
				if i <= classes.length
					obj.__proto__ = classes[i - 1].prototype
				else throw new Error("TNET: attempt to unpack unregistered class index: #{i}")
				obj
	makeFunction = (name, args, body) ->
		eval("var f = function #{name}(#{args}){#{body}}")
		return f
	classes = []
	class_index = {}
	register = (klass) ->
		class_index[klass] or= classes.push klass
	Symbols = {} # Reverse lookup table, for use during unpacking
	do -> for t,v of Types
		Symbols[v.symbol] = v
	unpackOne = (data) ->
		return data unless data?
		if (i = data.indexOf ":") > 0
			x = i+1+parseInt data[0...i], 10
			return [
				Symbols[data[x]]?.unpack(data[i+1...x]),
				data[x+1...]
			]
		return undefined
	packOne = (x, forceType) ->
		if forceType?
			tx = forceType
		else
			tx = $.type x
			if tx is "unknown" and not (x.constructor?.name in [undefined, "Object"])
				tx = "class instance"
		unless (t = Types[tx])?
			throw new Error("TNET: I don't know how to pack type '#{tx}' (#{x.constructor?.name})")
		data = t.pack(x)
		return (data.length) + ":" + data + t.symbol
	$:
		TNET:
			Types: Types
			registerClass: register
			stringify: packOne
			parse: (x) -> unpackOne(x)?[0]
$.plugin
	provides: "trace"
	depends: "function,type"
, ->
	$.type.extend
		unknown:  { trace: $.identity }
		object:   { trace: (label, o, tracer) ->
			(o[k] = $.trace(o[k], "#{label}.#{k}", tracer) for k in Object.keys(o))
			o
		}
		array:    { trace: (label, o, tracer) ->
			(o[i] = $.trace(o[i], "#{label}[#{i}]", tracer) for i in [0...o.length] by 1)
			o
		}
		bling:    { trace: (label, o, tracer) ->
			(o[i] = $.trace(o[i], "#{label}[#{i}]", tracer) for i in [0...o.length] by 1)
			o
		}
		function: { trace: (label, f, tracer) ->
			label or= f.name
			r = (a...) ->
				start = +new Date
				f.apply @, a
				label = "#{@name or $.type(@)}.#{label}"
				args = $(a).map($.toRepr).join ','
				elapsed = (+new Date - start).toFixed 0
				tracer "#{label}(#{args}): #{elapsed}ms"
			r.toString = -> "{Trace '#{label}' of #{f.toString()}"
			r
		}
	time = (label, f, logger) ->
		unless $.is "string", label
			[f, logger, label] = [label, f, "trace"]
		unless $.is "function", logger
			logger = $.log
		start = +new Date
		ret = do f
		logger "[#{label}] #{(+new Date - start).toFixed 0}ms"
		return ret
	return $:
		time: time
		trace: (label, o, tracer) ->
			unless $.is "string", label
				[tracer, o] = [o, label]
			tracer or= $.log
			label or= ""
			$.type.lookup(o).trace(label, o, tracer)
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
			if callback
				@delay duration, $.bound @, callback
		hide: (callback) -> # .hide() - each node gets display:none
			@each ->
				if @style
					@_display = "" # stash the old display
					if @style.display is not "none"
						@_display = @syle.display
					@style.display = "none"
			.trigger("hide")
			if callback
				@delay updateDelay, $.bound @, callback
			@
		show: (callback) -> # .show() - show each node
			@each ->
				if @style
					@style.display = @_display
					delete @_display
			.trigger("show")
			if callback
				@delay updateDelay, $.bound @, callback
			@
		toggle: (callback) -> # .toggle() - show each hidden node, hide each visible one
			@weave(@css("display"))
				.fold((display, node) ->
					if display is "none"
						node.style.display = node._display or ""
						delete node._display
						$(node).trigger "show"
					else
						node._display = display
						node.style.display = "none"
						$(node).trigger "hide"
					node
				).delay(updateDelay, $.bound @, callback)
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
			}, speed, -> @hide($.bound @, callback)
		fadeLeft: (speed, callback) -> @fadeOut speed, callback, "-"+@width().first(), 0.0
		fadeRight: (speed, callback) -> @fadeOut speed, callback, @width().first(), 0.0
		fadeUp: (speed, callback) -> @fadeOut speed, callback, 0.0, "-"+@height().first()
		fadeDown: (speed, callback)  -> @fadeOut speed, callback, 0.0, @height().first()
	}
$.plugin
	provides: "type,is,inherit,extend,defineProperty,isType,are,as,isSimple,isDefined,isEmpty"
	depends: "compat"
, ->
	isType = (T, o) ->
		if not o? then T in [o,"null","undefined"]
		else (o.constructor? and (o.constructor is T or o.constructor.name is T)) or
			Object::toString.apply(o) is "[object #{T}]" or
			isType T, o.__proto__ # recursive
	inherit = (parent, objs...) ->
		return unless objs.length > 0
		obj = objs.shift()
		if typeof parent is "function"
			parent = parent.prototype
		if parent.__proto__ in [Object.prototype, null, undefined]
			parent.__proto__ = obj.__proto__
		obj.__proto__ = parent
		if objs.length > 0
			return inherit obj, objs...
		else obj
	_type = do ->
		cache = {}
		base =
			name: 'unknown'
			is: -> true
		order = []
		_with_cache = {} # for finding types that have a certain method { method: [ types ] }
		_with_insert = (method, type) ->
			a = (_with_cache[method] or= [])
			if (i = a.indexOf type) is -1
				a.push type
		register = (name, data) ->
			unless 'is' of data
				throw new Error("$.type.register given a second argument without an 'is' function")
			order.unshift name if not (name of cache)
			cache[data.name = name] = if (base isnt data) then (inherit base, data) else data
			cache[name][name] = (o) -> o
			for key of cache[name]
				_with_insert key, cache[name]
		_extend = (name, data) ->
			if typeof name is "string"
				cache[name] or= register name, {}
				cache[name] = extend cache[name], data
				for method of data
					_with_insert method, cache[name]
			else if typeof name is "object"
				(_extend k, name[k]) for k of name
		lookup = (obj) ->
			for name in order
				if cache[name]?.is.call obj, obj
					return cache[name]
		register "unknown",   base
		register "object",    is: (o) -> typeof o is "object" and (o.constructor?.name in [undefined, "Object"])
		register "array",     is: Array.isArray or (o) -> isType Array, o
		register "buffer",    is: Buffer.isBuffer or -> false
		register "error",     is: (o) -> isType 'Error', o
		register "regexp",    is: (o) -> isType 'RegExp', o
		register "string",    is: (o) -> typeof o is "string" # or isType String, o
		register "number",    is: (o) -> typeof o is "number" and not isNaN(o)
		register "bool",      is: (o) -> typeof o is "boolean" # or try String(o) in ["true","false"]
		register "function",  is: (o) -> typeof o is "function"
		register "global",    is: (o) -> typeof o is "object" and 'setInterval' of o
		register "arguments", is: (o) -> try 'callee' of o and 'length' of o
		register "undefined", is: (x) -> x is undefined
		register "null",      is: (x) -> x is null
		return extend ((o) -> lookup(o).name),
			register: register
			lookup: lookup
			extend: _extend
			get: (t) -> cache[t]
			is: (t, o) -> cache[t]?.is.call o, o
			as: (t, o, rest...) -> lookup(o)[t]?(o, rest...)
			with: (f) -> _with_cache[f] ? []
	_type.extend
		unknown:   { array: (o) -> [o] }
		null:      { array:     -> [] }
		undefined: { array:     -> [] }
		array:     { array: (o) -> o }
		number:    { array: (o) -> $.extend new Array(o), length: 0 }
		arguments: { array: (o) -> Array::slice.apply o }
	maxHash = Math.pow(2,32)
	_type.register "bling",
		is:     (o) -> o and isType $, o
		array:  (o) -> o.toArray()
		hash:   (o) -> o.map($.hash).reduce (a,x) -> ((a*a)+x) % maxHash
		string: (o) -> $.symbol + "([" + o.map((x) -> $.type.lookup(x).string(x)).join(", ") + "])"
		repr:   (o) -> $.symbol + "([" + o.map((x) -> $.type.lookup(x).repr(x)).join(", ") + "])"
	$:
		inherit: inherit
		extend: extend
		defineProperty: (o, name, opts) ->
			Object.defineProperty o, name, extend({ configurable: true, enumerable: true }, opts)
			o
		isType: isType
		type: _type
		is: _type.is
		are: (type, args...) ->
			for a in args
				return false unless $.is type, a
			return true
		as: _type.as
		isDefined: (o) -> o?
		isSimple: (o) -> _type(o) in ["string", "number", "bool"]
		isEmpty: (o) -> o in ["", null, undefined] \
			or o.length is 0 or (typeof o is "object" and Object.keys(o).length is 0)
	defineProperty: (name, opts) -> @each -> $.defineProperty @, name, opts
$.plugin
	depends: 'math'
	provides: 'units'
, ->
	units = $ ["px","pt","pc","em","%","in","cm","mm","ex","lb","kg","yd","ft","m", ""]
	UNIT_RE = null
	do makeUnitRegex = ->
		joined = units.filter(/.+/).join '|'
		UNIT_RE = new RegExp "(\\d+\\.*\\d*)((?:#{joined})/*(?:#{joined})*)$"
	parseUnits = (s) ->
		if UNIT_RE.test(s)
			return UNIT_RE.exec(s)[2]
		""
	conv = (a,b) ->
		[numer_a, denom_a] = a.split '/'
		[numer_b, denom_b] = b.split '/'
		if denom_a? and denom_b?
			return conv(denom_b, denom_a) * conv(numer_a, numer_b)
		if a of conv and (b of conv[a])
			return conv[a][b]()
		0
	locker = (x) -> -> x
	fill = ->
	set = (from, to, f) ->
		conv[from] or= {}
		conv[from][to] = f
		if units.indexOf(from) is -1
			units.push from
		if units.indexOf(to) is -1
			units.push to
		makeUnitRegex()
		fill()
	init = ->
		set 'pc', 'pt', -> 12
		set 'in', 'pt', -> 72
		set 'in', 'px', -> 96
		set 'in', 'cm', -> 2.54
		set 'm', 'ft', -> 3.281
		set 'yd', 'ft', -> 3
		set 'cm', 'mm', -> 10
		set 'm', 'cm', -> 100
		set 'm', 'meter', -> 1
		set 'm', 'meters', -> 1
		set 'ft', 'feet', -> 1
		set 'km', 'm', -> 1000
		set 'em', 'px', ->
			w = 0
			try
				x = $("<span style='font-size:1em;visibility:hidden'>x</span>").appendTo("body")
				w = x.width().first()
				x.remove()
			w
		set 'ex', 'px', ->
			w = 0
			try
				x = $("<span style='font-size:1ex;visibility:hidden'>x</span>").appendTo("body")
				w = x.width().first()
				x.remove()
			w
		set 'ex', 'em', -> 2
		set 'rad', 'deg', -> 57.3
		set 's', 'sec', -> 1
		set 's', 'ms', -> 1000
		set 'ms', 'ns', -> 1000000
		set 'min', 'sec', -> 60
		set 'hr', 'min', -> 60
		set 'hr', 'hour', -> 1
		set 'hr', 'hours', -> 1
		set 'day', 'hr', -> 24
		set 'day', 'days', -> 1
		set 'y', 'year', -> 1
		set 'y', 'years', -> 1
		set 'y', 'd', -> 365.25
		set 'g', 'gram', -> 1
		set 'g', 'grams', -> 1
		set 'kg', 'g', -> 1000
		set 'lb', 'g', -> 453.6
		set 'lb', 'oz', -> 16
		set 'f', 'frame', -> 1
		set 'f', 'frames', -> 1
		set 'sec', 'f', -> 60
		do fill = ->
			conv[''] = {}
			one = locker 1.0
			for a in units
				conv[a] or= {}
				conv[a][a] = conv[a][''] = conv[''][a] = one
			infered = 1
			while infered > 0
				infered = 0
				for a in units when a isnt ''
					conv[a] or= {}
					for b in units when b isnt ''
						if (not conv a,b) and (conv b,a)
							conv[a][b] = locker 1.0/conv(b,a)
							infered += 1
						for c in units when c isnt ''
							if (conv a,b) and (conv b,c) and (not conv a,c)
								conv[a][c] = locker conv(a,b) * conv(b,c)
								infered += 1
			null
		$.units.enable = ->
	convert = (unit, number) ->
		f = parseFloat(number)
		u = parseUnits(number)
		c = conv(u, unit)
		unless isFinite(c) and isFinite(f)
			return number
		"#{f * c}#{unit}"
	$.type.register "units",
		is: (x) -> typeof x is "string" and UNIT_RE.test(x)
		number: (x) -> parseFloat(x)
		string: (x) -> "'#{x}'"
	{
		$:
			units:
				enable: init
				set: set
				get: conv
				convertTo: convert
		convertTo: (unit) -> @map (x) -> convert unit, x
		unitMap: (f) ->
			@map (x) ->
				f.call((n = parseFloat x), n) + parseUnits x
	}
$.plugin
	depends: "type",
	provides: "url,URL"
, ->
	url_re = /\b(?:([a-z+]+):)(?:\/{1,2}([^?\/#]*?))(\/[^?]*)*(?:\?([^#]+))*(?:#([^\s]+))*$/i
	user_pass_re = /^([^:]+):([^@]+)@/
	username_re = /^([^:@]+)@/
	host_port_re = /^([^:]+):(\d+)/
	parse_host = (host) ->
		return {} unless host? and host.length > 0
		ret = { host }
		if ret.host.indexOf(",") > -1 then $.extend ret, {
			hosts: ret.host.split(",").map(parse_host)
			host: undefined
		} else
			if (m = ret.host.match user_pass_re) then $.extend ret, {
				username: m[1]
				password: m[2]
				host: ret.host.replace user_pass_re, ''
			} else if (m = ret.host.match username_re) then $.extend ret, {
				username: m[1]
				host: ret.host.replace username_re, ''
			}
			if (m = ret.host.match host_port_re) then $.extend ret, {
				host: m[1]
				port: m[2]
			}
		return ret
	parse = (str, parseQuery=false) ->
		ret = if (m = str?.match url_re) then {
			protocol: m[1]
			host:     m[2]
			path:     m[3]
			query:    m[4]?.replace /^\?/,''
			hash:     m[5]?.replace /^#/, ''
		} else null
		if ret?
			if parseQuery
				query = ret.query ? ""
				ret.query = Object.create null
				for pair in query.split('&')
					if (i = pair.indexOf '=') > -1
						ret.query[pair.substring 0,i] = unescape pair.substring i+1
					else if pair.length > 0
						ret.query[pair] = null
				delete ret.query[""]
			$.extend ret, parse_host(ret.host)
			$.keysOf(ret).each (key) ->
				switch $.type ret[key]
					when "null","undefined" then delete ret[key]
					when "string" then if ret[key].length is 0 then delete ret[key]
				null
		ret
	clean = (val, re, prefix = '', suffix ='') ->
		x = val ? ""
		return if x and not re.test x then prefix+x+suffix else x
	stringify = (url) ->
		if $.is 'object', url.query
			url.query = ("#{k}=#{v}" for k,v of url.query).join("&")
		return [
			clean(url.protocol, /:$/, '', ':'),
			clean(url.host, /^\//, '//'),
			clean(url.port, /^:/, ':'),
			clean(url.path, /^\//, '/'),
			clean(url.query, /^\?/, '?'),
			clean(url.hash, /^#/, '#')
		].join ''
	return $: URL: { parse, stringify }
