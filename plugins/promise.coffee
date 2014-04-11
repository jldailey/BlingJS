
$.plugin
	depends: "core,function"
	provides: "promise"
, ->
	NoValue = -> # a totem
	Promise = (obj = {}) ->
		waiting = $()
		err = result = NoValue
		end = (error, value) ->
			if err is result is NoValue
				err = error
				result = value
				caught = null
				while w = waiting.shift()
					w.timeout?.cancel()
					try switch
						when err isnt NoValue then w(err, null)
						when result isnt NoValue then w(null, result)
					catch e then caught ?= e
				if caught then throw caught
			null
		ret = $.inherit {
			wait: (timeout, cb) -> # .wait([timeout], callback) ->
				if $.is 'function', timeout
					[cb, timeout] = [timeout, undefined]
				if err isnt NoValue
					$.delay 0, -> cb err, null
				else if result isnt NoValue
					$.delay 0, ->
						try
							cb null, result
						catch _err then cb _err, null
				else
					waiting.push cb
					if isFinite parseFloat timeout
						cb.timeout = $.delay timeout, ->
							if (i = waiting.indexOf cb) > -1
								waiting.splice i, 1
								cb('timeout', null)
				@
			then: (f) -> @wait (err, x) -> unless err then f(x)
			finish: (value) -> end NoValue, value; @
			fail:   (error) -> end error, NoValue; @
			reset:          -> err = result = NoValue; @
		}, $.EventEmitter(obj)

		$.defineProperty ret, 'finished',
			get: -> result isnt NoValue
		$.defineProperty ret, 'failed',
			get: -> err isnt NoValue

		ret.promiseId = $.random.string 6

		return ret

	Promise.compose = Promise.parallel = (promises...) ->
		try p = $.Progress(promises.length + 1) # always an extra one for setup, so an empty list is finished immediately
		finally
			$(promises).select('wait').call (err, data) ->
				if err then p.fail(err) else p.finish 1
			p.finish 1

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
				@__proto__.__proto__.finish(item) if cur >= max
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
			try return (typeof o is 'object')	and
				'wait' of o and
				'finish' of o and
				'fail' of o

	return $: { Promise, Progress }
