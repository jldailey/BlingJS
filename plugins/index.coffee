$.depends 'hook', ->
	$.init.append (obj) ->
		map = Object.create(null)
		keyMakers = []
		$.inherit {
			index: (keyFunc) ->
				if keyMakers.indexOf(keyFunc) is -1
					keyMakers.push keyFunc
					map[keyFunc] = Object.create(null)
				@each (x) ->
					map[keyFunc][keyFunc(x)] = x
			query: (criteria) ->
				for keyMaker in keyMakers
					key = keyMaker(criteria)
					return map[keyMaker][key] if key of map[keyMaker]
				null
		}, obj

