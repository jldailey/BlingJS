# Math Plugin
# -----------
# All the stuff you need to use blings as vectors in linear algebra.
$.plugin
	provides: "math"
	depends: "core"
, ->
	$.type.extend
		bool: { number: (o) -> if o then 1 else 0 }
		number: { bool: (o) -> not not o }

	_By = (cmp) ->
		(field) ->
			valueOf = switch $.type field
				when "string" then (o) -> o[field]
				when "function" then field
				else throw new Error ".maxBy first argument should be a string or function"
			x = @first()
			@skip(1).each ->
				if cmp valueOf(@), valueOf(x)
					x = @
			return x

	$:
		# Get an array of sequential numbers.
		range: (start, end, step = 1) ->
			if not end? then (end = start; start = 0)
			step *= -1 if end < start and step > 0 # force step to have the same sign as start->end
			$( (start + (i*step)) for i in [0...Math.ceil( (end - start) / step )] )
		# Get an array of zeros.
		zeros: (n, z = 0) -> $( z for i in [0...n] )
		# Get an array of ones.
		ones: (n) -> $( 1 for i in [0...n] )
		deg2rad: (n) -> n * Math.PI / 180
		rad2deg: (n) -> n * 180 / Math.PI
	# Convert everything to a float.
	floats: -> @map parseFloat
	# Convert everything to an int.
	ints: -> @map -> parseInt @, 10
	# Convert everything to a "px" string.
	px: (delta) -> @ints().map -> $.px @,delta
	# Get the smallest element (defined by Math.min)
	min: -> @filter( isFinite ).reduce Math.min
	# Get the largest element (defined by Math.max)
	max: -> @filter( isFinite ).reduce Math.max
	# Get the object with the highest value in a field.
	maxBy: _By (a,b) -> a > b
	minBy: _By (a,b) -> a < b
	# Get the mean (average) of the set.
	mean: mean = -> if not @length then 0 else @sum() / @length
	avg: mean
	# Get the sum of the set.
	sum: -> @filter( isFinite ).reduce(((a) -> a + @), 0)
	# Get the product of all items in the set.
	product: -> @filter( isFinite ).reduce (a) -> a * @
	# Get a new set with every item squared.
	squares: -> @pow(2)
	pow: (n) -> @map -> Math.pow @, n
	# Get the magnitude (vector length) of this set.
	magnitude: -> Math.sqrt @floats().squares().sum()
	# Get a new set, scaled by a real factor.
	scale: (r) -> @map -> r * @
	# Add this to d, get a new set.
	add: add = (d) -> switch $.type(d)
		when "number" then @map -> d + @
		when "bling","array" then $( @[i]+d[i] for i in [0...Math.min(@length,d.length)] )
	plus: add
	# Vector substraction
	sub: sub = (d) -> switch $.type d
		when "number" then @map -> @ - d
		when "bling","array" then $( @[i]-d[i] for i in [0...Math.min @length, d.length])
	minus: sub
	# Compute the dot-product.
	dot: (b) ->
		$.sum( @[i]*b[i] for i in [0...Math.min(@length,b.length)] )
	# Compute theta (the angle between two vectors)
	angle: (b) -> Math.acos (@dot(b) / (@magnitude() * b.magnitude()))
	# Compute the vector cross-product.
	cross: (b) ->
		$ @[1]*b[2] - @[2]*b[1],
			@[2]*b[0] - @[0]*b[2],
			@[0]*b[1] - @[1]*b[0]
	# Get a new vector with same direction, but magnitude equal to 1.
	normalize: -> @scale 1 / @magnitude()
	deg2rad: -> @filter( isFinite ).map -> @ * Math.PI / 180
	rad2deg: -> @filter( isFinite ).map -> @ * 180 / Math.PI
