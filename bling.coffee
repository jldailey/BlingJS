# License: MIT. Author: Jesse Dailey <jesse.dailey@gmail.com>

# Philoshopy
# ----------
# 1. Always work on _sets_, scalars are annoying.
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
	constructor: (args...) ->
		# See: plugins/hook.coffee
		return Bling.hook "bling-init", args

# We specify an inheritance similar to `class Bling extends (new Array)`,
# if such a thing were supported by the syntax directly.
Bling.prototype = []
Bling.prototype.constructor = Bling
Bling.global = if window? then window else global

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

Bling.plugin = (opts, constructor) ->
	if not constructor
		constructor = opts
		opts = {}

	# Support a { depends: } option as a shortcut for `$.depends`.
	if "depends" of opts
		return @depends opts.depends, =>
			# Support a { provides: } option as a shortcut for `$.provides`.
			@plugin { provides: opts.provides }, constructor
	try
		# We call the plugin constructor and expect that it returns an
		# object full of things to extend either Bling or it's prototype.
		if (plugin = constructor?.call @,@)
			# If the plugin has a `$` key, extend the root.
			extend @, plugin?.$
			# Clean off keys we no longer care about: `$` and `name`. (An
			# older version of plugin() used to require names,
			# but we ignore them now in favor of depends/provides.
			['$','name'].forEach (k) -> delete plugin[k]
			# Now put everything else on the Bling prototype.
			extend @::, plugin
			# Finally, add static wrappers for anything that doesn't have one.
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
do ->
	dep =
		q: []
		done: {}
		filter: (n) ->
			(if (typeof n) is "string" then n.split /, */ else n)
			.filter (x) -> not (x of dep.done)

	Bling.depends = (needs, f) ->
		if (needs = dep.filter needs).length is 0 then f()
		else
			dep.q.push (need) ->
				(needs.splice i, 1) if (i = needs.indexOf need) > -1
				return (needs.length is 0 and f)
		f

	Bling.provide = (needs, data) ->
		for need in dep.filter needs
			dep.done[need] = i = 0
			while i < dep.q.length
				if (f = dep.q[i] need)
					dep.q.splice i,1
					f data
					i = 0 # start over in case a nested dependency removed stuff 'behind' i
				else i++
		data


$ = Bling
# vim: ft=coffee sw=2 ts=2
