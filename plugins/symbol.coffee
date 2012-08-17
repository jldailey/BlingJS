do ($ = Bling) ->

	# Symbol Plugin
	# -------------
	# Symbol adds a dynamic property: Bling.symbol, which contains the
	# current global binding where you can find Bling (default: `$`).

	# When you assign a symbol, it carefully tracks the previous values
	# and restores them later if you change.  This is all so we can
	# play nice with jQuery and underscore.  For instance, if you load
	# jQuery, then load Bling, you set `Bling.symbol = "_"` and `$` will
	# go back to pointing at jQuery, and you can do `_(...)` to create a
	# Bling set.

	# There is no restriction on the length or nature of the symbol
	# except that it must be a valid JavaScript identifier:
	# > `Bling.symbol = 'foo'; $.is("bling", foo()) == true`
	$.plugin
		provides: "symbol"
		depends: "type"
	, ->
		# The current symbol.
		symbol = null
		# Allocate some space to remember clobbered symbols.
		cache = {}
		g = $.global
		# Export the global 'Bling' symbol.
		g.Bling = Bling
		if module?
			module.exports = Bling
		# Define $.symbol as a dynamic property.
		$.defineProperty $, "symbol",
			set: (v) ->
				# When you assign to $.symbol, it _moves_ the current
				# shortcut for Bling, preserving previous values.
				g[symbol] = cache[symbol]
				cache[symbol = v] = g[v]
				g[v] = Bling
			get: -> symbol
		return $:
			symbol: "$"
			noConflict: ->
				Bling.symbol = "Bling"
				Bling
		# Example:
		# > `Bling.symbol = "_"; _("body").html("Hello World");`
		# If `$` had been bound before, it's value will be restored.
