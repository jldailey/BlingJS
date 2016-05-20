$.depends 'hook', ->
	$.init.append (obj) ->
		map = new Map()
		keyMakers = []
		$.inherit {
			index: (keyFunc) ->
				if keyMakers.indexOf(keyFunc) is -1
					keyMakers.push keyFunc
					map.set(keyFunc.toString(), new Map())
				for x in @
					key = keyFunc x
					_map = map.get keyFunc.toString()
					unless _map.has key
						_map.set key, $()
					_map.get(key).push x
				@
			query: (criteria) ->
				for keyMaker in keyMakers
					_map = map.get keyMaker.toString()
					if _map.has key = keyMaker criteria
						return _map.get(key)
				return $()
			queryOne: (criteria) ->
				return @query(criteria)[0]
		}, obj

