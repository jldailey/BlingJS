$.plugin
	provides: 'TNET'
	depends: "type, string, function"
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

	reverseLookup = {} # Reverse lookup table, for use during unpacking
	do -> for t,v of Types
		reverseLookup[v.symbol] = v

	unpackOne = (data) ->
		if data
			if (i = data.indexOf ":") > 0
				di = parseInt data[0...i], 10 # read a number
				if isFinite(di) and $.is 'number', di # rules out NaN, Infinity, etc
					if i < (x = i + 1 + di) < data.length
						if sym = reverseLookup[data[x]]
							return [
								sym.unpack(data[i+1...x]),
								data[x+1...]
							]
		return [ undefined, data ]

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
			parse: (x) -> Bling.TNET.parseOne(x)?[0]
			parseOne: (x) -> # returns [value, leftOver] so you can continue reading a sequence
				if Buffer.isBuffer x
					x = x.toString()
				unpackOne(x)
