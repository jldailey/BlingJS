$.plugin
	provides: "hook"
	depends: "type"
, ->

	# Hooks are one way to make extensible code that I am playing with.
	# Each hook is a method, that fronts for a list of methods.
	# You can add new methods to either end. To execute the whole hook,
	# you just call it with arguments.
	#
	# > hook = $.hook()
	# > hook.append (x) -> x + 2
	# > hook.append (x) -> x * 4
	# > hook(2)
	# 16


	hook = ->
		chain = []
		return $.extend ((args) ->
			for func in chain
				args = func.call @, args
			args
		), {
			prepend: (obj) -> chain.unshift(obj); obj
			append: (obj) -> chain.push(obj); obj
		}

	Bling.init = hook()

	Bling.init.prepend (args) ->
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
		b

	$: hook: hook

