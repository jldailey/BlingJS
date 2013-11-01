
$.plugin
	depends: "core,function"
	provides: "promise"
, ->
	NoValue = -> # a totem
	Promise = (obj = {}) ->
		waiting = $()
		err = result = NoValue
		ret = $.inherit {
			wait: (timeout, cb) ->
				# .wait([timeout], callback) ->
				if $.is 'function', timeout
					cb = timeout
				return $.immediate(-> cb err, null) if err isnt NoValue
				return $.immediate(-> cb null,result) if result isnt NoValue
				waiting.push cb
				if isFinite timeout
					cb.timeout = $.delay timeout, ->
						if (i = waiting.indexOf cb) > -1
							waiting.splice i, 1
							cb('timeout', null)
				@
			finish: (value) ->
				if err is result is NoValue
					caught = null
					while waiting.length
						w = waiting.shift()
						w.timeout?.cancel()
						try w(null, value)
						catch err
							caught ?= err
					# dont save the result until all waiters finished
					result = value
					# now throw any deferred error
					if caught
						throw caught
				@
			fail: (error)  ->
				if err is result is NoValue
					err = error
					caught = null
					while waiting.length
						w = waiting.shift()
						w.timeout?.cancel()
						try w(error, null)
						catch e then caught ?= e
					if caught then throw caught
				@
			reset: ->
				err = result = NoValue
				@
		}, $.EventEmitter(obj)

		$.defineProperty ret, 'finished',
			get: -> result isnt NoValue
		$.defineProperty ret, 'failed',
			get: -> err isnt NoValue

		ret.promiseId = $.random.string 6

		return ret

	Promise.compose = (promises...) ->
		p = $.Progress(promises.length)
		$(promises).select('wait').call (err, data) ->
			return p.fail err if err
			p.finish 1 unless p.failed
		return p
	
	Promise.wrap = (f, args...) ->
		p = $.Promise()
		# the last argument to f will be a callback that finishes the promise
		args.push (err, result) ->
			if err then p.fail(err) else p.finish(result)
		$.immediate -> f args...
		p

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
		p = $.Promise()
		xhr.onreadystatechange = ->
			if @readyState is @DONE
				if @status is 200
					p.finish xhr.responseText
				else
					p.fail "#{@status} #{@statusText}"
		return p

	$.depend 'dom', ->
		Promise.image = (src) ->
			p = $.Promise()
			image = new Image()
			image.onload = -> p.finish(image)
			image.onerror = (evt) -> p.fail(evt)
			image.src = src
			return p
	
	$.depend 'type', ->
		$.type.register 'promise', is: (o) ->
			try return (typeof o is 'object')	and
				'wait' of o and
				'finish' of o and
				'fail' of o

	ret = $: { Promise, Progress }
