do ($ = Bling) ->
	# Compat Plugin
	# -------------
	# This keeps getting smaller over time, but we just try to bundle
	# 'shim-like' stuff here; adding or replacing basic ES5 stuff that
	# we need to use.
	$.plugin ->
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

		# Make sure we have Element functions: `matchesSelector`, and
		# `cloneNode`.
		if Element?
			Element::matchesSelector = Element::webkitMatchesSelector or
				Element::mozMatchesSelector or
				Element::matchesSelector
			# If cloneNode does not take a 'deep' argument, add support.
			if Element::cloneNode.length is 0
				oldClone = Element::cloneNode
				Element::cloneNode = (deep = false) ->
					n = oldClone.call(@)
					if deep
						for i in @childNodes
							n.appendChild i.cloneNode true
					return n

		return { }
