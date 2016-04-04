$.plugin {
	provides: "log, logger"
	depends: "bound"
}, ->
	log = (a...) ->
		if a.length
			if p = log.pre?()
				a.unshift p
			log.out a...
			return a[a.length-1]
	log.out = console.log.bind console
	log.pre = null
	log.enableTimestamps = (level=2) ->
		log.pre = ([
			null
			-> String(+new Date())
			-> $.date.format(+new Date(), "yyyy-mm-dd HH:MM:SS._MS", "ms")
		])[level]
	log.disableTimestamps = -> log.enableTimestamps(0)

	return $: {
		log: log
		logger: (prefix) -> (a...) -> a.unshift prefix; log a...
	}
