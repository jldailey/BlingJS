$.plugin
	provides: "debug, debugStack",
	depends: "core"
, ->
	explodeStack = (stack) ->
		fs = null
		try fs = require 'fs'
		catch err then return stack # if we aren't in node, reading files is meaningless
		lines = $(String(stack).split(/(?:\r\n|\r|\n)/)).filter(/^$/, false)
		message = lines.first()
		lines = lines.skip 1
		files = lines.map (s) ->
			f = s.replace(/^\s*at\s+/,'')
				.replace(/^[^(]*\(/,'(')
				.replace(/^\(/,'')
				.replace(/\)$/,'')
			try
				[f,ln_num,col] = f.split(/:/)
				data = String(fs.readFileSync f)
				f_lines = data.split(/(?:\r\n|\r|\n)/)
				line = f_lines[ln_num-1]
				# count the tabs
				tabs = line.replace(/[^\t]/g,'').length
				# setup the spacer in a way that is terminal independent
				# (no guessing about tab display widths)
				spacer = $.repeat('\t', tabs) + $.repeat(' ', (col-1)-tabs)
				# it's not 100% flawless, it can be fooled by mixed spaces and tabs
				# it could attempt to really read the characters in order
				return """  #{ln_num} #{line}\n  #{ln_num} #{spacer}^"""
			catch err
				return "  " + String(err).replace(/\n/,'')
		return message + "\n" + $.weave(files, lines).join "\n"

	return $: {
		debugStack: (error) ->
			explodeStack switch true
				when $.is 'error', error then String(error.stack)
				when $.is 'string', error then error
				else new Error('unsupported error type: ' + $.type error)
	}
