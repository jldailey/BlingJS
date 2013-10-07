$.plugin
	provides: "render"
	depends: "promise"
, ->

	log = $.logger "[render]"

	consume_forever = (promise, opts, p = $.Promise()) ->
		unless $.is "promise", promise
			return $.Promise().finish(reduce promise, opts)
		promise.wait (err, result) ->
			r = reduce result, opts
			if $.is 'promise', r
				consume_forever r, opts, p
			else p.finish(r)
		p

	render = (o, opts = {}) ->
		consume_forever r = (reduce [ o ], opts), opts

	object_handlers = {
		text: (o, opts) -> reduce o[opts.lang ? "EN"], opts
	}
	# Objects are handled based on their "t" or "type" property.
	render.register = register = (t, f) -> object_handlers[t] = f


	render.reduce = reduce = (o, opts) -> # all objects become either arrays, promises, or strings
		switch t = $.type o
			when "string","html" then o
			when "null","undefined" then t
			when "promise"
				q = $.Promise()
				o.wait finish_q = (err, result) ->
					return q.fail(err) if err
					if $.is 'promise', r = reduce result, opts
						r.wait finish_q
					else
						q.finish r
				q
			when "number" then String(o)
			when "array", "bling"
				p = $.Progress m = 1 # always start with one step (creation)
				# more steps will be added later during the recursion
				q = $.Promise() # use a summary promise for public view
				p.wait (err, result) ->
					if err then q.fail(err) else q.finish(finalize n, opts)
				n = []
				has_promises = false
				for x, i in o then do (x,i) ->
					n[i] = y = reduce x, opts # recurse here
					if $.is 'promise', y
						has_promises = true
						p.progress null, ++m
						y.wait finish_p = (err, result) -> # recursive promise trampoline
							return p.fail(err) if err
							rp = reduce result, opts
							if $.is 'promise', rp
								rp.wait finish_p
							else
								p.finish n[i] = rp
				p.finish(1) # creation is complete
				if has_promises then q
				else finalize n
			when "function" then switch f.length
				when 0,1 then reduce f(opts)
				else $.Promise.wrap f, opts
			when "object"
				if (t = o.t ? o.type) of object_handlers
					object_handlers[t].call o, o, opts
				else "[ no handler for object type: '#{t}' #{JSON.stringify(o).substr 0,20}... ]"
			else "[ cant reduce type: #{t} ]"
	
	finalize = (o, opts) -> # what to do once all the promises have been waited for and replaced with their results
		return switch t = $.type o
			when "string","html" then o
			when "number" then String(o)
			when "array","bling" then (finalize(x) for x in o).join ''
			when "null","undefined" then t
			else "[ cant finalize type: #{t} ]"

	register 'link', (o, opts) -> [
		"<a"
			[" ",k,"='",@[k],"'"] for k in ["href","name","target"] when k of @
		">",reduce(@content,opts),"</a>"
	]

	register 'let', (o, opts) ->
		save = opts[o.name]
		opts[o.name] = o.value
		try return reduce o.content, opts
		finally
			if save is undefined then delete opts[o.name]
			else opts[o.name] = save
	
	register 'get', (o, opts) -> reduce opts[o.name], opts

	return $: { render }
