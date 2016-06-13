$.plugin
	provides: "sortBy,sortedIndex,sortedInsert"
, ->
	$:
		sortedIndex: (array, item, sorter, lo = 0, hi = array.length) ->
			cmp = switch true
				when $.is "string", sorter then (a,b) -> a[sorter] < b[sorter]
				when $.is "function", sorter then (a,b) -> sorter(a) < sorter(b)
				else (a,b) -> a < b
			while lo < hi
				mid = (hi + lo)>>>1
				if cmp array[mid], item
					lo = mid + 1
				else
					hi = mid
			return lo
	sortBy: (sorter) ->
		a = $()
		for item in @
			n = $.sortedIndex a, item, sorter
			a.splice n, 0, item
		a
	sortedInsert: (item, sorter) ->
		@splice ($.sortedIndex @, item, sorter), 0, item
		@
	groupBy: (sorter) ->
		groups = {}
		switch $.type sorter
			when 'array','bling'
				for x in @
					c = (x[k] for k in key).join ","
					(groups[c] or= $()).push x
			when 'string' for x in @ then (groups[x[key]] or= $()).push x
		return $.valuesOf groups

