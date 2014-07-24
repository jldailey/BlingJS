[$, assert] = require './setup'

describe "$.hash", ->
	describe "hashes any type of object", ->
		it "number", -> assert $.hash(42) isnt $.hash(43)
		it "string", -> assert $.hash("foo") isnt $.hash("bar")
		it "array", -> assert $.hash("poop") isnt $.hash(["poop"])
		it "object", -> assert ($.hash a:1) isnt ($.hash a:2)
		it "bling", -> assert ($.hash $)?
		describe "arguments", ->
			f = -> $.hash arguments
			it "f(1) == f(1)", ->
				assert.equal f(1), f(1)
			it "f() == f()", ->
				assert.equal f(), f()
			it "f(1) != f(2)", ->
				assert.notEqual f(1), f(2)

	describe "always produces finite hashes", ->
		it "for objects", -> assert isFinite $.hash a:1
		it "for empty objects", -> assert isFinite $.hash {}
		it "for naked objects", -> assert isFinite $.hash Object.create null
	describe "the order of elements matters", ->
		it "in arrays", -> assert.notEqual $.hash(["a","b"]), $.hash(["b","a"])
		it "in blings", -> assert.notEqual $.hash($(["a","b"])), $.hash $(["b","a"])
	describe "overflow does not cause collisions", ->
		it "in arrays", -> assert.notEqual $.hash([1,2,3,0]), $.hash([1,2,3,99])
		it "in blings", -> assert.notEqual $.hash($(1,2,3,0)), $.hash(1,2,3,99)
		it "in objects", -> assert.notEqual $.hash({a:1,b:[1,2,3,0]}), $.hash({a:1,b:[1,2,3,99]})
