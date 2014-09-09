$.plugin
	provides: "matches"
, ->
	matches = (pattern, obj) ->
		if pattern is matches.Any
			return true
		obj_type = $.type obj
		switch $.type pattern
			when 'null','undefined' then return (obj is pattern)
			when 'function'
				switch obj_type
					when 'array','bling' then for v in obj when (pattern is v) then return true
					when 'object' then for k,v of obj when (matches pattern, v) then return true
				return false
			when 'regexp'
				switch obj_type
					when 'null','undefined' then return false
					when 'string' then return pattern.test obj
					when 'number' then return pattern.test String(obj)
					when 'array','bling' then for v in obj when pattern.test v then return true
				return false
			when 'object'
				switch obj_type
					when 'null','undefined','string','number' then return false
					when 'array','bling' then for v in obj when matches pattern, v then return true
					when 'object' then for k, v of pattern when matches v, obj[k] then return true
				return false
			when 'array'
				switch obj_type
					when 'null','undefined','string','number','object' then return false
					when 'array','bling'
						for k,v of pattern when not (matches v, obj[k]) then return false
						return true # an empty array matches true against any other array
				return false
			when 'number'
				switch obj_type
					when 'null','undefined','object','string' then return false
					when 'number' then return (obj is pattern)
					when 'array','bling' then for v in obj when matches pattern, v then return true
				return false
			when 'string'
				switch obj_type
					when 'null','undefined','object' then return false
					when 'string' then return (obj is pattern)
					when 'array','bling' then for v in obj when matches pattern, v then return true
				return false
			else return obj is pattern
	class matches.Any # magic token
	return $: matches: matches
