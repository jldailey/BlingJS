
$.plugin
	depends: "core,function"
	provides: "promise"
, ->
	NoValue = -> # a totem
	Promise = (obj = {}) ->
		waiting = $()
		err = result = NoValue
		consume_all = (e, v) ->
			while w = waiting.shift()
				w.timeout?.cancel()
				try w e, v
				catch _e then w _e, null
		end = (error, value) =>
			if err is result is NoValue

				# fatal error: passing a promise to it's own resolver
				if value is @
					throw new TypeError("cant resolve a promise with itself")

				# you can resolve one promise with another:
				if $.is 'promise', value
					value.wait (e, v) -> end e, v
					return @

				# every waiting callback gets consumed and called
				if error isnt NoValue
					consume_all error, null
				else if value isnt NoValue
					consume_all null, value

				# save the results
				err = error
				result = value

			return @

		ret = $.inherit {
			wait: (timeout, cb) -> # .wait([timeout], callback) ->
				if $.is 'function', timeout
					[cb, timeout] = [timeout, undefined]
				if err isnt NoValue
					$.delay 0, ->
						try cb err, null
						catch _err
							try cb _err, null
							catch __err
								$.log "Fatal error in Promise callback:", _err.stack ? String(_err)
				else if result isnt NoValue
					$.delay 0, ->
						try cb null, result
						catch _err
							try cb _err, null
							catch __err
								$.log "Fatal error in Promise callback:", _err.stack ? String(_err)
				else # this promise hasn't been resolved OR rejected yet
					waiting.push cb
					if isFinite parseFloat timeout
						cb.timeout = $.delay timeout, ->
							if (i = waiting.indexOf cb) > -1
								waiting.splice i, 1
								cb 'timeout', null
				@
			then: (f, e) -> @wait (err, x) ->
				if err then e?(err)
				else f(x)
			finish:  (value) -> end NoValue, value; @
			resolve: (value) -> end NoValue, value; @
			fail:    (error) -> end error, NoValue; @
			reject:  (error) -> end error, NoValue; @
			reset:           -> err = result = NoValue; @
		}, $.EventEmitter(obj)

		$.defineProperty ret, 'finished',
			get: -> result isnt NoValue
		$.defineProperty ret, 'failed',
			get: -> err isnt NoValue

		ret.promiseId = $.random.string 6

		return ret

	Promise.compose = Promise.parallel = (promises...) ->
		# always an extra one for setup, so an empty list is finished immediately
		try p = $.Progress(promises.length + 1)
		finally
			$(promises).select('wait').call (err, data) ->
				if err then p.fail(err) else p.finish 1
			p.finish 1

	Promise.collect = (promises) ->
		ret = []
		unless promises? then return $.Promise().finish(ret)
		p = $.Promise()
		q = $.Progress(1 + promises.length)
		for promise, i in promises then do (i) ->
			promise.wait (err, result) ->
				ret[i] = err ? result
				q.finish(1)
		q.then -> p.finish(ret)
		q.finish(1)
		p

	Promise.wrapCall = (f, args...) ->
		try p = $.Promise()
		finally # the last argument to f will be a callback that finishes the promise
			args.push (err, result) -> if err then p.fail(err) else p.finish(result)
			$.immediate -> f args...

	Progress = (max = 1.0) ->
		cur = 0.0
		return $.inherit {
			# .progress() - returns current progress
			# .progress(cur) - sets progress
			# .progress(cur, max) - set progress and goal
			# .progress(null, max) - set goal
			progress: (args...) ->
				return cur unless args.length
				cur = args[0] ? cur
				max = (args[1] ? max) if args.length > 1
				item = if args.length > 2 then args[2] else max
				if cur >= max
					@__proto__.__proto__.finish(item)
				@emit 'progress', cur, max, item
				@
			finish: (delta) ->
				item = delta
				unless isFinite(delta)
					delta = 1
				@progress cur + delta, max, item
			include: (promise) ->
				@progress cur, max + 1
				promise.wait (err) =>
					return @fail(err) if err
					@finish(1)
		}, p = Promise()

	# Helper for wrapping an XHR object in a Promise
	Promise.xhr = (xhr) ->
		try p = $.Promise()
		finally xhr.onreadystatechange = ->
			if @readyState is @DONE
				if @status is 200
					p.finish xhr.responseText
				else
					p.fail "#{@status} #{@statusText}"

	$.depend 'dom', ->
		Promise.image = (src) ->
			try p = $.Promise()
			finally $.extend image = new Image(),
				onerror: (e) -> p.fail e
				onload: -> p.finish image
				src: src

	$.depend 'type', ->
		$.type.register 'promise', is: (o) ->
			try return (typeof o is 'object')	and 'then' of o
			catch err then return false

	return $: { Promise, Progress }
