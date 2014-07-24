[$, assert] = require './setup'

describe "Functions plugin:", ->
	describe ".identity()", ->
		it "should be a function", -> assert $.is "function", $.identity
		it "should echo anything", -> assert.equal $.identity(a = {}), a

	describe ".bound()", ->
		f = -> @value
		a = value:'a'
		b = value:'b'
		it "binding to a should return a's value", ->
			assert.equal do $.bound(a, f), 'a'
		it "binding to b should return b's value", ->
			assert.equal do $.bound(b, f), 'b'

	describe ".call()", ->
		it "calls every function in the set", ->
			assert.deepEqual $([((x) -> x*2), ((x) -> x*x)]).call(4), [8, 16]
		it "skips non-functions", ->
			assert.deepEqual $([((x) -> x*2), NaN, ((x) -> x*x)]).call(4), [8, 16]

	describe ".apply()", ->
		it "calls every function in the set, with a specific context", ->
			assert.deepEqual($([((x) -> @+x), ((x) -> @*x)]).apply(4,[2]), [6, 8])

	describe ".partial()", ->
		it "partially applies every function in the set", ->
			b = $([
				(a,b) -> a+b
				(a,b) -> a-b
				(a,b) -> a*b
				(a,b) -> a/b
			])
			assert.deepEqual b.partial(4).call(2), [6,2,8,2]
		it "has a global version", ->
			f = $.partial ((a,b) -> a+b), 2
			assert.equal f(4), 6

	describe ".toRepr()", ->
		assert.equal $.toRepr(-> "Hello"), 'function () {\n        return "Hello";\n      }'
		describe "nested", ->
			assert.equal $.toRepr( {
				a: { b: "c" }
				d: { f: -> "e" }
			} ), '{"a": {"b": \'c\'}, "d": {"f": function () {\n              return \"e\";\n            }}}'

