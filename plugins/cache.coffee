$.plugin
	provides: "cache, Cache"
	depends: "core, sortBy, logger"
, ->

	class EffCache
		# In theory, the most efficient fixed-size cache will evict the
		# least efficient cache items.
		# An item's efficiency is n_gets / n_sets.
		# So for each key in the cache we need these two integers,
		# and a structure for listing the bottom N keys.
		log = $.logger "[LRU]"

		constructor: (@capacity = 1000, @defaultTtl = Infinity) ->
			@capacity = Math.max 0, @capacity
			# evict at least 3, as much as 10%
			@evictCount = Math.max 3, Math.floor @capacity * .1
			index = Object.create null
			order = []

			# The inverse efficiency of a cache item (for use in sortedIndex)
			eff = (o) -> -o.r / o.w

			autoEvict = =>
				return unless @capacity > 0
				if order.length >= @capacity
					while order.length + @evictCount - 1 >= @capacity
						delete index[k = order.pop().k]
				null

			reIndex = (i, j) ->
				for x in [i..j] when 0 <= x < order.length
					index[order[x].k] = x
				null

			rePosition = (i) ->
				obj = order[i]
				j = $.sortedIndex order, obj, eff
				if j isnt i
					order.splice i, 1
					order.splice j, 0, obj
					reIndex i, j
				null

			noValue	= v: undefined

			$.extend @,
				has: (k) -> k of index
				del: (k) ->
					if k of index
						i = index[k]
						order.splice i, 1
						delete index[k]
						reIndex i, order.length - 1
				set: (k, v, ttl = @defaultTtl) =>
					return v unless @capacity > 0
					if k of index
						d = order[i = index[k]]
						d.v = v
						d.w += 1
						rePosition i
					else
						autoEvict()
						item = { k, v, r: 0, w: 1 }
						i = $.sortedIndex order, item, eff
						order.splice i, 0, item
						reIndex i, order.length - 1
					if ttl < Infinity
						$.delay ttl, =>
							@del(k)
					v
				get: (k) ->
					ret = noValue
					if k of index
						# the current index
						i = index[k]
						ret = order[i]
						ret.r += 1
						rePosition i
					ret.v
				clear: ->
					for k of index # just break all the links to allow GC to cleanup
						order[index[k]] = null
					index = Object.create(null)
					order = []


	# $.Cache is both a class: new $.Cache(1200)
	# and, a static instance: $.Cache.get(key), $.Cache.set(key,val), $.Cache.has(key)
	# The static instance has 10000 max-items
	return $: Cache: $.extend EffCache, new EffCache(10000)

