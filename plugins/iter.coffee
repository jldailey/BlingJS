(($) ->
	
	$.plugin () ->

		Object.Extend Array.Iter,
			Reverse: (a) ->
				i = a.length - 1
				Object.Mixin 'Iterator',
					next: () -> a[i--]
					hasMore: () -> i >= 0
					reset: () -> i = a.length - 1; @
					skip: (n=1) -> i -= n; @
			Range: (start, stop, step) -> # supports Infinity as stop
				step ?= 1
				if not stop?
					stop = start
					start = 0
				i = start
				Object.Mixin 'Iterator',
					next: () -> (r=i;i+=step;r)
					hasMore: () -> i < stop
					reset: () -> i = start; @
					skip: (n=1) -> i += (n*step); @
			Random: (seed) -> # always infinite, doesnt use Math.random() so we control the seed
				max = 2147483647 # constants borrowed from tcl's rand()
				mult = 16807
				if not (0 < seed < max)
					seed = Math.floor(new Date().getTime())
				Object.Mixin 'Iterator',
					next: () -> (seed = (seed * mult) % max) / max
					hasMore: () -> true
			Shuffle: (a) ->
				b = (x for x in a) # copy the source array
				i = b.length-1 # read from the back
				Object.Mixin 'Iterator',
					# at each read, swap the last one with a random one
					next: () -> Array.Swap(b, i, Math.floor(Math.random() * i))[i--]
					hasMore: () -> i >= 0
					reset: () ->
						b = (x for x in a)
						i = b.length-1
					skip: (n=1) -> i -= n

		return {
			name: 'Iter'
		}

)(Bling)
