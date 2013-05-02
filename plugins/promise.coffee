
$.plugin
	depends: "core,function"
	provides: "promise"
, ->
	Promise = (obj = Object.create null) ->
		waiting = $()
		err = result = null
		return $.inherit {
			wait: (cb) ->
				return cb(err,null) if err?
				return cb(null,result) if result?
				waiting.push cb
				@
			finish: (result) -> waiting.call(null, result).clear(); @
			fail:   (error)  -> waiting.call(error,  null).clear(); @
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

	$.depend 'dom', ->
		Promise.image = (src) ->
			p = $.Promise()
			image = new Image()
			image.onload = -> p.finish(image)
			image.onerror = (evt) -> p.fail(evt)
			image.src = src

	ret = { $: { Promise, Progress } }
