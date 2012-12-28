# Memo Plugin
# -----------
# Wrap a function so that calls with the same argument return from a cache (without calling the wrapped function).
# Ex:
#    cachedWorker = $.memoize(function hardWorker(x,y) { ... })
#    f = $.memoize({
#      async: true
#      f: function asyncWorker(x,y,callback) { ... })
#    })
#    f(1,2,callback) # callback should get called here even if returning from cache
#
# $.memoize(opts)
#   f: (required, can be the lone argument)
#   async: bool (default: false)
#   hash: function (default: $.hash)
#   cache: object (default: new object)
# If opts is a function, that becomes opts
$.plugin
	depends: 'function'
	provides: 'memoize'
, ->
	$:
		# __$.memoize(f)__ returns a new function that caches function calls to f, based on hashing the arguments.
		memoize: (opts) ->
			if $.is 'function', opts
				opts = f: opts
			if not $.is 'object', opts
				throw new Error "Argument Error: memoize requires either a function or object as first argument"
			opts.cache or= Object.create(null)
			opts.hash or= $.identity
			return ->
				opts.cache[opts.hash(arguments)] ?= opts.f.apply @, arguments

	
