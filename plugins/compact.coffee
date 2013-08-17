
$.plugin
	provides: "compact"
	depends: "function"
, ->
	compact = (o, opts) ->
		types = $.type.with('compact')
		for t in types when t.match.call o, o
			return t.compact o, opts
		""

	$.type.extend null,       compact: default_compact = $.toString
	$.type.extend "undefined",compact: null_compact = (o) -> ""
	$.type.extend "null",     compact: null_compact
	$.type.extend "string",   compact: $.identity
	$.type.extend "array",    compact: array_compact = (o, opts) -> (compact(x, opts) for x in o).join('')
	$.type.extend "bling",    compact: array_compact
	$.type.extend "function", compact: func_compact = (f, opts) -> f opts

	handlers = {}
	register = (type, f) -> (handlers[type] = f)
	$.type.extend "object",   compact: object_compact = (o, opts) ->
		compact handlers[o.t or o.type]?.call(o, o, opts), opts

	register 'html', -> [
		"<!DOCTYPE html><html><head>"
			@head
		"</head><body>"
			@body
		"</body></html>"
	]
	register 'text', (o, opts) ->
		o[opts.lang ? "EN"]

	register 'link', -> [
		"<a"
			[" ",k,"='",@[k],"'"] for k in ["href","name","target"] when k of @
		">",@content,"</a>"
	]

	register 'let', (o, opts) ->
		save = opts[o.name]
		opts[o.name] = o.value
		try return compact o.content, opts
		finally
			if save?
				opts[o.name] = save
			else delete opts[o.name]

	register 'get', (o, opts) -> opts[o.name]
	
	return $: compact: $.extend ((o, opts = {}) -> compact o, opts), {
		register: register
	}

