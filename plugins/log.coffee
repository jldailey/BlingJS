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
	log.enableTimestamps = ->
		log.pre = -> $.date.format(+new Date(), "yyyy-mm-dd HH:MM:SS._MS", "ms")
	log.disableTimestamps = ->
		log.pre = null

	return $: {
		log: log
		logger: (prefix) -> (a...) -> a.unshift prefix; log a...
	}
