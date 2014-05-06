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
#   hash: function (default: $.hash)
#   cache: object (default: new object)
# If opts is a function, that becomes opts
$.plugin
	depends: 'function,hash'
	provides: 'memoize'
, ->
	plainCache = ->
		data = {}
		return {
			has: (k) -> k of data
			get: (k) -> data[k]
			set: (k,v) -> data[k] = v
		}

	$:
		# __$.memoize(f)__ returns a new function that caches function calls to f, based on hashing the arguments.
		memoize: (opts) ->
			if $.is 'function', opts
				opts = f: opts
			if not $.is 'object', opts
				throw new Error "Argument Error: memoize requires either a function or object as first argument"
			opts.cache or= plainCache()
			opts.hash or= $.hash
			return ->
				key = opts.hash arguments
				if opts.cache.has key then opts.cache.get key
				else opts.cache.set key, opts.f.apply @, arguments

