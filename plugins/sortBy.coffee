$.plugin
	provides: "sortBy,sortedIndex"
, ->
	$:
		sortedIndex: (array, item, iterator) ->
			cmp = switch $.type iterator
				when "string" then (a,b) -> a[iterator] - b[iterator]
				when "function" then (a,b) -> iterator(a) - iterator(b)
				else (a,b) -> a - b
			for i in [0...array.length] by 1 # should use a binary search for large N
				if cmp(array[i], item) > 0
					return i
			return array.length
	sortBy: (iterator) ->
		a = $()
		for item in @
			n = $.sortedIndex a, item, iterator
			a.splice n, 0, item
		a

		
