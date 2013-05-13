$.plugin
	depends: 'type'
	provides: 'TNET'
, -> # TnetStrings plugin
	Types =
		"number":
			symbol: "#"
			pack: (n) -> String(n)
			unpack: (s) -> Number(s)
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
			pack: (b) -> ""
			unpack: (s) -> null
		"undefined":
			symbol: "_"
			pack: (b) -> ""
			unpack: (s) -> undefined
		"array":
			symbol: "]"
			pack: (a) -> (packOne(y) for y in a).join('')
			unpack: (s) ->
				data = []
				while s.length > 0
					[one, s] = unpackOne(s)
					data.push(one)
				data
		"object":
			symbol: "}"
			pack: (o) ->
					(packOne(k)+packOne(v) for k,v of o).join('')
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
				[args, body] = f.toString()
					.replace(/function \w*/,'')
					.replace(/\/\*.*\*\//,'')
					.replace(/\n/,'')
					.replace(/^\(/,'')
					.replace(/}$/,'')
					.split(/\) {/)
				args = args.split /, */
				body = body.replace(/^\s+/,'').replace(/\s*$/,'')
				return [ args, body ].map(packOne).join ''
			unpack: (s) ->
				[args, rest] = unpackOne(s)
				[body, rest] = unpackOne(rest)
				args.push body
				return Function.apply null, args
		"regexp":
			symbol: "/"
			pack: (r) -> String(r).slice(1,-1)
			unpack: (s) -> RegExp(s)

	Symbols = {}
	do -> for t,v of Types
		Symbols[v.symbol] = v

	unpackOne = (data) ->
		i = data.indexOf ":"
		if i > 0
			len = parseInt data[0...i], 10
			item = data[i+1...i+1+len]
			symbol = data[i+1+len]
			extra = data[i+len+2...]
			if( type = Symbols[symbol] )?
				item = type.unpack item
				return [item, extra]
		return undefined

	packOne = (x) ->
		t = Types[$.type x]
		unless t?
			throw new Error("TNET: cant pack type '#{$.type x}'")
		data = t.pack(x)
		return (data.length|0) + ":" + data + t.symbol

	$:
		TNET:
			Types: Types
			stringify: packOne
			parse: (x) -> unpackOne(x)?[0]
