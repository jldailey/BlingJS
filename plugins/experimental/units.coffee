$.plugin -> # Units... just noodling
	# Units are strings with numbers followed by a unit suffix, like
	# "100px", "10pt", etc.
	# The purpose of handling them separately is to provide shorthand
	# to unit-aware math, so we override much of the Math plugin (not
	# the global Math object, though that might be fun...).

	# Define a RegEx to match a unit string.
	units = ["px","pt","pc","em","%","in","cm","mm","ex",""]
	UNIT_RE = /(\d+\.*\d*)(px|pt|pc|em|%|in|cm|mm|ex)/

	# Split a unit string into [number, unit]
	parseUnits = (s) -> UNIT_RE.exec(s)[2] if UNIT_RE.test(s) else ""

	# Conversion rates between units, for better comparisons.
	conv = (a,b) -> conv[a][b]()
	trick = (x) -> -> x # this trick forces x to evaluate at creation
	for a in units
		for b in units
			(conv[a] or= {})[b] = trick +(a is b or a is "" or b is "")
	conv.in.pt = -> 72
	conv.in.px = -> 96
	conv.in.cm = -> 2.54
	conv.pc.pt = -> 12
	conv.cm.mm = -> 10
	conv.em.px = ->
		x = $("<span style='font-size:1em;visibility:hidden'>x</span>").appendTo("body")
		w = x.width().first()
		x.remove()
		w
	conv.ex.px = ->
		x = $("<span style='font-size:1ex;visibility:hidden'>x</span>").appendTo("body")
		w = x.width().first()
		x.remove()
		w
	conv.ex.em = -> 2
	fillIn = ->
		for a in units
			for b in units
				if not conv(a,b) and conv(b,a)
					console.log "found inverse: #{a}.#{b}"
					conv[a][b] = trick 1.0/conv(b,a)
				for c in units
					if not conv(a,c) and conv(a,b) and conv(b,c)
						console.log "found induction: #{a}.#{c}"
						conv[a][c] = trick conv(a,b) * conv(b,c)
	fillIn(); fillIn()
	
	convertUnits = (number, unit) -> parseFloat(number) * conv[parseUnits(number)][unit]() + unit

	$.assert(convertUnits("300px", "cm") == "10cm")

	convertAll = (to, a) ->
		for i in [0...a.length]
			a[i] = convertTo(to, a[i])

	Object.Type.register "units",
		match: (x) -> UNIT_RE.test(x)

	unit_scalar = (f) ->
		(a...) ->
			convertAll( unit = parseUnits(@[0]), @)
			(f.apply @, a) + unit
	unit_vector = (f) ->
		(a...) ->
			u = @map parseUnits
			f.apply(@floats(), a).map ->

	{
		min: unit_scalar -> @reduce (a) -> Math.min parseFloat(@), a
		max: unit_scalar -> @reduce (a) -> Math.max parseFloat(@), a
		sum: unit_scalar -> @reduce (a) -> parseFloat(@) + a
		mean: unit_scalar -> parseFloat(@sum()) / @length
		magnitude: unit_scalar -> Math.sqrt @floats().squares().sum()
		squares: -> @map -> (x=parseFloat(@)) * x
		scale: (n) -> @map -> n * parseFloat(@)
		add: (d) -> @map -> d + @
		normalize: -> @scale(1/@magnitude())
	}
