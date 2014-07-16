[$, assert] = require './setup'

describe "$.Cache", ->
	it "is a class", ->
		assert.equal typeof $.Cache, "function"
		c = new $.Cache()
		assert.equal typeof c.get, "function"
		assert.equal typeof c.set, "function"
	it "is also an instance of itself", ->
		assert.equal typeof $.Cache.get, "function"
		assert.equal typeof $.Cache.set, "function"
	describe "instances", ->
		it "can set capacity upon creation", ->
			cache = new $.Cache(101)
			assert.equal cache.capacity, 101
		it "can get/set cache items", ->
			cache = new $.Cache(10)
			cache.set 'a', { a: 1 }
			cache.set 'b', { b: 2 }
			assert.deepEqual { a: 1 }, cache.get 'a'
			assert.deepEqual { b: 2 }, cache.get 'b'
		it "evicts items when over capacity", ->
			cache = new $.Cache(5)
			i = 0
			assert.deepEqual $('a','b','c','d','e','f') \
				# Set all 6 items (one over full)
				.each((a) -> cache.set a, ++i) \
				# That 6th insert will trigger an eviction of (by default) 3 items
				.map((a) -> cache.get a),
				[ undefined, undefined, undefined,  4, 5, 6   ]
		it "supports evictCount option", ->
			cache = new $.Cache(5)
			cache.evictCount = 2
			i = 0
			assert.deepEqual $('a','b','c','d','e','f') \
				.each((a) -> cache.set a, ++i) \
				.map((a) -> cache.get a),
				[ undefined, undefined, 3, 4, 5, 6 ]
		it "evicts based on efficiency", ->
			cache = new $.Cache(5)
			cache.evictCount = 3
			i = 0
			$('a','b','c').each((a) -> cache.set a, ++i) # put some initial items in
			$.zeros(10).each(-> cache.get 'b' ) # make 'b' efficient
			$('d','e','f').each((a) -> cache.set a, ++i) # then overflow it
			assert.deepEqual $('a','b','c','d','e','f') \
				.map((a) -> cache.get a),
				# 'b' will have been preserved b/c of it's efficiency
				[ undefined, 2, undefined, undefined, 5, 6 ]
		it "supports a default TTL on all keys", (done) ->
			cache = new $.Cache(10, 50)
			cache.set('a', 'A')
			cache.set('b', 'B')
			$.delay 100, ->
				assert.equal cache.get('a'), undefined
				assert.equal cache.get('b'), undefined
				done()
		it "supports a TTL on single keys", (done) ->
			cache = new $.Cache(10)
			cache.set('a', 'A')
			cache.set('b', 'B', 30)
			$.delay 100, ->
				assert.equal cache.get('a'), 'A'
				assert.equal cache.get('b'), undefined
				done()

