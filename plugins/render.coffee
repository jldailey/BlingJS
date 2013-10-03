$.plugin
	provides: "render"
	depends: "promise"
, ->

	log = $.logger "[render]"

	consume_forever = (promise, opts, p = $.Promise()) ->
		return $.Promise().finish(reduce promise, opts) unless $.is "promise", promise
		promise.wait (err, result) ->
			r = reduce result, opts
			if $.is 'promise', r
				consume_forever r, opts, p
			else p.finish(r)
		p

	render = (o, opts = {}) ->
		consume_forever (reduce [ o ], opts), opts

	object_handlers = {
		text: (o, opts) -> reduce o[opts.lang ? "EN"], opts
	}
	# Objects are handled based on their "t" or "type" property.
	render.register = register = (t, f) -> object_handlers[t] = f

	reduce = (o, opts) -> # all objects become either arrays, promises, or strings
		switch t = $.type o
			when "string" then o
			when "promise"
				q = $.Promise()
				o.wait finish_q = (err, result) ->
					return q.fail(err) if err
					if $.is 'promise', r = reduce result, opts
						r.wait finish_q
					else
						q.finish r
				q
			when "number" then $.toRepr(o)
			when "array", "bling"
				p = $.Progress m = 1
				q = $.Promise()
				p.wait (err, result) ->
					if err then q.fail(err) else q.finish(result)
				n = []
				has_promises = false
				for x, i in o then do (x,i) ->
					n[i] = y = reduce x, opts
					log "n[#{i}] = ", y
					if $.is 'promise', y
						has_promises = true
						p.progress null, ++m
						# trampoline promises here
						finish_p = (err, result) ->
							return p.fail(err) if err
							rp = reduce result, opts
							if $.is 'promise', rp
								rp.wait finish_p
							else
								p.finish n[i] = rp
						y.wait finish_p
				p.finish(1) # setup is complete
				if has_promises then q
				else n
			when "function" then switch f.length
				when 0,1 then reduce f(opts)
				else $.Promise.wrap f, opts
			when "object"
				if (t = o.t ? o.type) of object_handlers
					object_handlers[t].call o, o, opts
				else "[ no handler for object type: '#{t}' #{JSON.stringify(o).substr 0,20}... ]"
			else "[ cant reduce type: #{t} ]"
	
	return $: { render }
