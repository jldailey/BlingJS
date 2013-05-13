$.plugin
	provides: "matches"
, ->
	return {
		$:
			matches: (pattern, obj) ->
				for k, v of pattern
					unless k of obj
						return false
					if ($.is 'regexp', v)
						continue if v.test obj[k]
						return false
					else if ($.is 'object', v)
						continue if $.matches v, obj[k]
						return false
					else if obj[k] isnt v
						return false
				return true
	}

