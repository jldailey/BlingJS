
$.plugin
	depends: "core"
	provides: "async,series,parallel"
, ->

	return {
		# Given a set of asynchronous functions, call them all in series.
		# Each item is not called until it's predecessor has completed.
		# The first function in the series begins in the next tick.
		# The results are collected in-order and given to a final callback,
		# This assumes that each f in this only accepts a single callback argument,
		# if this is not true, use $(f...).partial(arg1,arg2).series(cb) to first partially apply the arguments you want.
		series: (fin = $.identity) ->
			try return @
			finally
				ret = $()
				todo = @length
				unless todo > 0
					fin.apply ret, ret
				else
					done = 0
					finish_one = (index) -> -> # create a callback to finish an ordered element
						# 'index' puts the result in ordered position
						ret[index] = arguments # typically capture [err, result]; but by convention only
						if ++done >= todo then fin.apply ret, ret # if we are done, call the final callback
						else next done
						null
					do next = (i=0) => $.immediate => @[i] finish_one i

		# Given a set of async functions, call them all at once,
		# when they are all finished, fin (the final callback) is given the set of results
		parallel: (fin = $.identity) ->
			try return @
			finally
				ret = $()
				todo = @length
				unless todo > 0
					fin.apply ret, ret
				else
					done = 0
					finish_one = (index) -> -> # see the comments in .series: collate the output
						ret[index] = arguments
						if ++done >= todo
							fin.apply ret, ret
						null
					for i in [0...todo] by 1
						@[i] finish_one i

	}
