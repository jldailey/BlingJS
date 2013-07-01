
$.plugin
	provides: "css,CSS"
, ->

	# Recursive helper that does the real work in $.CSS.stringify
	flatten = (o, prefix, into) ->
		unless prefix of into
			into[prefix] = []
		for k,v of o
			switch typeof v
				when "string","number"
					nk = k.replace(/([a-z]+)([A-Z]+)/g, "$1-$2").toLowerCase()
					into[prefix].push "#{nk}: #{v};"
				when "object"
					nk = if prefix then (prefix + k) else k
					flatten(v, nk, into)
				else throw new Error("unexpected type in css: #{typeof v}")
		return into

	trim = (str) -> str.replace(/^\s+/, '').replace(/\s+$/, '')

	stripComments = (str) ->
		while (i = str.indexOf "/*") > -1
			if (j = str.indexOf "*/", i) is -1
				break # Unclosed comments
			str = str.substring(0,i) + str.substring(j+2)
		str
	
	parse = (str, into) ->
		# <Selector> { <Rule> ... } ...
		if m = str.match /([^{]+){/
			selector = trim m[1]
			rest = str.substring m[0].length
			into[selector] or= {}
			if m = rest.match /([^}]+)}/
				body = m[1].split ';'
				rest = rest.substring m[0].length
				for rule in body
					colon = rule.indexOf ':'
					continue unless key = rule.substring(0,colon)
					key = trim key
					value = trim rule.substring(colon+1)
					into[selector][key] = value
			if rest.length > 0
				# Continue recursively until the whole string has been consumed
				return parse(rest, into)
		return into
	
	specialOps = '>+~'
	compact = (obj) ->
		# Given a flat parsing of CSS, compact the resulting object
		# such that rules that share a common prefix become nested objects
		ret = {}
		# Phase One: create nested objects for each rule part
		for selector, rules of obj
			# Clean the selector, so we can split it easily
			for op in specialOps
				# "div>p" becomes "div > p"
				selector = selector.replace op, " #{op} "
			# "div > p" becomes ["div",">","p"]
			parts = selector.split(/\s+/)
			switch parts.length
				when 0 then continue
				when 1 then $.extend (ret[selector] or= {}), rules
				else
					cur = ret
					first = true
					for part in parts
						unless first then part = " " + part
						cur = cur[part] or= {}
						first = false
					$.extend cur, rules
		# Phase Two: collapse nested rules
		# delete rules that have no children
		# if a node only has one child, and that child is an object, merge them
		# TODO: there is probably a way to do this compaction during phaseOne
		phaseTwo = (cur) ->
			modified = false
			for key, val of cur
				if $.is 'object', val
					subkeys = Object.keys(val)
					switch subkeys.length
						when 0
							delete cur[key]
						else
							if subkeys.length is 1 and $.is 'object', val[subkeys[0]]
								cur[key + subkeys[0]] = val[subkeys[0]] # lift sub-value up into a merged key
								delete cur[key] # delete old key
								phaseTwo cur # restart recursion from the top, in case we need to keep folding up into the root
					phaseTwo val
			cur
		return phaseTwo ret

	return {
		$:
			CSS:
				parse: (str, packed=false) ->
					# "a { width: 0; }" becomes { a: { width: 0; } }
					# with packed=true, "a { width: 0; } a > b.c { height: 0; }" becomes {
					#		a: {
					#			width: 0
					#			" > b.c ": {
					#				height: 0
					#			}
					#		}
					#	}
					ret = parse stripComments(str), {}
					return if packed then compact ret else ret
				stringify: (obj) ->
					return ("#{x} { #{y.join ' '} }" for x,y of flatten(obj, "", {}) when y.length > 0).join ' '
	}
