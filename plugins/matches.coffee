$.plugin
	provides: "matches"
	depends: "function,core,string"
, ->
	IsEqual = (p, o, t) -> (o is p)
	Contains = (p, a, t) ->
		for v in a when (matches p, v, t) then return true
		return false
	ContainsValue = (p, o, t) ->
		for k,v of o when (matches p, v, t) then return true
		return false
	ObjMatch = (p, o, t) -> # matches if all keys match
		for k,v of p when not (matches v, o[k]) then return false
		return true
	ArrayMatch = (p, o, t) ->
		for v,i in p when not (matches v, o[i]) then return false
		return true
	RegExpMatch = (p, s, t) -> p.test String(s)

	# specify the comparison behavior data
	behaviors = {
		'function': [
			['array', 'bling', Contains]
			['object', ContainsValue]
		]
		regexp: [
			['string','number', RegExpMatch ]
			['array','bling', Contains ]
			['object', ContainsValue ]
		]
		object: [
			['array','bling', Contains ]
			['object', ObjMatch ]
		]
		array: [
			['array','bling', ArrayMatch ]
		]
		number: [
			['number', IsEqual ]
			['array','bling', Contains ]
		]
		string: [
			['string', IsEqual ]
			['array','bling', Contains ]
		]
	}
	# parse the behavior data into the $.type system
	for pt,v of behaviors
		matches = { }
		for list in v
			f = list.pop()
			for obj_type in list
				matches[obj_type] = f
		$.type.extend pt, { matches }

	specialPatterns = {
		$any: -> true
		$type:  (p, o, t) -> $.is p.$type, o
		$class: (p, o, t) -> $.isType p.$class, o
		$lt:    (p, o, t) -> o < p.$lt
		$gt:    (p, o, t) -> o > p.$gt
		$lte:   (p, o, t) -> o <= p.$lte
		$gte:   (p, o, t) -> o >= p.$gte
	}

	matches = (pattern, obj, pt = $.type.lookup pattern) ->
		if pt.name is 'object'
			for k, f of specialPatterns
				if k of pattern
					return f pattern, obj, pt
		for type, f of pt.matches
			continue if type is 'else'
			if $.is type, obj
				return f pattern, obj, pt
		return pt.matches?.else?(pattern, obj, pt) ? IsEqual pattern, obj, pt

	matches.Any = { $any: true }
	matches.Type = (type) -> { $type: type }
	matches.Class = (klass) -> { $class: klass }

	return $: matches: matches
