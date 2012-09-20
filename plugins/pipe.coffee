$.plugin
	provides: "pipe"
	depends: "type"
, ->

	# Pipes are one way to make extensible code that I am playing with.
	# Each pipe is a named list of methods. You can add new
	# methods to either end. To execute the whole pipe you call it
	# with an array of arguments.

	# Add a method to a pipe:
	# > `$.pipe("amplify").append (x) -> x+1`

	# The output of each function becomes the input of the next function
	# in the pipe.
	# > `$.pipe("amplify").append (x) -> x*2`

	# Invoking a pipe with arguments will call all the functions and
	# return the final value.
	# > `$.pipe("amplify", 10) == 22`

	pipes = {}
	pipe = (name, args) ->
		p = (pipes[name] or= [])
		if not args
			return {
				prepend: (obj) -> p.unshift(obj); obj
				append: (obj) -> p.push(obj); obj
			}
		for func in p
			args = func.call @, args
		args

	# Create the very first pipe used by the constructor: "bling-init".
	pipe("bling-init").prepend (args) ->
		# If there was only one argument,
		if args.length is 1
			# Classify the type to get a type-instance.
			# Then convert the args to an array.
			args = $.type.lookup(args[0]).array(args[0])
		$.inherit Bling, args
		# Note: Uses inherit to _hijack_ the resulting array's prototype in-place.

	$: pipe: pipe

