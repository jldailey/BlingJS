(($) ->
	$.plugin () ->
		pruners = {}
		register = (type, f) -> (pruners[type] = f)
		lookup = (obj) -> pruners[obj.t or obj.type]
		stack = []

		Object.Type.extend null,        { compact: (o) -> Object.String(o) }
		Object.Type.extend "undefined", { compact: (o) -> "" }
		Object.Type.extend "null",      { compact: (o) -> "" }
		Object.Type.extend "string",    { compact: Function.Identity }
		Object.Type.extend "array",     { compact: (o) -> (Object.Compact(x) for x in o).join("") }
		Object.Type.extend "bling",     { compact: (o) -> o.map(Object.Compact).join("") }
		Object.Type.extend "object",    { compact: (o) -> Object.Compact(lookup(o)?.call o, o) }

		Object.Compact = (o) ->
			stack.push(o)
			Object.Type.lookup(o)?.compact(o)
			stack.pop()
		Object.Extend Object.Compact,
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

