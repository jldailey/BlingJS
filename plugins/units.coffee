$.plugin
	depends: 'math'
	provides: 'units'
, ->
	# Units... just noodling
	# Units are strings with numbers followed by a unit suffix, like
	# "100px", "10pt", etc.
	# The purpose of handling them separately is to provide shorthand
	# to unit-aware math, so we override much of the Math plugin (not
	# the global Math object, though that might be fun...).

	# Define a RegEx to match a unit string.
	units = ["px","pt","pc","em","%","in","cm","mm","ex","lb","kg","yd","ft","m"]
	UNIT_RE = null
	do makeUnitRegex = -> UNIT_RE = new RegExp "(\\d+\\.*\\d*)(#{units.join '|'})"

	# Return the units portion of a string: "4.2px" yields "px"
	parseUnits = (s) ->
		if UNIT_RE.test(s)
			return UNIT_RE.exec(s)[2]
		null

	# Conversion rates between units, for better comparisons.
	conv = (a,b) ->
		if a of conv
			if b of conv[a]
				return conv[a][b]()
		0
	trick = (x) -> -> x # evaluate expression x now, return the final value later on request
	fillIdentityConversions = ->
		# sets a<->a and a<->"" converters to 1.0
		for a in units
			conv[a] or= {}
			for b in units
				unless b of conv[a]
					ident = a is b or a is "" or b is ""
					if ident
						conv[a][b] = trick +ident
	fillInferredConversions = ->
		inferred = 1
		while inferred > 0
			inferred = 0
			for a in units
				continue if a is ''
				for b in units
					continue if b is ''
					if (not conv a,b) and (conv b,a)
						conv[a] or= {}
						conv[a][b] = trick 1.0/conv(b,a)
						inferred += 1
					for c in units
						continue if c is ''
						if (conv a,b) and (conv b,c) and (not conv a,c)
							conv[a] or= {}
							conv[a][c] = trick conv(a,b) * conv(b,c)
							inferred += 1
		null
	setConversion = (from, to, f) ->
		conv[from] or= {}
		conv[from][to] = f
		if units.indexOf(from) is -1
			units.push from
		if units.indexOf(to) is -1
			units.push to
		makeUnitRegex()
		fillIdentityConversions()
		fillInferredConversions()
	setConversion 'in', 'pt', -> 72
	setConversion 'in', 'px', -> 96
	setConversion 'in', 'cm', -> 2.54
	setConversion 'm', 'ft', -> 3.3
	setConversion 'yd', 'ft', -> 3
	setConversion 'pc', 'pt', -> 12
	setConversion 'cm', 'mm', -> 10
	setConversion 'm', 'cm', -> 100
	setConversion 'em', 'px', ->
		w = 0
		try
			x = $("<span style='font-size:1em;visibility:hidden'>x</span>").appendTo("body")
			w = x.width().first()
			x.remove()
		w
	setConversion 'ex', 'px', ->
		w = 0
		try
			x = $("<span style='font-size:1ex;visibility:hidden'>x</span>").appendTo("body")
			w = x.width().first()
			x.remove()
		w
	setConversion 'ex', 'em', -> 2
	
	convertUnits = (number, unit) -> parseFloat(number) * conv[parseUnits(number)]?[unit]() + unit


	$.type.register "units",
		match: (x) -> typeof x is "string" and UNIT_RE.test(x)
		number: (x) -> parseFloat(x)
		string: (x) -> "'#{x}'"

	{
		$:
			units:
				set: setConversion
				get: conv
				convertTo: (to, obj) -> convertUnits(obj, to)
		convertTo: (to) -> @map (x) -> convertUnits(x, to)
		unitMap: (f) ->
			@map (x) ->
				f.call((n = parseFloat x), n) + parseUnits x

	}
