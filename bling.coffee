# License: MIT. Author: Jesse Dailey <jesse.dailey@gmail.com>

# Philoshopy
# ----------
# 1. Always work on _sets_.
#    If you always write code to handle sets, you usually handle the scalar case for free.
# 2. Don't alter global prototypes; play _nice_ with others.
# 3. Have _fun_ and learn; about the DOM, about jQuery, about JavaScript and CoffeeScript.
# 4. Have the _courage_ to refactor; learning requires some chaos.

# Warming Up
# ---------
# We need a few things to get started.

# A shim for `Object.keys`.
Object.keys or= (o) -> (k for k of o)

# A shim for `Object.values`.
Object.values or= (o) -> (o[k] for k of o)

# A way to assign properties from `b` to `a`.
extend = (a, b...) ->
	for obj in b when obj
		a[k] = v for k,v of obj # when v?
	a

# The Bling Constructor
# =====================
# This is using coffee's class syntax, but only as a hack really.

# First, the class syntax is the only way to get a named function,
# and we want the Bling function to have a name so that
# `$().constructor.name == "Bling"`, for sanity, and for easily
# detecting a mixed-jQuery environment (we do try to play nice).

# But, we don't really want a real class, because the `new` operator is bad.
# What it does normally is make a shallow copy of the prototype to use as
# context and return value for the constructor.

# In that simple statement is basically the core of the JS type
# system, and even in that one sentence there are three problems:

# 1. _The copy is shallow_; creating partially-shared state between
# instances.
# 2. _There is a copy at all_; it's nice to avoid copying in critical
# sections whenever possible.
# 3. _It replaces the return value of the constructor_; reducing
# flexibility in implementations.

# So, the Bling constructor should not be called as `new Bling`,
# rather it should be used python style: `Bling(stuff)`.
class Bling # extends (new Array)
	"Bling:nomunge"
	constructor: (args...) ->
		# If there was only one argument,
		if args.length is 1
			# Classify the type to get a type-instance.
			# Then convert to an array-like
			args = $.type.lookup(args[0]).array(args[0])
		b = $.inherit Bling, args
		# Firefox clobbers the length when you change the inheritance chain on an array, so we patch it up here
		if args.length is 0 and args[0] isnt undefined
			i = 0
			i++ while args[i] isnt undefined
			b.length = i
		if 'init' of Bling # See: plugins/hook.coffee
			# This allows plugins to modify the constructor behavior
			return Bling.init(b)
		return b

# We specify an inheritance similar to `class Bling extends (new Array)`,
# if such a thing were supported by the syntax directly.
Bling:: = []
Bling::constructor = Bling
Bling.global = do -> @

# $.plugin( [ opts ], func )
# -----------------
# Each plugin function should return an object full of stuff to
# extend the Bling prototype with.

# Example: the simplest possible plugin.
# > `$.plugin -> echo: -> @`

# This defines: `$(...).echo()`.  Also, this will
# create a default 'static' helper: `$.echo`.

# You can explicitly define static helpers by nesting under a `$` key:
# > `$.plugin -> $: hello: -> "Hello!"`

# This would only define $.hello()

Bling.plugin = (opts, constructor) ->
	if not constructor
		constructor = opts
		opts = {}

	# If this plugin depends on anything, then defer.
	if "depends" of opts
		return @depends opts.depends, =>
			# Pass along any { provides: } option.
			@plugin { provides: opts.provides }, constructor
	try
		# We call the plugin constructor and expect that it returns an
		# object full of keys to extend either Bling or it's prototype.
		if typeof (plugin = constructor?.call @,@) is "object"
			# If the plugin has a `$` key, extend the root with static items.
			extend @, plugin?.$
			# What remains extends the Bling prototype.
			delete plugin.$
			extend @prototype, plugin
			# Add static wrappers for anything that doesn't have one.
			for key of plugin then do (key) =>
				@[key] or= (a...) => (@::[key].apply Bling(a[0]), a[1...])
			# Honor the { provides: } option.
			if opts.provides? then @provide opts.provides
	catch error
		console.log "failed to load plugin: #{@name} #{error.message}: #{error.stack}"
	@

# Dependency
# ----------
# $.depends, $.provide, represent dependencies between functions.

# Example: `$.depends "tag", -> $.log "hello"`
# This example will not log "hello" until `provide("tag")` is
# called.
extend Bling, do ->
	waiting = []
	complete = {}
	incomplete = (n) ->
		(if (typeof n) is "string" then n.split /, */ else n)
		.filter (x) -> not (x of complete)

	depend = (needs, func) ->
		if (needs = incomplete needs).length is 0 then func()
		else
			waiting.push (need) ->
				(needs.splice i, 1) if (i = needs.indexOf need) > -1
				return (needs.length is 0 and func)
		func

	depend: depend
	depends: depend # alias
	provide: (needs, data) ->
		caught = null
		for need in incomplete needs
			complete[need] = i = 0
			while i < waiting.length
				if (ready = waiting[i] need)
					waiting.splice i,1
					try ready data
					catch err then caught = err
					i = 0 # start over in case a nested dependency removed stuff 'behind' i
				else i++
		if caught then throw caught
		data

$ = Bling
