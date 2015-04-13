$.plugin
	provides: "debug, debugStack",
	depends: "core"
, ->
	explodeStack = (stack, node_modules) ->
		nl = /(?:\r\n|\r|\n)/
		fs = null
		try fs = require 'fs'
		catch err then return stack # if we aren't in node, reading files is meaningless
		lines = $(String(stack).split nl).filter(/^$/, false)
		unless node_modules
			lines = lines.filter(/node_modules/, false)
		message = lines.first()
		lines = lines.skip 1
		lines_cache = Object.create null
		files = lines.map (s) ->
			unless s? then return null
			f = s.replace(/^\s*at\s+/g,'') \
				.replace(/.*\(([^:]+:\d+:\d+)\)$/, "$1")
			try
				[f,ln_num,col] = f.split(/:/)
				f_lines = lines_cache[f] ?= String(fs.readFileSync f).split nl
				unless f_lines?
					return null
				before = ""
				if ln_num > 1
					before = f_lines[ln_num-2]
					if before.length > 80
						before = "..8<.. " + before.substr(col-25,50) + " ..>8.."
				if ln_num >= f_lines.length
					return null
				line = f_lines[ln_num-1]
				unless line?
					return null
				if line.length > 80
					line = "..8<.." + line.substr(col-25,50) + "..>8.."
					col = 31
				# count the tabs
				tabs = line.replace(/[^\t]/g,'').length
				# setup the spacer in a way that is terminal independent
				# (no guessing about tab display widths)
				spacer = $.repeat('\t', tabs) + $.repeat(' ', (col-1)-tabs)
				# it's not 100% flawless, it can be fooled by mixed spaces and tabs
				# it could attempt to really read the characters in order
				return """  #{ln_num-1} #{before}\n  #{ln_num} #{line}\n  #{ln_num} #{spacer}^"""
			catch err
				return null
				# TODO: verbose mode: return String(err.stack).split(nl).slice(0,2).join "\n"
		return message + "\n" + $.weave(files, lines).filter(null, false).join "\n"

	return $: {
		debugStack: (error, node_modules=false) ->
			stack = switch
				when $.is 'error', error then String(error.stack)
				when $.is 'string', error then error
				else String(error)
			explodeStack stack, node_modules
	}
