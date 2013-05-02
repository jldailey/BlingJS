$.plugin
	provides: "sortBy,sortedIndex"
, ->
	$:
		sortedIndex: (array, item, iterator) ->
			cmp = switch $.type iterator
				when "string" then (a,b) -> a[iterator] < b[iterator]
				when "function" then (a,b) -> iterator(a) < iterator(b)
				else (a,b) -> a < b
			hi = array.length
			lo = 0
			while lo < hi
				mid = (hi + lo)>>>1
				if cmp(array[mid], item)
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

		
