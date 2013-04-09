
$.plugin
	depends: "core,function"
	provides: "promise"
, ->
	promise = (obj = Object.create null) ->
		waiting = $()
		err = result = null
		return $.inherit {
			wait: (cb) ->
				return cb(err,null) if err?
				return cb(null,result) if result?
				waiting.push cb
				@
			finish: (result) ->
				waiting.call(null, result).clear()
				@
			fail: (error) ->
				waiting.call(error, null).clear()
				@
		}, obj

	# Common Wrappers
	# ---------------
	#
	# Wrap IndexedDB objects in a Promise.
	promise.iDB = (obj) ->
		p = $.Promise()
		$.extend obj,
			onerror:   -> p.fail @result
			onfailure: -> p.fail @result
			onblocked: -> p.fail "blocked"
			onsuccess: -> p.finish @result
		p
	
	promise.xhr = (xhr) ->
		p = $.Promise()
		xhr.onreadystatechange = ->
			if @readyState is @DONE
				if @status is 200
					p.finish xhr
				else
					p.fail "#{@status} #{@statusText}"

	return $: Promise: promise
