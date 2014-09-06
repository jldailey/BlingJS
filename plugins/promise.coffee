
$.plugin
	depends: "core,function"
	provides: "promise"
, ->
	class NoValue # a named totem
	Promise = (obj = {}) ->
		waiting = new Array()
		err = result = NoValue
		consume_all = (e, v) ->
			while w = waiting.shift()
				consume_one w, e, v
			null
		consume_one = (cb, e, v) ->
			cb.timeout?.cancel()
			try cb e, v
			catch _e
				try cb _e, null
				catch __e
					$.log "Fatal error in promise callback:", __e?.stack, "caused by:", _e?.stack
			null

		end = (error, value) =>
			if err is result is NoValue
				if error isnt NoValue
					err = error
				else if value isnt NoValue
					result = value
				switch
					# fatal error: passing a promise to it's own resolver
					when value is @ then return end new TypeError "cant resolve a promise with itself"
					# but, you can resolve one promise with another:
					when $.is 'promise', value then (value.wait end; return @)
					# every waiting callback gets consumed and called
					when error isnt NoValue then consume_all error, null
					when value isnt NoValue then consume_all null, value

			return @

		ret = $.inherit {
			promiseId: $.random.string 6
			wait: (timeout, cb) -> # .wait([timeout], callback) ->
				if $.is 'function', timeout
					[cb, timeout] = [timeout, Infinity]
				if err isnt NoValue
					$.immediate -> consume_one cb, err, null
				else if result isnt NoValue
					$.immediate -> consume_one cb, null, result
				else # this promise hasn't been resolved OR rejected yet
					waiting.push cb # so save this callback for later
					if isFinite parseFloat timeout
						cb.timeout = $.delay timeout, ->
							if (i = waiting.indexOf cb) > -1
								waiting.splice i, 1
								consume_one cb, err = 'timeout', undefined
				@
			then: (f, e) -> @wait (err, x) ->
				if err
					if e? then e(err)
					else throw err
				else f(x)
			finish:  (value) -> end NoValue, value; @
			resolve: (value) -> end NoValue, value; @
			fail:    (error) -> end error, NoValue; @
			reject:  (error) -> end error, NoValue; @
			reset:           -> err = result = NoValue; @ # blasphemy!
			handler: (err, data) ->
				# use 'ret' here instead of '@' to prevent binding issues later
				if err then ret.reject(err) else ret.resolve(data)
			inspect: -> "{Promise[#{@promiseId}] #{getState()}}"
		}, $.EventEmitter(obj)

		getState = -> switch
			when result isnt NoValue then "resolved"
			when err isnt NoValue then "rejected"
			else "pending"

		isFinished = -> result isnt NoValue
		$.defineProperty ret, 'finished', get: isFinished
		$.defineProperty ret, 'resolved', get: isFinished

		isFailed = -> err isnt NoValue
		$.defineProperty ret, 'failed',   get: isFailed
		$.defineProperty ret, 'rejected', get: isFailed

		return ret

	Promise.compose = Promise.parallel = (promises...) ->
		# always an extra one for setup, so an empty list is finished immediately
		p = $.Progress(1 + promises.length)
		$(promises).select('wait').call (err, data) ->
			if err then p.reject(err) else p.resolve 1
		p.resolve 1

	Promise.collect = (promises) ->
		ret = []
		p = $.Promise()
		unless promises? then return p.resolve(ret)
		q = $.Progress(1 + promises.length)
		for promise, i in promises then do (i) ->
			promise.wait (err, result) ->
				ret[i] = err ? result
				q.resolve(1)
		q.then -> p.resolve(ret)
		q.resolve(1)
		p

	Promise.wrapCall = (f, args...) ->
		try p = $.Promise()
		finally # the last argument to f will be a callback that finishes the promise
			args.push (err, result) -> if err then p.reject(err) else p.resolve(result)
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
				item = if args.length > 2 then args[2] else cur
				if cur >= max
					@__proto__.__proto__.resolve(item)
				@emit 'progress', cur, max, item
				@
			resolve: (delta, item = delta) ->
				unless isFinite(delta)
					delta = 1
				@progress cur + delta, max, item
			finish: (delta, item) -> @resolve delta, item

			include: (promise) ->
				@progress cur, max + 1
				promise.wait (err) =>
					if err then @reject err
					else @resolve 1

			inspect: -> "{Progress[#{@promiseId}] #{cur}/#{max}}"
		}, Promise()

	# Helper for wrapping an XHR object in a Promise
	Promise.xhr = (xhr) ->
		try p = $.Promise()
		finally xhr.onreadystatechange = ->
			if @readyState is @DONE
				if @status is 200
					p.resolve xhr.responseText
				else
					p.resolve "#{@status} #{@statusText}"

	$.depend 'dom', ->
		Promise.image = (src) ->
			try p = $.Promise()
			finally $.extend image = new Image(),
				onerror: (e) -> p.resolve e
				onload: -> p.resolve image
				src: src

	$.depend 'type', ->
		$.type.register 'promise', is: (o) ->
			try return (typeof o is 'object')	and 'then' of o
			catch err then return false

	return $: { Promise, Progress }
