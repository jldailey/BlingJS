$.plugin
	provides: "auto"
, ->

	parsers = [
		/^\d+:/
		$.TNET

		/^[{\["']/
		JSON
	]

	register = (regex, codec) ->
		if parsers.indexOf(regex) + parsers.indexOf(codec) is -2
			parsers.push regex
			parsers.push codec
	
	$.depends "dom", -> register /^</, $.HTML
	
	parse = (s) ->
		for regex, i in parsers by 2
			if s.test regex
				return parsers[i+1].parse s
		null
	
	return $: AUTO: { parse }
