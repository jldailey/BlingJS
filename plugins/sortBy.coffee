$.plugin
	provides: "sortBy,sortedIndex"
, ->
	$:
		sortedIndex: (array, item, field, cmp, dir=1) ->
			cmp or= if field?
				(a,b) -> a[field] - b[field]
			else
				(a,b) -> a - b
			for i in [0...array.length] by 1 # should use a binary search for large N
				if cmp(array[i], item)*dir > 0
					return i
			return array.length
	sortBy: (field, cmp, dir) ->
		for i in [0...@length] by 1
			item = @shift()
			n = $.sortedIndex @, item, field, cmp, dir
			@splice n, 0, item
		@

		
