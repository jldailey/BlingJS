
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
					result = value
					for w in waiting
						w(null, value)
						w.timeout?.cancel()
					waiting.clear()
				@
			fail: (error)  ->
				if err is result is NoValue
					err = error
					for w in waiting
						w(error, null)
						w.timeout?.cancel()
					waiting.clear()
				@
			reset: ->
				err = result = NoValue
				@
		}, $.EventEmitter(obj)

		$.defineProperty ret, 'finished',
			get: -> result isnt NoValue
		$.defineProperty ret, 'failed',
			get: -> err isnt NoValue

		return ret

	Promise.compose = (promises...) ->
		p = $.Progress(promises.length)
		$(promises).select('wait').call (err, data) ->
			return p.fail err if err
			p.finish 1 unless p.failed
		return p

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
				max = args[1] if args.length > 1
				@__proto__.__proto__.finish(max) if cur >= max
				@emit 'progress', cur, max
				@
			finish: (delta = 1) ->
				@progress cur + delta
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

	ret = $: { Promise, Progress }
