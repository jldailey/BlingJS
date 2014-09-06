$.plugin
	provides: "matches"
, ->
	matches = (pattern, obj) ->
		switch $.type pattern
			when 'function'
				return if pattern is matches.Any then true else (obj is pattern)
			when 'regexp' then return pattern.test obj
			when 'object', 'array'
				unless obj?
					return false
				if pattern instanceof Contains
					for k,v of obj
						if matches pattern.item, v then return true
					return false
				for k, v of pattern
					unless matches v, obj[k]
						return false
				return true
			else return obj is pattern
	class matches.Any # magic token
	class Contains then constructor: (@item) ->
	# dont require the use of 'new' in actual practice
	matches.Contains = (item) -> new Contains(item)
	return $: matches: matches
