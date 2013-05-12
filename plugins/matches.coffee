$.plugin
	provides: "matches"
, ->
	return {
		$:
			matches: (obj, pattern) ->
				for k, v of pattern
					unless k of obj
						return false
					if ($.is 'regex', v) and not v.test obj[k]
						return false
					if ($.is 'object', v)
						continue if $.matches obj[k], v
						return false
					if obj[k] isnt v
						return false
				return true
	}

