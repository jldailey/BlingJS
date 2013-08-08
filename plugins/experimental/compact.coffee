$ = require 'bling'

$.plugin
	provides: "compact"
	depends: "function"
, ->
	stack = []
	compact = (o, opts) ->
		stack.push(o)
		try return $.type.lookup(o)?.compact(o, opts)
		finally stack.pop()
		return ""

	$.type.extend null,       compact: $.toString
	$.type.extend "undefined",compact: empty = (o) -> ""
	$.type.extend "null",     compact: empty
	$.type.extend "string",   compact: $.identity
	$.type.extend "array",    compact: array_compact = (o, opts) -> (compact(x, opts) for x in o).join ''
	$.type.extend "bling",    compact: array_compact
	$.type.extend "function", compact: (f, opts) -> compact (f opts), opts

	handlers = {}
	register = (type, f) -> (handlers[type] = f)
	$.type.extend "object",   compact: (o, opts) ->
		try return compact handlers[o.t or o.type]?.call(o, o, opts), opts
		catch err then return $.log "err:", err

	$.extend compact,
		register: register

	register 'html', -> [
		"<!DOCTYPE html><html><head>"
			@head
		"</head><body>"
			@body
		"</body></html>"
	]
	register 'text', (o, opts) ->
		o[opts.lang ? "EN"]
	register 'link', ->
		a = $ ["<a"]
		a.extend([" ",k,"='",@[k],"'"]) for k in ["href","name","target"] when k of @
		a.extend [">",@content,"</a>"]
	
	return $: compact: (o, opts = {}) -> compact o, opts

$.depends "compact", ->
	$.log $.compact { t: "html", body: [
		{ t: "text", EN: "Hello", FR: "Bonjour" }
		"&nbsp;"
		{ t: "link", href: "#home", content: [
			{ t: "text", EN: "World", FR: "l'Monde" }
		] }
	] },
	{ lang: "FR" }
	
