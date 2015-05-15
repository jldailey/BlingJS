$.plugin
	provides: "render"
	depends: "promise, type"
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
	# Objects are handled based on their "t" or "type" property.
	render.register = register = (t, f) -> object_handlers[t] = f

	render.reduce = reduce = (o, opts) -> # all objects become either arrays, promises, or strings
		(t = $.type.lookup o).reduce(o, t, opts)
	$.type.extend
		unknown:   reduce: (o, t, opts) -> "[ cant reduce type: #{t} ]"
		string:    reduce: $.identity
		html:      reduce: $.identity
		null:      reduce: (o, t, opts) -> t
		undefined: reduce: (o, t, opts) -> t
		number:    reduce: (o, t, opts) -> String o
		function:  reduce: (o, t, opts) ->
			# upon review after an interval... this seems fishy.
			switch f.length
				when 0,1 then reduce f(opts)
				else $.Promise.wrap f, opts
		object: reduce: (o, t, opts) ->
			# if there's a "t" or "type" property, try to use a registered handler
			if (t = o.t ? o.type) of object_handlers
				object_handlers[t].call o, o, opts
			else "[ no handler for object type: '#{t}' #{JSON.stringify(o).substr 0,20}... ]"
		promise: reduce: (o, t, opts) ->
			# recursively wait on all promises,
			# only finished when a non-promise value is produced.
			q = $.Promise()
			o.wait finish_q = (err, result) ->
				return q.reject(err) if err
				if $.is 'promise', r = reduce result, opts
					r.wait finish_q
				else
					q.resolve r
			q
		array: reduce: array_reduce = (o, t, opts) ->
			p = $.Progress m = 1 # always start with one bit of work to do (creation)
			# more steps will be added later during the recursion
			q = $.Promise() # use a summary promise for public view
			n = []
			p.wait (err) ->
				if err then q.reject(err) else q.resolve(finalize n, opts)
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
		bling: reduce: array_reduce

	# what to do once all the promises have been waited for and replaced with their results
	finalize = (o, opts) ->
		(t = $.type.lookup o).finalize(o, t, opts)
	$.type.extend
		unknown:   finalize: (o, t, opts) -> "[ cant finalize type: #{t} ]"
		string:    finalize: $.identity
		html:      finalize: $.identity
		number:    finalize: (o, t, opts) -> String o
		array:     finalize: array_finalize = (o, t, opts) -> (finalize(x, opts) for x in o).join ''
		bling:     finalize: array_finalize
		null:      finalize: -> "null"
		undefined: finalize: -> "undefined"
	
	aka = (name) -> object_handlers[name]

	register 'link', (o, opts) -> [
		"<a"
			[" #{k}='",o[k],"'"] for k in ["href","name","target"] when k of o
		">",reduce(o.content,opts),"</a>"
	]
	register 'a', aka 'link'

	register 'let', (o, opts) ->
		save = opts[o.name]
		opts[o.name] = o.value
		ret = reduce o.content, opts
		if save is undefined then delete opts[o.name]
		else opts[o.name] = save
		return ret
	register 'set', aka 'let'

	register 'get', (o, opts) -> reduce opts[o.name], opts

	return $: { render }
