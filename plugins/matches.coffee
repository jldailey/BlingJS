$.plugin
	provides: "matches"
, ->
	matches = (pattern, obj) ->
		switch $.type pattern
			when 'function'
				if pattern is matches.Any then return true
				return obj is pattern
			when 'regexp' then return pattern.test obj
			when 'object', 'array'
				unless obj?
					return false
				for k, v of pattern
					unless matches v, obj[k]
						return false
				return true
			else return obj is pattern
	matches.Any = -> # magic token
	return $: matches: matches
