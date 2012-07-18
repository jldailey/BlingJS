
$.plugin -> # Background workers... just noodling for now

	# EOF is a sentinel (instead of an object/guid so it has safer comparisons)
	EOF = -> "EOF"

	BackgroundQueue = (opts) ->
		opts = extend {
			item: -> EOF
			action: Function.Identity
			latency: 10
		}, opts

		return extend new $.EventEmitter(), {
			run: ->
				r = () =>
					if (item = opts.action(opts.item())) isnt EOF
						@emit("data", item)
						setTimeout r, opts.latency
				setTimeout r, opts.latency
		}

	data = x for x in [0...1000]
	i = 0
	BackgroundQueue
		item: ->
			return data[i++] if i < data.length else EOF
		action: (item) -> (item*item) - 1
		latency: 10
	.on "data", (x) -> console.log "data:", x
	.on "error", (x) -> console.log "error:", x
	.run() # this should output 1 to 1000 over about 10 seconds, while other events keep working
	
