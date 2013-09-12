$.plugin
	provides: "render"
	depends: "promise"
, ->

	$.type.extend null, render: (o) ->
		$.log "zomg, cant render type: #{$.type o}"
		return ""

	# Strings and Promises survive unchanged
	$.type.extend 'string',  render: $.identity
	$.type.extend 'promise', render: $.identity

	# Numbers become Strings
	$.type.extend 'number', render: $.toString

	# Sets recurse over their contents
	$.type.extend 'array', render: (a, opts) -> ((reduce x, opts) for x in a)
	$.type.extend 'bling', render: (b, opts) -> $((reduce x, opts) for x in b)

	# Functions are either called immediately, or upgraded to Promises
	$.type.extend 'function', render: (f, opts) ->
		switch f.length
			when 0, 1 then reduce f opts
			when 2 then $.Promise.wrap f, opts

	# Objects are handled based on their "t" or "type" property.
	object_handlers = {
		text: (o, opts) -> o[opts.lang ? "EN"]
	}
	register = (t, f) -> object_handlers[t] = f
	$.type.extend 'object', render: (o, opts) ->
		t = o.t ? o.type
		unless t of object_handlers
			return "[no handler for object type: '#{t}' #{JSON.stringify(o).substr 0,20}...]"
		object_handlers[t].call o, o, opts

	# reduce is phase-one of everything,
	# the output is a mixture of: arrays, strings, promises
	# everything else is reduced to one of these three things
	reduce = (o, opts) ->
		t = $.type.lookup(o)
		unless 'render' of t
			throw new Error "cant pack type: #{$.type o}"
		$.type.lookup(o).render(o, opts)

	# given reduce's output, wait for all the promises
	# if they yield further promises, keep waiting for those also
	wait = (a) ->
		p = $.Progress 1 # we always have at least one step of progress (the creation)
		q = $.Promise()
		wait_helper a, p, 1
		p.finish 1 # progress creation is complete
		# wait_helper above should have started all the async tasks,
		# and incremented the progress's max value,
		# once they are all finished, finish q:
		p.wait (err, result) -> if err then q.fail(err) else q.finish(finalize a)
		q

	wait_helper = (a, p, m) ->
		# recursively walk all arrays, adding to the progress object
		start = m
		for x, i in a then do (x, i, a) ->
			finisher = (err, result) ->
				a[i] = if err then err else reduce result
				if $.is 'promise', a[i]
					p.progress null, ++m
					a[i].wait finisher
				p.finish(1)
			if $.is 'promise', x
				p.progress null, ++m
				x.wait finisher
			else if $.is 'array', x
				m = wait_helper x, p, m
		m
	
	finalize = (a) ->
		return switch t = $.type a
			when 'array', 'bling' then a.map(finalize).join ''
			when 'string','html' then a
			when "null", "undefined" then ''
			else "[bad final type: #{t}]"

	# [ '[', decisionGetter('agent-1','decision-1'), ']' ]
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
		try return reduce o.content, opts
		finally
			if save is undefined then delete opts[o.name]
			else opts[o.name] = save

	register 'get', (o, opts) -> opts[o.name]
	
	return $: render: $.extend ((o, opts = {}) -> wait reduce o, opts), {
		register: register
	}

