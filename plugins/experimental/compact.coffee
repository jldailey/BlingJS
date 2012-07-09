(($) ->
	$.plugin
		depends: "experimental"
	, ->
		pruners = {}
		register = (type, f) -> (pruners[type] = f)
		lookup = (obj) -> pruners[obj.t or obj.type]
		stack = []

		$.type.extend null,        { compact: (o) -> $.toString(o) }
		$.type.extend "undefined", { compact: (o) -> "" }
		$.type.extend "null",      { compact: (o) -> "" }
		$.type.extend "string",    { compact: $.identity }
		$.type.extend "array",     { compact: (o) -> (Object.Compact(x) for x in o).join("") }
		$.type.extend "bling",     { compact: (o) -> o.map(Object.Compact).join("") }
		$.type.extend "object",    { compact: (o) -> Object.Compact(lookup(o)?.call o, o) }

		Object.Compact = (o) ->
			stack.push(o)
			$.type.lookup(o)?.compact(o)
			stack.pop()
		$.extend Object.Compact,
			register: register
			lookup: lookup

		register 'page', -> [
			"<!DOCTYPE html><html><head>",
				@head,
			"</head><body>",
				@body,
			"</body></html>"
		]
		register 'text', -> @EN
		register 'link', ->
			a = $(["<a"])
			a.extend(" ",k,"='",@[k],"'") for k in ["href","name","target"] when k of @
			a.extend(">",node.content,"</a>")

		$.assert(Object.Compact({ t: "page", head: [], body: {type: "text", EN: "Hello World"} }) is
			"<!DOCTYPE html><html><head></head><body>Hello World</body></html>")

		return { name: "Compact" }
)(Bling)

