
$.plugin
	depends: "core"
	provides: "async"
, ->

	return {
		# Given a set of asynchronous functions, call them all in series.
		# Each item is not called until it's predecessor has completed.
		# The first function in the series begins immediately.
		# The results are collected in order and given to a final callback,
		# This assumes that each f in this only accepts a single callback argument,
		# if this is not true, use $(f...).partial(arg1,arg2).series(cb) to first partially apply the arguments you want.
		series: (fin = $.identity) ->
			ret = $()
			todo = @length
			unless todo > 0
				fin.apply ret
				return @
			done = 0
			finish_one = (index) ->
				# create a callback to finish an ordered element
				->
					# save the result in ordered position
					ret[index] = arguments # this typically captures [err, result]; but by convention only
					# if we are done with all the items, call the final callback
					if ++done >= todo then fin.apply ret
					else next(done)
					null
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
			finish_one = (index) -> -> # see the comments in .series, same approach used here for collating the output
				ret[index] = arguments
				if ++done >= todo
					fin.apply ret
				null
			for i in [0...todo] by 1
				@[i](finish_one(i))

	}
