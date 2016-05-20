$.plugin
	provides: "sortBy,sortedIndex,sortedInsert"
, ->
	$:
		sortedIndex: (array, item, iterator, lo = 0, hi = array.length) ->
			cmp = switch true
				when $.is "string", iterator then (a,b) -> a[iterator] < b[iterator]
				when $.is "function", iterator then (a,b) -> iterator(a) < iterator(b)
				else (a,b) -> a < b
			while lo < hi
				mid = (hi + lo)>>>1
				if cmp array[mid], item
					lo = mid + 1
				else
					hi = mid
			return lo
	sortBy: (iterator) ->
		a = $()
		for item in @
			n = $.sortedIndex a, item, iterator
			a.splice n, 0, item
		a
	sortedInsert: (item, iterator) ->
		@splice ($.sortedIndex @, item, iterator), 0, item
		@
	groupBy: (key) ->
		groups = {}
		switch $.type key
			when 'array','bling'
				for x in @
					c = (x[k] for k in key).join ","
					(groups[c] or= $()).push x
			else for x in @ then (groups[x[key]] or= $()).push x
		return $.valuesOf groups

