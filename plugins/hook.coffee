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
			prepend: (o) -> chain.unshift o; o
			append: (o) -> chain.push o; o
		}

	# The hook used by the constructor
	Bling.init = hook()

	return $: { hook }

