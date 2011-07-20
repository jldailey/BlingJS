(($) ->
	$.plugin () -> # TnetStrings plugin
		parseOne = (data) ->
			i = data.indexOf ":"
			if i > 0
				len = parseInt data[0...i], 10
				item = data[i+1...i+1+len]
				type = data[i+1+len]
				extra = data[i+len+2...]
				item = switch type
					when "#" then Number(item)
					when "'" then String(item)
					when "!" then (item is "true")
					when "~" then null
					when "]" then parseArray(item)
					when "}" then parseObject(item)
				return [item, extra]
			return undefined
		parseArray = (x) ->
			data = []
			while x.length > 0
				[one, x] = parseOne(x)
				data.push(one)
			data
		parseObject = (x) ->
			data = {}
			while x.length > 0
				[key, x] = parseOne(x)
				[value, x] = parseOne(x)
				data[key] = value
			data
		return {
			name: 'TNET'
			$: {
				TNET: {
					stringify: (x) ->
						[data, type] = switch Object.Type(x)
							when "number" then [String(x), "#"]
							when "string" then [x, "'"]
							when "function" then [String(x), "'"]
							when "boolean" then [String(not not x), "!"]
							when "null" then ["", "~"]
							when "undefined" then ["", "~"]
							when "array" then [($.TNET.stringify(y) for y in x).join(''), "]"]
							when "object" then [($.TNET.stringify(y)+$.TNET.stringify(x[y]) for y of x).join(''), "}"]
						return (data.length|0) + ":" + data + type
					parse: (x) ->
						parseOne(x)?[0]
				}
			}
		}
)(Bling)
