do ($ = Bling) ->
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
		# This first piece of the pipe converts [selector, context] -> object;
		# and should always be in the _middle_ (if you `prepend` onto the
		# beginning of this pipe you should accept and return [selector, context].
		# If you `append` onto the end, you should accept and return a bling object.
		pipe("bling-init").prepend (args) ->
			[selector, context] = args
			# Classify the type of selector to get a type-instance, which is
			# used to convert the selector and context together to an array.
			$.inherit Bling, $.inherit {
				selector: selector
				context: context
			}, $.type.lookup(selector).array(selector, context)
			# Note: Uses inherit to _hijack_ the resulting array's prototype in-place.

		$: pipe: pipe

