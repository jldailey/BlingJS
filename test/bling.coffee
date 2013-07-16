[$, assert] = require './setup'

describe "Object", ->
	it "should have a keys method", ->
		assert typeof Object.keys is "function"
	it "should have a values method", ->
		assert typeof Object.values is "function"
	describe ".keys()", ->
		it "should return the list of keys", ->
			assert.deepEqual Object.keys( "a": 1, b: 2 ), ['a', 'b']
	describe ".values()", ->
		it "should return the list of values", ->
			assert.deepEqual Object.values( "a": 1, b: 2 ), [1, 2]

describe "Bling", ->
	it "should have a symbol with side effects", ->
		assert Bling?
		assert.equal Bling.symbol, "$"
		assert.equal global.$, Bling
		Bling.symbol = "_"
		assert.equal global._, Bling
		global.$ = "before"
		Bling.symbol = "$"
		assert.equal global.$, Bling
		Bling.symbol = "_"
		assert.equal global.$, "before"
		Bling.symbol = "$"
		assert.equal global.$, Bling
	it "should be constructable by call (python style)", ->
		b = Bling([1,2,3])
		assert.equal b[0], 1
		assert.equal b[1], 2
		assert.equal b[2], 3
	it "should have have the right constructor name", ->
		assert.equal Bling([1,2]).constructor.name, "Bling"
	it "should correct the length value", ->
		assert.equal(Array(10).length,10)
		assert.equal(Bling(10).length, 0)
	it "can be created from an array", ->
		assert.deepEqual $([1,2,3]), [1,2,3]
	it "can be created from multiple arguments", ->
		assert.deepEqual $(1,2,3), [1,2,3]
	it "can be created from CSS selector", (done) ->
		$.depends 'dom', ->
			assert.equal $("td").length, 8
			done()
	it "can be created from an arguments object", ->
		f = -> Bling(arguments)
		assert.equal $.type(f(1,2,3)), "bling"
		assert.equal f(1,2,3).length, 3
		assert.deepEqual f(1,2,3), [1,2,3]

	describe ".plugin()", ->
		describe "creating new plugins", ->
			$.plugin ->
				$:
					testGlobal: -> 9
				testOp: -> 42
			it "should define new globals", ->
				assert.equal $.testGlobal?(), 9
			it "should define new instance methods", ->
				assert.equal $().testOp?(), 42
			it "should provide a default global wrapper", ->
				assert.equal $.testOp?(), 42

	describe ".keysOf()", ->
		it "is like Object.keys", ->
			assert.deepEqual $.keysOf(a:1), ['a']
		it "returns a bling", ->
			assert $.is 'bling', $.keysOf(a:1)
		it "includes any enumerable property", ->
			a = a: 1
			$.defineProperty a, "b", get: -> 2
			assert.deepEqual $.keysOf(a), ["a", "b"]

	describe ".valuesOf()", ->
		it "returns a bling", ->
			assert $.is 'bling', $.valuesOf(a:1)
		it "returns the set of values", ->
			assert.deepEqual $.valuesOf(a:1), [1]
		it "includes any enumerable properties", ->
			a = a: 1
			$.defineProperty a, "b", get: -> 2
			assert.deepEqual $.valuesOf(a), [1, 2]

