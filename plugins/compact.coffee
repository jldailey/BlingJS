(($) ->
	$.plugin () ->
		pruners = {}
		register = (type, obj) -> (pruners[type] = obj)
		lookup = (obj) -> pruners[obj.TYPE]

		Object.Type.extend "unknown", { compact: (o) -> Object.String(o) }
		Object.Type.extend "string", { compact: (o) -> o }
		Object.Type.extend "number", { compact: (o) -> Object.String(o) }
		Object.Type.extend "array", { compact: (o) -> (Object.Compact(x) for x in o).join("") }
		Object.Type.extend "bling", { compact: (o) -> o.map(Object.Compact).join("") }
		Object.Type.extend "undefined", { compact: (o) -> "" }
		Object.Type.extend "null", { compact: (o) -> "" }
		Object.Type.extend "object", { compact: (o) -> Object.Compact(lookup(o)?.prune.call o, o) }

		Object.Compact = (o) -> Object.Type.lookup(o)?.compact(o)
		Object.Extend Object.Compact,
			register: register
			lookup: lookup

		register 'page', prune: (node) -> [
			"<!DOCTYPE html><html><head>",
					node.HEAD,
				"</head><body>",
					node.BODY,
				"</body></html>"
		]
		register 'text', prune: (node) -> node.EN
		register 'link', prune: (node) ->
			a = ["<a"]
			for k in ["href","name","target"]
				if k of node
					Array.Extend(a, [" ",k,"='",node[k],"'"])
			Array.Extend(a, [">",node.CONTENT,"</a>"])
			return a

		Object.Compact({ TYPE: "page", HEAD: [], BODY: {TYPE: "text", EN: "Hello World"} }) is
			"<!DOCTYPE html><html><head></head><body>Hello World</body></html>"

		return { name: "Compact" }
)(Bling)

