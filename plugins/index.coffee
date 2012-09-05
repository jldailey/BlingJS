$.depends 'pipe', ->
	$.pipe('bling-init').append (obj) ->
		map = {}
		keyMaker = null
		$.inherit {
			index: (keyFunc) ->
				keyMaker = keyFunc
				@each (x) ->
					map[keyFunc(x)] = x
			query: (criteria) ->
				if $.is 'function', keyMaker
					key = keyMaker(criteria)
					return map[key] if key of map
				null
		}, obj

