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
	units = $ ["px","pt","pc","em","%","in","cm","mm","ex","lb","kg","yd","ft","m", ""]
	UNIT_RE = null
	do makeUnitRegex = ->
		joined = units.filter(/.+/).join '|'
		UNIT_RE = new RegExp "(\\d+\\.*\\d*)((?:#{joined})/*(?:#{joined})*)$"

	# Return the units portion of a string: "4.2px" yields "px"
	parseUnits = (s) ->
		if UNIT_RE.test(s)
			return UNIT_RE.exec(s)[2]
		""

	# The core conversion routine:
	conv = (a,b) ->
		[numer_a, denom_a] = a.split '/'
		[numer_b, denom_b] = b.split '/'
		if denom_a? and denom_b?
			return conv(denom_b, denom_a) * conv(numer_a, numer_b)
		if a of conv and (b of conv[a])
			return conv[a][b]()
		0

	# A locker is a function for returning a fixed value,
	# `locker <expression>` evaluates the expression and returns the result later.
	locker = (x) -> -> x

	# Compute any conversions that we can figure out programmatically (identity, inverses, inference)
	fillConversions = ->
		# For now, this is just a stub, because we don't want the initial setup calls to do any of this
		# Right after all the initial conversions are set, we put the real code back in


	setConversion = (from, to, f) ->
		conv[from] or= {}
		conv[from][to] = f
		if units.indexOf(from) is -1
			units.push from
		if units.indexOf(to) is -1
			units.push to
		makeUnitRegex()
		fillConversions()

	initialize = ->
		setConversion 'pc', 'pt', -> 12
		setConversion 'in', 'pt', -> 72
		setConversion 'in', 'px', -> 96
		setConversion 'in', 'cm', -> 2.54
		setConversion 'm', 'ft', -> 3.281
		setConversion 'yd', 'ft', -> 3
		setConversion 'cm', 'mm', -> 10
		setConversion 'm', 'cm', -> 100
		setConversion 'm', 'meter', -> 1
		setConversion 'm', 'meters', -> 1
		setConversion 'ft', 'feet', -> 1
		setConversion 'km', 'm', -> 1000
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
		setConversion 'rad', 'deg', -> 57.3
		setConversion 's', 'sec', -> 1
		setConversion 's', 'ms', -> 1000
		setConversion 'ms', 'ns', -> 1000000
		setConversion 'min', 'sec', -> 60
		setConversion 'hr', 'min', -> 60
		setConversion 'hr', 'hour', -> 1
		setConversion 'hr', 'hours', -> 1
		setConversion 'day', 'hr', -> 24
		setConversion 'day', 'days', -> 1
		setConversion 'y', 'year', -> 1
		setConversion 'y', 'years', -> 1
		setConversion 'y', 'd', -> 365.25
		setConversion 'g', 'gram', -> 1
		setConversion 'g', 'grams', -> 1
		setConversion 'kg', 'g', -> 1000
		setConversion 'lb', 'g', -> 453.6
		setConversion 'lb', 'oz', -> 16
		setConversion 'f', 'frame', -> 1
		setConversion 'f', 'frames', -> 1
		setConversion 'sec', 'f', -> 60

		# Now fill in the conversions, and assign the reference back
		# so further calls to setConversion will do the exhaustive fill.
		do fillConversions = ->
			# set up all the identity conversions (self to self, or to unitless)
			conv[''] = {}
			one = locker 1.0
			for a in units
				conv[a] or= {}
				conv[a][a] = conv[a][''] = conv[''][a] = one

			# set up all inverse and inference conversions (exhaustively)
			infered = 1
			while infered > 0
				infered = 0
				for a in units when a isnt ''
					conv[a] or= {}
					for b in units when b isnt ''
						if (not conv a,b) and (conv b,a)
							conv[a][b] = locker 1.0/conv(b,a)
							infered += 1
						for c in units when c isnt ''
							if (conv a,b) and (conv b,c) and (not conv a,c)
								conv[a][c] = locker conv(a,b) * conv(b,c)
								infered += 1
			null

		$.units.enable = ->

	convertNumber = (number, unit) ->
		f = parseFloat(number)
		u = parseUnits(number)
		c = conv(u, unit)
		unless isFinite(c) and isFinite(f)
			return number
		"#{f * c}#{unit}"


	$.type.register "units",
		is: (x) -> typeof x is "string" and UNIT_RE.test(x)
		number: (x) -> parseFloat(x)
		string: (x) -> "'#{x}'"

	{
		$:
			units:
				enable: initialize
				set: setConversion
				get: conv
				convertTo: (unit, obj) -> convertNumber(obj, unit)
		convertTo: (unit) -> @map (x) -> convertNumber(x, unit)
		unitMap: (f) ->
			@map (x) ->
				f.call((n = parseFloat x), n) + parseUnits x
	}
