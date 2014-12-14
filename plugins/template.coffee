$.plugin
	depends: "StateMachine"
	provides: "template"
, -> # Template plugin, pythonic style: %(value).2f
	current_engine = null
	engines = {}

	template = {
		register_engine: (name, render_func) ->
			engines[name] = render_func
			if not current_engine?
				current_engine = name
		render: (text, args) ->
			if current_engine of engines
				engines[current_engine](text, args)
	}
	template.__defineSetter__ 'engine', (v) ->
		if not v of engines
			throw new Error "invalid template engine: #{v} not one of #{Object.Keys(engines)}"
		else
			current_engine = v
	template.__defineGetter__ 'engine', -> current_engine
	template.__defineGetter__ 'engines', -> $.keysOf(engines)

	template.register_engine 'null', do ->
		return (text, values) ->
			text

	# a bracket-matcher, useful in most template parsing steps
	match_forward = (text, find, against, start, stop = -1) ->
		count = 1
		if stop < 0
			stop = text.length + 1 + stop
		for i in [start...stop] by 1
			t = text[i]
			if t is against
				count += 1
			else if t is find
				count -= 1
			if count is 0
				return i
		return -1

	template.register_engine 'pythonic', do ->
		# '%.2f' becomes [key, pad, fixed, type, remainder]
		type_re = /([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/
		chunk_re = /%[\(\/]/

		compile = (text) ->
			chunks = text.split chunk_re
			n = chunks.length
			ret = [chunks[0]]
			j = 1 # insert marker into ret
			for i in [1...n] by 1
				end = match_forward chunks[i], ')', '(', 0, -1
				if end is -1
					return "Template syntax error: unmatched '%(' starting at: #{chunks[i].substring(0,15)}"
				key = chunks[i].substring 0, end
				rest = chunks[i].substring end
				match = type_re.exec rest
				if match is null
					return "Template syntax error: invalid type specifier starting at '#{rest}'"
				rest = match[4]
				ret[j++] = key
				# the |0 operation coerces to a number,
				# anything that doesnt map becomes 0,
				# so "3" -> 3, "" -> 0, null -> 0, etc.
				ret[j++] = match[1]|0
				ret[j++] = match[2]|0
				ret[j++] = match[3]
				ret[j++] = rest
			return ret
		compile.cache = {}

		render = (text, values) -> # replace markers in /text/ with /values/
			cache = compile.cache[text] # get the cached version
			if not cache?
				cache = compile.cache[text] = compile(text) # or compile and cache it
			output = [cache[0]] # the first block is always just text
			j = 1 # insert marker into output
			n = cache.length

			# then the rest of the cache items are: [key, pad, fixed, type, text remainder] 5-lets
			for i in [1..n-5] by 5
				[key, pad, fixed, type, rest] = cache[i..i+4]
				# the value to render for @ key
				value = values[key]
				# require the value
				if not value?
					value = "missing value: #{key}"
				# format the value according to the format options
				# currently supports 'd', 'f', and 's'
				switch type
					when 'd'
						output[j++] = "" + parseInt(value, 10)
					when 'f'
						output[j++] = parseFloat(value).toFixed(fixed)
					# output unsupported formats like %s strings
					# TODO: add support for more formats
					when 's'
						output[j++] = "" + value
					else
						output[j++] = "" + value
				if pad > 0
					output[j] = String.PadLeft output[j], pad
				output[j++] = rest
			output.join ""

		return render

	template.register_engine 'js-eval', do -> # work in progress...
		class TemplateMachine extends $.StateMachine
			@STATE_TABLE = [
				{ # 0: START
					enter: () ->
						@data = []
						@GO(1)
				},
				{ # 1: read anything
				}
			]

		return (text, values) ->
			text

	return $: { template }
