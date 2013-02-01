$.plugin
	provides: "hook"
	depends: "type"
, ->

	# Hooks are one way to make extensible code that I am playing with.
	# Each hook is a method, that fronts for a list of methods.
	# You can add new methods to either end. To execute the whole hook,
	# you just call it with arguments.

	# Add a method to a hook:
	# > `$.hook("amplify").append (x) -> x+1`

	# The output of each function becomes the input of the next function
	# in the hook (they are composed).
	# > `$.hook("amplify").append (x) -> x*2`

	# Invoking a hook with arguments will call all the functions and
	# return the final value.
	# > `$.hook("amplify", 10) == 22`

	hooks = {}
	hook = (name, args) ->
		p = (hooks[name] or= [])
		if not args
			return {
				prepend: (obj) -> p.unshift(obj); obj
				append: (obj) -> p.push(obj); obj
			}
		for func in p
			args = func.call @, args
		args

	# Create the very first hook used by the constructor: "bling-init".
	hook("bling-init").prepend (args) ->
		# If there was only one argument,
		if args.length is 1
			# Classify the type to get a type-instance.
			# Then convert the args to an array.
			args = $.type.lookup(args[0]).array(args[0])
		b = $.inherit Bling, args
		# Firefox clobbers the length when you change the inheritance chain on an array, so we patch it up here
		if args.length is 0 and args[0] isnt undefined
			i = 0
			i++ while args[i] isnt undefined
			b.length = i
		b

	$: hook: hook

