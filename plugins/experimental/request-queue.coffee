$.plugin
	depends: "function"
	provides: "request-queue"
, ->
	$: # A Queue of HTTP Requests
		RequestQueue: class RequestQueue
			constructor: (requester) ->
				@requester = requester ? try require 'request'
				@interval = null
				@queue = []
			tick: ->
				for i in [0...n = Math.min @queue.length, @perTick] by 1
					@requester @queue.shift()...
			start: (@perTick=1, interval=100) ->
				@stop() if @interval?
				@interval = setInterval (=> do @tick), interval
				@
			stop: stop = ->
				clearInterval @interval
				@interval = null
				@
			close: stop
			request: (args...) ->
				@queue.push args
				@
			post: (opts, callback = $.identity) ->
				@queue.push [($.extend opts, method: "POST"), callback]
				@
			get: (opts, callback = $.identity) ->
				@queue.push [($.extend opts, method: "GET"), callback]
				@
