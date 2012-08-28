# String Plugin
# -------------
# Filling out the standard library of string functions.
$.plugin
	provides: "string"
	depends: "function"
, ->
	safer = (f) ->
		(a...) ->
			try return f(a...)
			catch err then return "[Error: #{err.message}]"
	$.type.extend
		# First, extend the base type with a default `string` function
		unknown:
			string: safer (o) -> o.toString?() ? String(o)
			repr: safer (o) -> $.type.lookup(o).string(o)
			number: safer (o) -> parseFloat String o
		# Now, for each basic type, provide a basic `string` function.
		# Later, more complex types will be added by plugins.
		null: { string: -> "null" }
		undefined: { string: -> "undefined" }
		string:
			number: safer parseFloat
			repr:   (s) -> "'#{s}'"
		array:  { string: safer (a) -> "[" + ($.toString(x) for x in a).join(",") + "]" }
		object: { string: safer (o) ->
			ret = []
			for k of o
				try
					v = o[k]
				catch err
					v = "[Error: #{err.message}]"
				ret.push "#{k}:#{$.toString v}"
			"{" + ret.join(', ') + "}"
		}
		function:
			string: (f) -> f.toString().replace(/^([^{]*){(?:.|\n|\r)*}$/, '$1{ ... }')
		number:
			repr:   (n) -> String(n)
			string: safer (n) ->
				switch true
					when n.precision? then n.toPrecision(n.precision)
					when n.fixed? then n.toFixed(n.fixed)
					else String(n)

	# Return a bunch of root-level string functions.
	return {
		$:
			# __$.toString(x)__ returns a fairly verbose string, based on
			# the type system's "string" method.
			toString: (x) ->
				if not x? then "function Bling(selector, context) { [ ... ] }"
				else
					try
						$.type.lookup(x).string(x)
					catch err
						"[Error: #{err.message}]"

			# __$.toRepr(x)__ returns a a code-like view of an object, using the
			# type system's "repr" method.
			toRepr: (x) -> $.type.lookup(x).repr(x)

			# __$.px(x,[delta])__ computes a "px"-string ("20px"), `x` can
			# be a number or a "px"-string; if `delta` is present it will
			# be added to the number portion.
			px: (x, delta=0) -> x? and (parseInt(x,10)+(delta|0))+"px"
			# Example: Add 100px of width to an element.

			# jQuery style:
			# `nodes.each(function(){ $(this).css("width",($(this).css("width") + 100) + "px")})`

			# Bling style:
			# `nodes.zap 'style.width', -> $.px @, + 100`

			# Properly **Capitalize** Each Word In A String.
			capitalize: (name) -> (name.split(" ").map (x) -> x[0].toUpperCase() + x.substring(1).toLowerCase()).join(" ")

			# Convert a _camelCase_ name to a _dash-name_.
			dashize: (name) ->
				ret = ""
				for i in [0...(name?.length|0)]
					c = name.charCodeAt i
					# For each uppercase character,
					if 91 > c > 64
						# Shift it to lower case and insert a '-'.
						c += 32
						ret += '-'
					ret += String.fromCharCode(c)
				ret

			# Convert a _dash-name_ to a _camelName_.
			camelize: (name) ->
				name.split('-')
				while (i = name?.indexOf('-')) > -1
					name = $.stringSplice(name, i, i+2, name[i+1].toUpperCase())
				name

			# Fill the left side of a string to make it a fixed width.
			padLeft: (s, n, c = " ") ->
				while s.length < n
					s = c + s
				s

			# Fill the right side of a string to make it a fixed width.
			padRight: (s, n, c = " ") ->
				while s.length < n
					s = s + c
				s

			stringTruncate: (s, n, c = "...") ->
				s = s.split(' ')
				r = []
				while n > 0
					x = s.shift()
					n -= x.length
					if n >= 0
						r.push x
				r.join('') + c


			# __$.stringCount(s,x)__ counts the number of occurences of `x` in `s`.
			stringCount: (s, x, i = 0, n = 0) ->
				if (j = s.indexOf x,i) > i-1
					$.stringCount s, x, j+1, n+1
				else n

			# __$.stringSplice(s,i,j,n)__ splices the substring `n` into the string `s', replacing indices
			# between `i` and `j`.
			stringSplice: (s, i, j, n) ->
				nn = s.length
				end = j
				if end < 0
					end += nn
				start = i
				if start < 0
					start += nn
				s.substring(0,start) + n + s.substring(end)

			# __$.checksum(s)__ computes the Adler32 checksum of a string.
			checksum: (s) ->
				a = 1; b = 0
				for i in [0...s.length]
					a = (a + s.charCodeAt(i)) % 65521
					b = (b + a) % 65521
				(b << 16) | a

			# __$.repeat(x, n)__ repeats x, n times.
			repeat: (x, n=2) ->
				switch true
					when n is 1 then x
					when n < 1 then ""
					when $.is "string", x then x + $.repeat(x, n-1)
					else $(x).extend $.repeat(x, n-1)

			# Return a string-builder, which uses arrays to defer all string
			# concatenation until you call `builder.toString()`.
			stringBuilder: ->
				if $.is("global", @) then return new $.stringBuilder()
				items = []
				@length   = 0
				@append   = (s) => items.push s; @length += s?.toString().length|0
				@prepend  = (s) => items.splice 0,0,s; @length += s?.toString().length|0
				@clear    = ( ) => ret = @toString(); items = []; @length = 0; ret
				@toString = ( ) => items.join("")
				@
		toString: -> $.toString @
		toRepr: -> $.toRepr @
	}
