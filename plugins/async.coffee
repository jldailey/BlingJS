
$.plugin
	depends: "core"
	provides: "async"
, ->

	return {
		# Given a set of asynchronous functions, call them all in series, collecting a new set of results
		# This assumes that each f in this only accepts a single callback argument,
		# if this is not true, use $(f...).partial(arg1,arg2).series(cb) to first partially apply the arguments you want.
		series: (fin = $.identity) ->
			ret = $()
			todo = @length
			unless todo > 0
				fin.apply ret
				return @
			done = 0
			finish_one = (index) -> ->
				ret[index] = arguments
				if ++done >= todo
					fin.apply ret
				else next(done)
			do next = (i=0) => $.immediate => @[i](finish_one(i))
			return @

		# Given a set of async functions, call them all at once,
		# when they are all finished, fin (the final callback) is given the set of results
		parallel: (fin = $.identity) ->
			ret = $()
			todo = @length
			unless todo > 0
				fin.apply ret
				return @
			done = 0
			finish_one = (index) -> ->
				ret[index] = arguments
				if ++done >= todo
					fin.apply ret
			for i in [0...todo] by 1
				@[i](finish_one(i))


	}
