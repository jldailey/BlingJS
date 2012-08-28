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

	$:
		# Get an array of sequential numbers.
		range: (start, end, step = 1) ->
			if not end? then (end = start; start = 0)
			step *= -1 if end < start and step > 0 # force step to have the same sign as start->end
			$( (start + (i*step)) for i in [0...Math.ceil( (end - start) / step )] )
		# Get an array of zeros.
		zeros: (n) -> $( 0 for i in [0...n] )
		# Get an array of ones.
		ones: (n) -> $( 1 for i in [0...n] )
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
	# Get the mean (average) of the set.
	mean: -> if not @length then 0 else @sum() / @length
	avg: -> @mean()
	# Get the sum of the set.
	sum: -> @filter( isFinite ).reduce(((a) -> a + @), 0)
	# Get the product of all items in the set.
	product: -> @filter( isFinite ).reduce (a) -> a * @
	# Get a new set with every item squared.
	squares: -> @map -> @ * @
	# Get the magnitude (vector length) of this set.
	magnitude: -> Math.sqrt @floats().squares().sum()
	# Get a new set, scaled by a real factor.
	scale: (r) -> @map -> r * @
	# Add this to d, get a new set.
	add: (d) -> switch $.type(d)
		when "number" then @map -> d + @
		when "bling","array" then $( @[i]+d[i] for i in [0...Math.min(@length,d.length)] )
	# Get a new vector with same direction, but magnitude equal to 1.
	normalize: -> @scale 1/@magnitude()
