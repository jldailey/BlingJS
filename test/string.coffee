[$, assert] = require './setup'

describe "String plugin:", ->
	describe ".px()", ->
		describe "converts ... to pixel strings", ->
			it "integers", -> assert.equal $.px(100), "100px"
			it "floats", -> assert.equal $.px(-100.1), "-100px"
			it "negatives", -> assert.equal $.px(-100.2), "-100px"
			it "pixel strings", -> assert.equal $.px("100.0px"), "100px"
		describe "adjusts by a delta while converting", ->
			it "with a number delta", ->
				assert.equal "20px", $.px("10px", 10)
			it "with a px delta", ->
				assert.equal "20px", $.px("10px", "10px")
			it "with NaN", ->
				assert.equal "10px", $.px("10px", NaN)
			it "with Infinity", ->
				assert.equal "10px", $.px("10px", Infinity)
			it "with null", ->
				assert.equal "10px", $.px("10px", null)
	describe ".repeat(x, n)", ->
		it "can repeat strings", ->
			assert.equal $.repeat("abc", 3), "abcabcabc"
		it "does not crash with large N", ->
			assert.equal $.repeat("a", 99999).length, 99999
		it "can repeat objects", ->
			assert.deepEqual $.repeat({a:1}, 3),
				[ {a:1}, {a:1}, {a:1} ]
	describe ".padLeft()", ->
		it "adds padding when needed", ->
			assert.equal $.padLeft("foo", 5), "  foo"
		it "does not add padding when not needed", ->
			assert.equal $.padLeft("foo", 2), "foo"
		it "does not add padding when barely not needed", ->
			assert.equal $.padLeft("foo", 3), "foo"
		it "can pad with non-default character", ->
			assert.equal $.padLeft("foo", 5, "X"), "XXfoo"
	describe ".padRight()", ->
		it "adds padding when needed", -> assert.equal $.padRight("foo", 5), "foo  "
		it "doesnt when not", -> assert.equal $.padRight("foo", 2), "foo"
		it "doesnt when not", -> assert.equal $.padRight("foo", 3), "foo"
		it "can pad with non-default character", -> assert.equal $.padRight("foo", 5, "X"), "fooXX"
	describe ".stringSplice()", ->
		it "should insert text", ->
			assert.equal $.stringSplice("foobar",3,3,"baz"), "foobazbar"
		it "should partially replace text", ->
			assert.equal $.stringSplice("foobar",1,5,"baz"), "fbazr"
		it "should completely replace text", ->
			assert.equal $.stringSplice("foobar",0,6,"baz"), "baz"
		it "should prepend text", ->
			assert.equal $.stringSplice("foobar",0,0,"baz"), "bazfoobar"
	describe ".checkSum()", ->
		it "should compute the same hash as adler32", ->
			assert.equal $.checksum("foobar"), 145425018
		it "should not just hash the one thing", ->
			assert.equal $.checksum("foobarbaz"), 310051767
	describe ".toString()", ->
		describe "should output", ->
			it "blings", ->
				assert.equal $([2,3,4]).toString(), "$([2, 3, 4])"
			it "functions", ->
				assert.equal $.toString(-> $.log), "function () { ... }"
			it "objects", ->assert.equal $.toString({a:{b:1}}), "{a:{b:1}}"
			it "null", -> assert.equal $.toString(null), "null"
			it "undefined", -> assert.equal $.toString(undefined), "undefined"
		it "should not fail", ->
			obj = a: 1
			$.defineProperty obj, 'xxx',
				get: -> throw new Error "forbidden"
			assert.equal $.toString(obj), "{a:1, xxx:[Error: forbidden]}"
	describe ".stringTruncate()", ->
		it "should truncate long strings and add ellipses", ->
			assert.equal ($.stringTruncate "long string", 6), "long..."
	describe ".camelize", ->
		it "converts dash-case to camelCase", ->
			assert.equal $.camelize("foo-bar"), "fooBar"
		it "converts all dashed letter to captials", ->
			assert.equal $.camelize("-foo-bar"), "FooBar"
	describe ".slugize", ->
		it "converts a phrase to a slug", ->
			assert.equal $.slugize("foo bar"), "foo-bar"
			assert.equal $.slugize(" foo bar "), "foo-bar"
		it "strips special characters", ->
			assert.equal $.slugize("\x01foo bar\n"), "foo-bar"
	describe ".dashize", ->
		it "converts camelCase to dash-case", ->
			assert.equal $.dashize("fooBar"), "foo-bar"
		it "all capital letters get dashed", ->
			assert.equal $.dashize("FooBar"), "-foo-bar"
	describe "::replace", ->
		it "maps replace over a set of strings", ->
			assert.deepEqual $(["abc","bbc","cbc"]).replace(/bc$/,''),
				['a','b','c']
