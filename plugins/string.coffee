# String Plugin
# -------------
# Filling out the standard library of string functions.
$.plugin
	provides: "string"
	depends: "function"
, ->
	safer = (f) -> (a...) ->
		try return f(a...)
		catch err then return "[Error: #{err.message}]"
	escape_single_quotes = (s) -> s.replace(/([^\\]{1})'/g,"$1\\'")
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
			repr: (s) -> "'#{escape_single_quotes s}'"
		array:
			string: safer (a) -> "[#{a.map($.toString).join()}]"
			repr: safer (a) -> "[#{a.map($.toRepr).join()}]"
		arguments:
			string: safer (a) -> "[#{($.toString(x) for x in a).join()}]"
			repr: safer (a) -> "[#{($.toRepr(x) for x in a).join()}]"
		object:
			string: safer (o) ->
				ret = []
				for k of o
					try
						v = o[k]
					catch err
						v = "[Error: #{err.message}]"
					ret.push "#{k}:#{$.toString v}"
				"{" + ret.join(', ') + "}"
			repr: safer (o) ->
				ret = []
				for k of o
					try
						v = o[k]
					catch err
						v = "[Error: #{err.message}]"
					ret.push "#{k}:#{$.toRepr v}"
				"{" + ret.join(', ') + "}"
		function:
			repr: (f) -> f.toString()
			string: (f) -> f.toString().replace(/^([^{]*){(?:.|\n|\r)*}$/, '$1{ ... }')
		number:
			repr: (n) -> String(n)
			string: safer (n) -> switch
				when n.precision? then n.toPrecision(n.precision)
				when n.fixed? then n.toFixed(n.fixed)
				else String(n)

	# Return a bunch of root-level string functions.
	return {
		$:
			# __$.toString(x)__ returns a fairly verbose string, based on
			# the type system's "string" method.
			toString: (x) ->
				if arguments.length is 0 then "function Bling() { [ ... ] }"
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
			px: (x, delta=0) -> x? and (parseInt(x,10)+(parseInt(delta)|0))+"px"
			# Example: Add 100px of width to an element.

			# jQuery style:
			# `nodes.each(function(){ $(this).css("width",($(this).css("width") + 100) + "px")})`

			# Bling style:
			# `nodes.zap 'style.width', -> $.px @, + 100`

			# Properly **Capitalize** Each Word In A String.
			capitalize: (name) ->
				(name.split(" ").map (x) -> x[0].toUpperCase() + x.substring(1).toLowerCase()).join(" ")

			slugize: slugize = (phrase, slug="-") ->
				phrase = switch $.type phrase
					when 'null','undefined' then ""
					when 'object' then ($.slugize(k,slug) + slug + $.slugize(v, slug) for k,v of phrase).join slug
					when 'array','bling' then phrase.map((item)-> $.slugize item, slug).join slug
					else String(phrase)
				phrase.toLowerCase() \
					.replace(/^\s+/, '') \
					.replace(/\s+$/, '') \
					.replace(/\t/g, ' ') \
					.replace(/[^A-Za-z0-9. -]/g, '') \
					.replace(/\s+/g,'-')
			stubize: slugize

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
				name = $.slugize(name)
				name.split('-')
				while (i = name?.indexOf('-')) > -1
					name = $.stringSplice(name, i, i+2, name[i+1].toUpperCase())
				name

			# Add decorative commas to long numbers (or currencies)
			commaize: (num, comma=',',dot='.',currency='') ->
				if $.is 'number', num
					s = String(num)
					if not isFinite num
						return s
					sign = if (num < 0) then "-" else ""
					[a, b] = s.split '.' # split the whole part from the decimal part
					if a.length > 3 # if the whole part is long enough to need commas
						a = $.stringReverse $.stringReverse(a).match(/\d{1,3}/g).join comma
					return sign + currency + a + (if b? then dot+b else "")

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

			stringTruncate: (s, n, c='...') ->
				if s.length <= n
					return s
				s = s.split(' ') # split into words.
				r = []
				while n > 0
					x = s.shift()
					n -= x.length
					if n >= 0
						r.push x
				r.join(' ') + c


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

			stringReverse: (s) -> s.split('').reverse().join('')

			# __$.checksum(s)__ computes the Adler32 checksum of a string.
			checksum: (s) ->
				a = 1; b = 0
				for i in [0...s.length]
					a = (a + s.charCodeAt(i)) % 65521
					b = (b + a) % 65521
				(b << 16) | a

			# __$.repeat(x, n)__ repeats x, n times.
			repeat: (x, n=2) -> switch
				when n is 1 then x
				when n < 1 then ""
				when $.is "string", x then $.zeros(n, x).join ''
				else $.zeros(n, x)

			# Return a string-builder, which uses arrays to defer all string
			# concatenation until you call `builder.toString()`.
			stringBuilder: do ->
				len = (s) -> s?.toString().length | 0
				->
					if $.is("global", @) then return new $.stringBuilder()
					items = []
					$.extend @,
						length: 0
						append:  (s) => items.push s; @length += len s
						prepend: (s) => items.splice 0,0,s; @length += len s
						clear:       => ret = @toString(); items = []; @length = 0; ret
						toString:    -> items.join("")
		toString: -> $.toString @
		toRepr: -> $.toRepr @
		replace: (patt, repl) ->
			@map (s) -> s.replace(patt, repl)
		indexOf: (target) ->
			if $.is 'regexp', target
				for i in [0...@length] by 1
					if target.test @[i]
						return i
				return -1
			else Array::indexOf.apply @, arguments
	}
