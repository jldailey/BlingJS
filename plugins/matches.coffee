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
	for pattern_type,v of behaviors
		matches = { }
		for list in v
			f = list.pop()
			for obj_type in list
				matches[obj_type] = f
		$.type.extend pattern_type, { matches: matches }

	matches = (pattern, obj, pt = $.type.lookup pattern) ->
		if typeof pattern is 'object' then  switch
			when '$any' of pattern then return true
			when '$type' of pattern then return $.is pattern.$type, obj
			when '$class' of pattern then return $.isType pattern.$class, obj
		for type, f of pt.matches
			continue if type is 'else'
			if $.is type, obj
				return f pattern, obj, pt
		return pt.matches?.else?(pattern, obj, pt) ? IsEqual pattern, obj, pt

	matches.Any = { $any: true }
	matches.Type = (type) -> { $type: type }
	matches.Class = (klass) -> { $class: klass }

	return $: matches: matches
