
$.plugin
	depends: "core,function"
	provides: "promise"
, ->
	NoValue = -> # a totem
	Promise = (obj = {}) ->
		waiting = $()
		err = result = NoValue
		return $.inherit {
			wait: (cb) ->
				return cb(err,null) if err isnt NoValue
				return cb(null,result) if result isnt NoValue
				waiting.push cb
				@
			finish: (value) ->
				waiting.call null, result = value
				waiting.clear()
				@
			fail: (error)  ->
				waiting.call err = error, null
				waiting.clear()
				@
			reset: ->
				err = result = NoValue
				# does NOT clear waiting, b/c it should already be empty (or result would already be NoValue)
				@
		}, $.EventEmitter(obj)

	Progress = (max = 1.0) ->
		cur = 0.0
		progress = (args...) ->
		return $.inherit {
			progress: (args...) ->
				return cur unless args.length
				cur = args[0]
				if args.length > 1
					max = args[1]
				@finish(cur) if cur >= max
				@emit 'progress', cur, max
				@
			progressInc: (delta = 1) -> @progress cur + delta
			progressMax: (q) -> max = q
		}, Promise()

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

	ret = { $: { Promise, Progress } }
