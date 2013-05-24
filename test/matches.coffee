[$, assert] = require './setup'

describe ".matches()", ->
	it "compares an object against a pattern object", ->
		assert $.matches { a: 1 }, { a: 1 }
	it "properly fails to match", ->
		assert.equal false, $.matches { a: /oo$/ }, { a: "bar" }
	describe "patterns can be", ->
		it "strings", ->
			assert $.matches { a: "foo" }, { a: "foo" }
		it "strings (negative)", ->
			assert.equal false, $.matches { a: "foo" }, { a: "bar" }
		it "numbers", ->
			assert $.matches { a: 42 }, { a: 42 }
		it "numbers (negative)", ->
			assert.equal false, $.matches { a: 42 }, { a: 43 }
		it "regexes", ->
			assert $.matches { a: /oo$/ }, { a: "foo" }
		it "regexes (negative)", ->
			assert.equal false, $.matches { a: /oo$/ }, { a: "bar" }
		it "arrays", ->
			assert $.matches [1,2,3], [1,2,3,4]
		it "undefined", ->
			assert $.matches undefined, undefined
		it "undefined (nested)", ->
			assert $.matches [1,undefined], [1]
		it "undefined (nested negative)", ->
			assert.equal false, $.matches [1,undefined], [1,2]
		it "matches.Any", ->
			assert $.matches $.matches.Any, undefined
			assert $.matches $.matches.Any, 42 
			assert $.matches $.matches.Any, 'string'
			assert $.matches [1, $.matches.Any, 3], [1, 2, 3]
		it "nested", ->
			assert $.matches {a: { b: 42 }}, {a: { b: 42 }}
		it "nested (negative)", ->
			assert.equal false, $.matches {a: { b: 42 }}, {a: { b: 43 }}
		it "partial nesting", ->
			assert $.matches { a: { b: /oo$/ } },
				{ a: { b: "foo", c: { d: "bar" } } }
		it "partial nesting (negative)", ->
			assert.equal false, $.matches { a: { b: /oo$/ } },
				{ a: { b: "bar", c: { d: "foo" } } }
		it "deep nesting", ->
			assert $.matches { a: { c: { d: /^b/ } } },
				{ a: { b: "foo", c: { d: "bar" } } }
		it "deep nesting (negative)", ->
			assert.equal false, $.matches { a: { c: { d: /^b/ } } },
				{ a: { b: "bar", c: { d: "foo" } } }
	it "what happens when patterns are an array", ->
		assert $.matches [1,2,3], [1,2,3,4]
	it "fallbacks to basic comparisons if you dont pass a pattern", ->
		it "(strings)", ->
			assert $.matches "a", "a"
		it "(numbers)", ->
			assert $.matches 42, 42
		it "(regexp)", ->
			assert $.matches /\d+/, "42"
