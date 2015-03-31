# Compat Plugin
# -------------
# This keeps getting smaller over time, but we just try to bundle
# 'shim-like' stuff here; adding or replacing basic ES5 stuff that
# we need to use.
$.plugin
	provides: "compat,trimLeft,split,lastIndexOf,join,preventAll,matchesSelector,isBuffer,Map"
, ->
	# if Buffer isn't defined globally, then isBuffer is always false
	$.global.Buffer or= { isBuffer: -> false }
	$.global.Map or= class Map # shim for the ES6 Map
		constructor: (iterable) ->
			data = Object.create null
			$.extend @, {
				size:       0
				keys:       -> Object.keys(data)
				values:     -> (v for k,v of data)
				entries:    -> ( [k,v] for k,v of data )
				has:    (k) -> k of data
				get:    (k) -> data[k]
				set: (k, v) ->
					@size += 1 unless k of data
					data[k] = v
					@
				delete: (k) ->
					@size -= 1 if k of data
					delete data[k]
					@
				clear:      ->
					data = Object.create null
					@size = 0
					@
				forEach: (cb, t) ->
					cb.call(t,k,v) for k,v of data
					@
			}
			for item in iterable
				@set item...

	# Make sure we have String functions: `trimLeft`, and `split`.
	String::trimLeft or= -> @replace(/^\s+/, "")
	String::split or= (sep) ->
		a = []; i = 0
		while (j = @indexOf sep,i) > -1
			a.push @substring(i,j)
			i = j + 1
		a
	# Find the last index of character `c` in the string `s`.
	String::lastIndexOf or= (s, c, i = -1) ->
		j = -1
		j = i while (i = s.indexOf c, i+1) > -1
		j

	# Make sure we have Array functions: `join`.
	Array::join or= (sep = '') ->
		n = @length
		return "" if n is 0
		s = @[n-1]
		while --n > 0
			s = @[n-1] + sep + s
		s

	# Add a handy nuke function to events: `preventAll`.
	if Event?
		Event::preventAll = () ->
			@preventDefault()
			@stopPropagation()
			@cancelBubble = true

	# Make sure we have Element functions: `matchesSelector`
	if Element?
		Element::matchesSelector = Element::webkitMatchesSelector or
			Element::mozMatchesSelector or
			Element::matchesSelector

	return { }
