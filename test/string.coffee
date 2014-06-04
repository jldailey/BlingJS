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
	describe ".stringReverse(s)", ->
		it "should reverse s", ->
			assert.equal $.stringReverse("abcd"), "dcba"
	describe ".checkSum()", ->
		it "should compute the same hash as adler32", ->
			assert.equal $.checksum("foobar"), 145425018
			assert.equal $.checksum("foobarbaz"), 310051767
	describe ".toString()", ->
		describe "should output", ->
			it "blings", ->
				assert.equal $([2,3,4]).toString(), "$([2, 3, 4])"
			it "functions (without the code body)", ->
				assert.equal $.toString(-> $.log), "function () { ... }"
			it "objects", ->assert.equal $.toString({a:{b:1}}), "{a:{b:1}}"
			it "null", -> assert.equal $.toString(null), "null"
			it "undefined", -> assert.equal $.toString(undefined), "undefined"
		it "should not fail", ->
			obj = a: 1
			$.defineProperty obj, 'xxx',
				get: -> throw new Error "forbidden"
			assert.equal $.toString(obj), "{a:1, xxx:[Error: forbidden]}"
	describe ".toRepr()", ->
		describe "should produce code-parseable output for", ->
			it "blings", ->
				assert.equal $([2,3,4]).toRepr(), "$([2, 3, 4])"
				assert.equal $([{a:1},[],"Hello"]).toRepr(), "$([{\"a\": 1}, [], 'Hello'])"
			describe "strings", ->
				it "with no single quotes inside",   -> assert.equal $.toRepr("a"), "'a'"
				it "with single quotes inside",      -> assert.equal $.toRepr("a 'fine' day"), "'a \\'fine\\' day'"
				it "with pre-escaped single quotes", -> assert.equal $.toRepr("a \\'fine\\' day"), "'a \\'fine\\' day'"
				it "multi-line strings",             -> assert.equal $.toRepr("a fine\n day"), "'a fine\n day'"
			it "numbers", ->
				assert.equal $.toRepr(-54.32), "-54.32"
				assert.equal $.toRepr(Infinity), "Infinity"
				assert.equal $.toRepr(NaN), "NaN"
			it "nulls", ->
				assert.equal $([null]).toRepr(), "$([null])"
				assert.equal $([undefined]).toRepr(), "$([undefined])"
			it "functions", ->
				assert.equal $([(x) -> x + "a"]).toRepr().replace(/\n\s+/g,' '), '$([function (x) { return x + "a"; }])'
			it "objects", ->
				assert.equal $.toRepr([{a:1, b:"s", c: [1,2,3]}]), """[{"a": 1, "b": 's', "c": [1, 2, 3]}]"""
			it "arrays", ->
				assert.equal $.toRepr([["a",2,3]]), "[['a', 2, 3]]"
			it "arguments", ->
				assert.equal (-> $.toRepr arguments)(1,2,3), "[1, 2, 3]"
			it "should not fail", ->
				obj = a: 1
				$.defineProperty obj, 'xxx',
					get: -> throw new Error "kinjiru!"
				assert.equal $.toRepr(obj), """{"a": 1, "xxx": '[Error: kinjiru!]'}"""

	describe ".stringTruncate(string, len)", ->
		it "should truncate long strings and add ellipses", ->
			assert.equal ($.stringTruncate "long string", 6), "long..."
		it "should try to keep words whole", ->
			assert.equal ($.stringTruncate "super long string", 10), "super long..."
		it "doesnt count spaces toward final length", ->
			assert.equal ($.stringTruncate "super long string", 9), "super long..."
	describe ".camelize", ->
		it "converts dash-case to camelCase", ->
			assert.equal $.camelize("foo-bar"), "fooBar"
		it "converts all dashed letter to captials", ->
			assert.equal $.camelize("-foo-bar"), "FooBar"
		it "cleans deviant input with slugize", ->
			assert.equal $.camelize(undefined), ""
			assert.equal $.camelize(null), ""
			assert.equal $.camelize([ {a:1}, {b:2} ]), "a1B2"
	describe ".commaize", ->
		it "adds comma to long numbers", ->
			assert.equal $.commaize(1004023), "1,004,023"
		it "works with floating point numbers", ->
			assert.equal $.commaize(4267.5398), "4,267.5398"
		it "works with really long numbers", ->
			assert.equal $.commaize(1234567890), "1,234,567,890"
		it "works with really short numbers", ->
			assert.equal $.commaize(0), "0"
		it "works with negative numbers", ->
			assert.equal $.commaize(-1234.56), "-1,234.56"
		it "can be given the seperator", ->
			assert.equal $.commaize(123456, '.'), "123.456"
		it "can be given the seperator and decimal", ->
			assert.equal $.commaize(-1234.56, '.', ','), "-1.234,56"
		it "ignores non-numbers", ->
			assert.equal $.commaize(NaN), "NaN"
			assert.equal $.commaize(Infinity), "Infinity"
			assert.equal $.commaize({ a: 1 }), undefined
		describe "currency", ->
			it "is optional", ->
				assert.equal $.commaize(1000, null, null, "$"), "$1,000"
			it "supports negative amounts", ->
				assert.equal $.commaize(-1000, null, null, "$"), "-$1,000"
	describe ".slugize", ->
		it "converts a phrase to a slug", ->
			assert.equal $.slugize("foo bar"), "foo-bar"
			assert.equal $.slugize(" foo bar "), "foo-bar"
		it "strips special characters", ->
			assert.equal $.slugize("\x01foo bar\n"), "foo-bar"
		it "lowercases everything", ->
			assert.equal $.slugize("FOob ARR"), "foob-arr"
		describe "handles", ->
			it "empty strings", ->
				assert.equal $.slugize(""), ""
			it "junk", ->
				assert.equal $.slugize(undefined), ""
				assert.equal $.slugize(null), ""
			it "numbers", ->
				assert.equal $.slugize(1234.56), "1234.56"
			it "objects", ->
				assert.equal $.slugize({ a: 1 }), "a-1"
			it "arrays", ->
				assert.equal $.slugize([ {a:1}, {b:2} ]), "a-1-b-2"
	describe ".dashize", ->
		it "converts camelCase to dash-case", ->
			assert.equal $.dashize("fooBar"), "foo-bar"
		it "all capital letters get dashed", ->
			assert.equal $.dashize("FooBar"), "-foo-bar"
		it "already dashed words get left alone", ->
			assert.equal $.dashize("foo-bar"), "foo-bar"
	describe "::replace(regex,repl)", ->
		it "maps replace over a set of strings", ->
			assert.deepEqual $(["abc","bbc","cbc"]).replace(/bc$/,''), ['a','b','c']

	describe "::indexOf(regex,offset=0)", ->
		b = $(["abc", "bbc", "cbc", "bbd"])
		it "adds regex support over Array::indexOf", ->
			assert.equal 1, b.indexOf(/^bb/)
		it "supports an offset", ->
			assert.equal 3, b.indexOf(/^bb/, 2)
