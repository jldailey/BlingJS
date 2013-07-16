[$, assert] = require './setup'

describe "$.memoize", ->
	it "caches function calls", ->
		i = 0
		g = $.memoize f = -> ++i
		assert.equal g(), 1
		assert.equal g(), 1
		assert.equal f(), 2
		assert.equal f(), 3
		assert.equal g(), 1
	describe "longform options", ->
		it "f:", ->
			i = 0
			g = $.memoize {
				f: f = -> ++i
			}
			assert.equal g(), 1
			assert.equal g(), 1
			assert.equal f(), 2
			assert.equal f(), 3
			assert.equal g(), 1
		describe "hash:", ->
			i = 0
			g = $.memoize {
				f: -> ++i
				hash: (n) -> n[0] % 2
			}
			it "1 is uncached", ->
				assert.equal g(1), 1
			it "all odds are then cached", ->
				assert.equal g(3), 1
				assert.equal g(99), 1
			it "the next even is uncached", ->
				assert.equal g(42), 2
			it "all evens are then cached", ->
				assert.equal g(24), 2
				assert.equal g(4), 2
			it "odds are still cached", ->
				assert.equal g(9), 1

		describe "cache:", ->
			describe "with $.Cache", ->
				i = 0
				g = $.memoize {
					f: f = -> ++i
					cache: new $.Cache(3)
				}
				it "still works for basic caching", ->
					assert.equal g(), 1 # cache-miss
					assert.equal g(), 1 # cache-hit
					assert.equal f(), 2 # avoids cache and increments the real i
					assert.equal g(), 1 # cache-hit, to prove we aren't reading i
				it "different arguments cache separately", ->
					assert.equal g(1), 3 # cache-miss
					assert.equal g(2), 4 # cache-miss
					assert.equal g(1), 3 # cache-hit
					assert.equal g(3), 5 # cache-miss
					assert.equal g(4,5),6 # cache-miss
			
