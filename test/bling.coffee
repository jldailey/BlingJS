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
	it "can be created from CSS selector", ->
		assert.equal $("td").length, 8
	it "can be created from an arguments object", ->
		f = -> Bling(arguments)
		assert.equal $.type(f(1,2,3)), "bling"
		assert.equal f(1,2,3).length, 3
		assert.deepEqual f(1,2,3), [1,2,3]

	describe ".type()", ->
		describe "should classify", ->
			it "'string'", -> assert.equal $.type(''), 'string'
			it "'number'", -> assert.equal $.type(42), 'number'
			it "'undefined'", -> assert.equal $.type(), "undefined"
			it "'null'", -> assert.equal $.type(null), "null"
			it "'array'", -> assert.equal $.type([]), "array"
			it "'function'", -> assert.equal $.type(->), "function"
			it "'bool'", -> assert.equal $.type(true), "bool"
			it "'regexp'", -> assert.equal $.type(//), "regexp"
			it "'window'", -> assert.equal $.type(window), "global"
			it "'arguments'", -> assert.equal $.type(arguments), "arguments"

	describe ".is()", ->
		describe "should identify", ->
			it "'string'", -> assert $.is 'string', ''
			it "'number'", -> assert $.is 'number', 42
			it "'undefined'", -> assert.equal $.type(), "undefined"
			it "'null'", -> assert $.is "null", null
			it "'array'", -> assert $.is "array", []
			it "'function'", -> assert $.is "function", ->
			it "'bool'", -> assert $.is "bool", true
			it "'regexp'", -> assert $.is "regexp", /^$/
			it "'window'", -> assert $.is "global", window
			it "'arguments'", -> assert $.is "arguments", arguments

	describe ".inherit(a,b)", ->
		a = a: 1
		b = b: 2
		$.inherit a, b
		it "should set b's __proto__ to a", ->
			assert.equal b.__proto__, a
		it "b should inherit properties from a", ->
			assert.equal b.a, 1
		it "but b should not own those properties", ->
			assert not b.hasOwnProperty "a"

	describe ".extend(a,b)", ->
		a = a: 1
		b = b: 2
		c = $.extend a, b
		it "should return the modified a", -> assert.equal c, a
		it "should give a properties from b", -> assert.equal a.b, 2
		it "should copy those properties", ->
			a.b = 3
			assert.equal b.b, 2
		it "can extend many b's at once", ->
			d = d: 1
			$.extend d, { e: 2 }, { f: 3 }
			assert.equal d.e, 2
			assert.equal d.f, 3

	describe ".defineProperty()", ->
		describe "getters", ->
			a = {}
			$.defineProperty a, "getter",
				get: -> 2
			it "should be readable", ->
				assert.equal a.getter, 2
			it "should not be settable", ->
				a.getter = 3
				assert.equal a.getter, 2
			it "should be enumerable", ->
				assert.notEqual -1, Object.keys(a).indexOf("getter")
			it "should be configurable"
		describe "setters", ->
			a = {}
			$.defineProperty a, "setter",
				set: (v) ->
			it "should be settable", ->
				a.setter = 10
			it "should not be gettable", ->
				assert.equal a.setter, undefined
			it "should be enumerable", ->
				assert.notEqual -1, Object.keys(a).indexOf("setter")

	describe ".isType()", ->
		it "should compare against actual types", ->
			assert $.isType Array, []
		it "or against names of constructors", ->
			assert( $.isType('Array', []) )
		it "should work on non-builtin types", ->
			class Foo
			f = new Foo()
			assert $.isType Foo, f

	describe ".isSimple()", ->
		describe "should accept", ->
			it "strings", -> assert $.isSimple ""
			it "numbers", -> assert $.isSimple 42.0
			it "bools", -> assert( $.isSimple false )
		describe "should reject", ->
			it "objects", -> assert not $.isSimple {}
			it "arrays", -> assert not $.isSimple []

	describe ".isEmpty()", ->
		describe "should accept", ->
			it "empty strings", -> assert $.isEmpty ""
			it "nulls", -> assert $.isEmpty null
			it "undefineds", -> assert $.isEmpty undefined
			it "empty arrays", -> assert $.isEmpty []
			it "empty objects", -> assert $.isEmpty {}
		describe "should reject", ->
			it "full strings", -> assert not $.isEmpty "abc"
			it "arrays with items", -> assert not $.isEmpty [1,2,3]
			it "objects with keys", -> assert not $.isEmpty a:1

	describe ".toArray()", ->
		a = $([1,2,3])
		b = a.toArray()
		it "should produce an Array", ->
			assert.equal b.constructor.name, "Array"
		it "should preserve data", ->
			assert.equal b[1], 2
		it "should preserve length", ->
			assert.equal b.length, 3
		it "should not preserve bling functions", ->
			assert not b.zap

	describe ".as()", ->
		describe "should convert", ->
			it "strings to numbers", -> assert.equal ($.as "number", "1234"), 1234

	describe ".identity", ->
		it "should be a function", -> assert $.is "function", $.identity
		it "should echo anything", -> assert.equal $.identity(a = {}), a

	describe ".bound", ->
		f = -> @value
		a = value:'a'
		b = value:'b'
		it "binding to a should return a's value", ->
			assert.equal do $.bound(a, f), 'a'
		it "binding to b should return b's value", ->
			assert.equal do $.bound(b, f), 'b'

	describe "$.log", ->
		describe ".out", ->
			it "defaults to console.log", ->
				assert.equal $.log.out, console.log
			it "is called by $.log", ->
				try
					pass = false
					$.log.out = (arg) -> pass = arg
					$.log true
					assert pass
				finally
					$.log.out = console.log

	describe "$.logger", ->
		it "creates a logger with a fixed prefix", ->
			f = $.logger('[magic]')
			message = ""
			try
				$.log.out = (a...) -> message = a.join " "
				f "message"
				assert message.indexOf("[magic] message") > -1
			finally
				$.log.out = console.log

	describe ".trace", ->
		f = -> 42
		g = [] # an output buffer
		h = $.trace "label", f, (a...) ->
			g.push a.join ''
		it "should not trace the original function", ->
			f()
		it "should trace the returned function", ->
			h "one", "two" # but this will
			assert /global\.label\('one','two'\): \d+ms/.test g[0]
	
	describe ".time", ->
		f = -> 42
		pass = false
		it "reports execution time", ->
			$.time f, (m) ->
				assert.equal m, "[trace] 0ms"
				pass = true
			assert pass, "logger must be called"
		it "accepts an optional prefix", ->
			$.time "LABEL", f, (m) -> assert /\[LABEL\] \dms/.test m
		it "return the value that f returns", ->
			assert.equal $.time( (->42), (->) ), 42

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

	describe ".random()", ->
		assert 0.0 < $.random() < 1.0
		describe ".real()", ->
			r = $.random.real 10,100
			it "should produce a number", ->
				assert $.is 'number', r
			it "is in the range", ->
				assert 10.0 < r < 100.0
		describe ".integer()", ->
			r = $.random.integer(3,9)
			it "should be an integer", ->
				assert.equal Math.floor(r), r
			it "is in the range", ->
				assert 3 <= r <= 9
		describe ".string()", ->
			s = $.random.string(16)
			it "is a string", ->
				assert $.is 'string', s
			it "has the right length", ->
				assert.equal s.length, 16
		describe ".seed()", ->
			$.random.seed = 42
			r = $.random.string(16)
			$.random.seed = 43
			s = $.random.string(16)
			$.random.seed = 42
			t = $.random.string(16)
			it "should produce same output for the same seed", ->
				assert.equal r, t
			it "should produce different output for a new seed", ->
				assert.notEqual r, s
		describe ".dice()", ->
			it "rolls multiple dice", ->
				for i in [0...100]
					roll = $.random.dice(2,8)
					assert $.is 'bling', roll
					assert.equal roll.length, 2
					for r in roll
						assert 1 <= r <= 8
		describe ".die()", ->
			it "rolls one die", ->
				for i in [0...100]
					assert 0 < $.random.die(6) < 7
		describe ".element()", ->
			it "chooses a random element", ->
				sum = 0
				elems = [1,2,3]
				e = $.random.element elems
				assert e in elems
				elems = [0,1]
				for i in [0..1000]
					sum += $.random.element elems
				assert Math.abs(sum - 500) < 50
			it "accepts weights", ->
				sum = 0
				elems = [0,1]
				weights = [6,4]
				for i in [0..1000]
					sum += $.random.element elems, weights
				assert Math.abs(sum - 400) < 50

	describe ".hash()", ->
		describe "hashes any type of object", ->
			it "number", -> assert $.hash(42) isnt $.hash(43)
			it "string", -> assert $.hash("foo") isnt $.hash("bar")
			it "array", -> assert $.hash("poop") isnt $.hash(["poop"])
			it "object", -> assert ($.hash a:1) isnt ($.hash a:2)
			it "bling", -> assert ($.hash $)?
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

	describe ".hook()", ->
		it "is a function", ->
			assert $.is 'function', $.hook
		it "returns a hook with append/prepend", ->
			p = $.hook()
			assert $.is 'function', p.append
			assert $.is 'function', p.prepend
		it "returns a function", ->
			p = $.hook()
			assert $.is 'function', p
		it "computes values when called", ->
			hook = $.hook()
			hook.append (x) -> x + 2
			hook.prepend (x) -> x * 2
			assert.equal hook(4), 10

	describe "functions", ->
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
			assert.equal $.toRepr(-> "Hello"), 'function () {\n          return "Hello";\n        }'
			describe "nested", ->
				assert.equal $.toRepr( {
					a: { b: "c" }
					d: { f: -> "e" }
				} ), "{a:{b:'c'}, d:{f:function () {\n                return \"e\";\n              }}}"

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

	describe ".date", ->
		it "adds the 'date' type", ->
			assert $.is 'date', new Date(0)
		describe 'converts', ->
			it "date to string", ->
				assert.equal ($.as "string", new Date 1,2,3,4,5,6), "1901-03-03 09:05:06"
			it "string to date", ->
				assert.equal ($.as "date", "1901-03-03 09:05:06").toString(), new Date(1,2,3,4,5,6).toString()
			it "date to number", ->
				assert.equal ($.as "number", new Date 1,2,3,4,5,6), -2172149694
			it "number to date", ->
				assert.equal ($.as "date", -2172149694).toString(), (new Date 1,2,3,4,5,6).toString()
		describe ".stamp()", ->
			describe "converts date objects to numbers (with units)", ->
				it "ms", -> assert $.date.stamp(new Date(1000000), "ms") is 1000000
				it "seconds", -> assert $.date.stamp(new Date(1000000), "s") is 1000
		describe ".unstamp()", ->
			it "converts a number to a real date", ->
				assert $.is 'date', $.date.unstamp 0
			it "is the reverse of stamp", ->
				d1 = new Date(1000000)
				d2 = $.date.unstamp $.date.stamp d1
				assert d1.toString() is d2.toString()
			it "supports chaining as .unstamp()", ->
				assert $.is 'date', $([1000000]).unstamp().first()
		describe ".convert()", ->
			assert $.date.convert(1000000, "ms", "s") is 1000
		describe ".midnight()", ->
			it "returns a stamp", ->
				assert $.is 'number', $.date.midnight new Date 0
			it "shifts a date to midnight of that day", ->
				assert.notEqual -1, $.date.unstamp($.date.midnight new Date 1000000000).toUTCString().indexOf("00:00:00 GMT")
			it "supports chaining", ->
				assert.equal $($.date.range 1000, 1000000, 3)
					.midnight()
					.dateFormat("HHMMSS")
					.ints().sum(), 0
		describe ".format()", ->
			d1 = new Date(1000000000)
			describe "supports fields", ->
				it "yyyy", -> assert.equal $.date.format(d1, "yyyy"), "1970"
				it "mm", -> assert.equal $.date.format(d1, "mm"), "01"
				it "dd", -> assert.equal $.date.format(d1, "dd"), "12"
				it "HH", -> assert.equal $.date.format(d1, "HH"), "13"
				it "MM", -> assert.equal $.date.format(d1, "MM"), "46"
				it "SS", -> assert.equal $.date.format(d1, "SS"), "40"
			it "supports spacing and punctuation", ->
				assert.equal $.date.format(d1, "yyyy-mm-dd HH:MM:SS"), "1970-01-12 13:46:40"
			it "supports chaining as .dateFormat()", ->
				assert.equal $($.date.range 1000, 1000000, 3)
					.dateFormat("dd")
					.ints().sum(), 35
		describe ".parse()", ->
			it "supports the same formats as .format()", ->
				assert $.date.parse("1970-01-12 13:46:40", "yyyy-mm-dd HH:MM:SS", "ms") is 1000000000
			it "supports chaining as .dateParse()", ->
				assert $(["1970-01-12 13:46:40"]).dateParse("yyyy-mm-dd HH:MM:SS", "ms").first() is 1000000000
		describe ".range()", ->
			it "generates a range of date stamps", ->
				assert.equal $($.date.range(1000, 1000000, 3))
					.unstamp()
					.select("getUTCDate").call()
					.ints().sum(), 35 # == 1 + 4 + 7 + 10 + 13 (every 3 days from Jan 1 1970 for 2 weeks)

	describe ".config(name, def)", ->
		it "gets config from the environment", ->
			try
				process.env.UNIT_TEST_MAGIC = "magic"
				assert.equal $.config.get("UNIT_TEST_MAGIC"), "magic"
			finally
				delete process.env.UNIT_TEST_MAGIC
		it "supports a default value", ->
			assert.equal $.config.get("NOT_FOUND", "default"), "default"
		it "can be called directly", ->
			assert.equal $.config("NOT_FOUND", "default"), "default"
		it "can parse and set values from string data", ->
			assert.deepEqual $.config.parse("""NO_LEAD='no leading whitespace'
				LEADING='ignores leading whitespace'
				NOQUOTES=does not require any quotes
			"""), {
					NO_LEAD: "no leading whitespace"
					LEADING: "ignores leading whitespace"
					NOQUOTES: "does not require any quotes"
				}

	describe ".index(keyMaker)", ->
		keyMaker = (obj) -> obj.a
		it "creates a private index", ->
			$([{a:1,b:2}, {a:2,b:3}]).index keyMaker
		it "cannot query until index has been built", ->
			assert.equal $([1,2,3]).query(a:1), null
		it "can .query() after indexing", ->
			a = $([{a:1,b:'b'},{a:2},{a:3}]).index keyMaker
			assert.equal a.query(a:1).b, 'b'
		it "can use compound keys", ->
			compoundKeyMaker = (obj) -> obj.a + "-" + obj.b
			a = $([{a:1,b:'b'},{a:2,b:1},{a:3,b:2,c:'c'}]).index compoundKeyMaker
			assert.equal a.query(a:3,b:2).c, 'c'
		describe "using more than one key maker", ->
			keyMakerOne = (obj) -> obj.a
			keyMakerTwo = (obj) -> obj.b
			keyMakerThree = (obj) -> obj.a + '-' + obj.b
			a = $([{a:1,b:'b'},{a:2,b:1},{a:3,b:2,c:'c'}])
			it "wont hurt if you re-index by the same keyMaker", ->
				a.index keyMakerOne
				a.index keyMakerOne
				assert.equal a.query(a:3).b, 2
			it "will allow querying against a second keyMaker", ->
				a.index keyMakerTwo
				assert.equal a.query(a:3).b, 2
				assert.equal a.query(b:2).a, 3
			it "will allow querying against N keyMakers", ->
				a.index keyMakerOne
				a.index keyMakerTwo
				a.index keyMakerThree
				assert.equal a.query(a:3).b, 2
				assert.equal a.query(b:'b').a, 1
				assert.equal a.query({a:3,b:2}).c, 'c'
	
	describe ".groupBy(key)", ->
		objs = $([
			{name: "a", k: 1, val: 1},
			{name: "a", k: 1, val: 2},
			{name: "a", k: 2, val: 3},
			{name: "b", k: 1, val: 4},
			{name: "c", k: 1, val: 5},
			{ val: 6 }

		])
		it "groups objects by the key", ->
			assert.deepEqual objs.groupBy('name'), [
				[ {name: "a", k:1, val: 1},
					{name: "a", k:1, val: 2},
					{name: "a", k:2, val: 3} ],
				[ {name: "b", k:1, val: 4} ],
				[ {name: "c", k:1, val: 5} ],
				[ { val: 6 } ]
			]
		it "can group by multiple keys", ->
			assert.deepEqual objs.groupBy(['name','k']), [
				[ {name: "a", k:1, val: 1},
					{name: "a", k:1, val: 2}
				],
				[ {name: "a", k:2, val: 3} ], # this 'a' gets its own group
				[ {name: "b", k:1, val: 4} ],
				[ {name: "c", k:1, val: 5} ],
				[ { val: 6 } ]
			]

		it "is mappable", ->
			assert.deepEqual objs.groupBy('name').map(-> @select('val').sum()),
				[ 6, 4, 5, 6 ]

		it "is mappable to a new object", ->
			assert.deepEqual objs.groupBy(['name','k']).map(->
				name: @select('name').first()
				sum: @select('val').sum()
				k: @select('k').first()
			),
				[ { name: "a", sum: 3, k:1 },
					{ name: "a", sum: 3, k:2 },
				  { name: "b", sum: 4, k:1 },
					{ name: "c", sum: 5, k:1 }
					{ name: undefined, sum: 6, k:undefined }
				]
	
	describe "$.sortedIndex()", ->
		it "returns the index to insert at", ->
			assert.equal $.sortedIndex([1,2,4], 3), 2
		it "will insert at end", ->
			assert.equal $.sortedIndex([1,2,3], 4), 3
		it "will insert at beginning", ->
			assert.equal $.sortedIndex([2,3,4], 1), 0
		it "can use a field for comparison", ->
			assert.equal $.sortedIndex([{a:1},{a:2},{a:4}], {a:3}, 'a'), 2
		it "can use a comparison function", ->
			assert.equal $.sortedIndex([1,2,4], 3, null, (x)->Math.pow(x,2)), 2

	describe ".sortBy(field,cmp)", ->
		it "can sort", ->
			assert.deepEqual $(3,1,2).sortBy(), [1,2,3]
		it "can sort by a field", ->
			assert.deepEqual $( {a:2}, {a:1}, {a:3} ).sortBy('a').select('a'), [1,2,3]
		it "does NOT sort in-place", ->
			a = $(2,3,1)
			b = a.sortBy()
			assert.deepEqual b, [1,2,3]
			assert a isnt b
		it "sorts strings correctly", ->
			assert.deepEqual $(
				{ code: "a" },
				{ code: "c" },
				{ code: "b" }
			).sortBy('code').select('code'), ["a","b","c"]
		it "can do complex sorts (such as case-less)", ->
			assert.deepEqual $(
				{ code: "a" },
				{ code: "c" },
				{ code: "B" }
			).sortBy((item)-> item.code.toLowerCase()).select('code'), ["a","B","c"]
	
	describe ".sortedInsert(item,iterator)", ->
		it "inserts in sorted order", ->
			assert.deepEqual $(1,2,4).sortedInsert(3), [1,2,3,4]
		it "can be chained", ->
			assert.deepEqual $().sortedInsert(3).sortedInsert(1).sortedInsert(2), [1,2,3]
		it "works on fields", ->
			assert.deepEqual $().sortedInsert({x:1,y:2}, 'y').sortedInsert({x:2,y:1}, 'y'), [{x:2,y:1},{x:1,y:2}]
	
	describe ".histogram(data)", ->
		it "draws a histogram", ->
			assert $.is 'string', $.histogram( [1,2,3,4,5] )
		it "can get real", ->
			assert $.is 'string', $.histogram $.ones(1000).map(-> $.random.gaussian .65, .07), .01
	
	describe ".repeat(x, n)", ->
		it "can repeat strings", ->
			assert.equal $.repeat("abc", 3), "abcabcabc"
		it "does not crash with large N", ->
			assert.equal $.repeat("a", 99999).length, 99999
		it "can repeat objects", ->
			assert.deepEqual $.repeat({a:1}, 3),
				[ {a:1}, {a:1}, {a:1} ]
	
	describe ".units", ->
		$.units.enable()
		it "handles strings with unit-suffixed numbers", ->
			assert.equal $.type("34px"), "units"
		it "does not handle strings with numbers alone", ->
			assert.notEqual $.type("34"), "units"
		it "converts between units", ->
			assert.equal $.units.convertTo('cm', '300in'), "762cm"
		it "can find non-trivial conversions through inferrence", ->
			assert.equal $.units.convertTo('px', '.1yd'), "345.58313554298553px"
		it "simply adds a unit to un-suffixed numbers", ->
			assert.equal $.units.convertTo('px', '10.1'), '10.1px'
		it "does not crash on bad numbers", ->
			assert not isFinite $.units.convertTo('px', Infinity)
			assert not isFinite $.units.convertTo('px', NaN)
		it "can convert compound units like m/s", ->
			assert.equal $.units.convertTo("px/ms", "42in/s"), "4.032px/ms"
	
	describe ".matches()", ->
		it "compares an object against a pattern object", ->
			assert $.matches { a: 1 }, { a: 1 }
		it "properly fails to match", ->
			assert.equal false, $.matches { a: /oo$/ }, { a: "bar" }
		describe "patterns can be", ->
			it "strings", ->
				assert $.matches { a: "foo" }, { a: "foo" }
			it "strings (false)", ->
				assert.equal false, $.matches { a: "foo" }, { a: "bar" }
			it "numbers", ->
				assert $.matches { a: 42 }, { a: 42 }
			it "numbers (false)", ->
				assert.equal false, $.matches { a: 42 }, { a: 43 }
			it "regexes", ->
				assert $.matches { a: /oo$/ }, { a: "foo" }
			it "regexes (false)", ->
				assert.equal false, $.matches { a: /oo$/ }, { a: "bar" }
			it "nested", ->
				assert $.matches {a: { b: 42 }}, {a: { b: 42 }}
			it "nested (false)", ->
				assert.equal false, $.matches {a: { b: 42 }}, {a: { b: 43 }}
			it "partial nesting", ->
				assert $.matches { a: { b: /oo$/ } },
					{ a: { b: "foo", c: { d: "bar" } } }
			it "partial nesting (false)", ->
				assert.equal false, $.matches { a: { b: /oo$/ } },
					{ a: { b: "bar", c: { d: "foo" } } }
			it "deep nesting", ->
				assert $.matches { a: { c: { d: /^b/ } } },
					{ a: { b: "foo", c: { d: "bar" } } }
			it "deep nesting (false)", ->
				assert.equal false, $.matches { a: { c: { d: /^b/ } } },
					{ a: { b: "bar", c: { d: "foo" } } }


	describe "pubsub", ->
		it "defines $.Hub", ->
			assert typeof $.Hub is "function"
		it "puts a root Hub on $ itself", ->
			assert typeof $.publish is "function"
			assert typeof $.subscribe is "function"
		it "can create new Hubs", ->
			h = new $.Hub()
			assert typeof $.publish is "function"
			assert typeof $.subscribe is "function"
		it "implements the pubsub protocol", ->
			h = new $.Hub()
			pass = false
			h.subscribe 'test-channel', -> pass = true
			h.publish 'test-channel'
			assert pass
		it "passes along published data", ->
			h = new $.Hub()
			pass = false
			h.subscribe 'test-channel', (data) -> pass = data
			h.publish 'test-channel', true
			assert pass
		it "the root behaves like a global Hub", ->
			pass = false
			$.subscribe 'test-channel', (data) -> pass = data
			$.publish 'test-channel', true
			assert pass
		describe ".subscribe()", ->
			hub = new $.Hub()
			it "attaches basic listeners to a channel", ->
				pass = false
				hub.subscribe "chan", (data) -> pass = data
				hub.publish "chan", true
				assert pass
			it "accepts an optional pattern object", ->
				pass = 0
				hub.subscribe "chan", { op: /oo$/ }, (obj) ->
					pass += obj.data
				hub.publish "chan", { op: "bar", data: 1 }
				hub.publish "chan", { op: "foo", data: 2 }
				assert.equal pass, 2

		describe ".unsubscribe()", ->
			hub = new $.Hub()
			it "can unsub a single listener", ->
				f = ->
				hub.subscribe("chan", f)
				assert.deepEqual hub.listeners["chan"], [ f ]
				hub.unsubscribe("chan", f)
				assert.notEqual hub.listeners["chan"][0], f
			it "can unsub all listeners at once", ->
				hub.subscribe("chan", ->)
				hub.subscribe("chan", ->)
				assert.equal hub.listeners["chan"].length, 2
				hub.unsubscribe "chan"
				assert.equal hub.listeners["chan"].length, 0
	
	describe "async", ->
		it "defines series and parallel", ->
			assert 'series' of $::
			assert 'parallel' of $::
		describe ".series(cb)", ->
			it "calls all funcs in series", (done) ->
				$([
					(cb) -> $.delay 200, -> cb(1)
					(cb) -> $.delay 100, -> cb(2)
					(cb) -> $.delay 10, -> cb(3)
					(cb) -> $.immediate -> cb(4)
				]).series ->
					assert.deepEqual @flatten(), [1,2,3,4]
					done()
		describe ".paralell(cb)", ->
			it 'calls all funcs in parallel', (done) ->
				$([
					(cb) -> $.delay 200, -> cb(1)
					(cb) -> $.delay 100, -> cb(2)
					(cb) -> $.delay 10, -> cb(3)
					(cb) -> $.immediate -> cb(4)
				]).parallel ->
					assert.deepEqual @flatten(), [1,2,3,4]
					done()
	
	describe "RequestQueue", ->
		it "pushes throttled messages through a real requester", (done) ->
			# Make a mock requester
			count = 0
			requester = (opts, cb) ->
				assert opts.method is "POST"
				count += opts.index
				cb(false, opts.index)
			rq = new $.RequestQueue(requester)
			# Push 3 messages every 101ms
			rq.start 3, 101
			# Queue some messages (5 should take 202ms to send)
			for index in [0...5] by 1 then do (index) ->
				rq.post {index}, (err, data) ->
					assert.equal err, false
					assert.equal data, index
			# Stop in 250ms
			$.delay 250, ->
				rq.stop()
				assert.equal count, 10
				done()
	
	describe ".stringDistance()", ->
		it "equal strings are zero distance", ->
			assert.equal $.stringDistance("a","a"), 0
			assert.equal $.stringDistance("ab","ab"), 0
		it "inserts are one distance", ->
			assert.equal $.stringDistance('a','ab'), 1
		it "deletes are one distance", ->
			assert.equal $.stringDistance('ab', 'a'), 1
		it "replaces are one distance", ->
			assert.equal $.stringDistance('a','b'), 1
		it "can mix inserts/deletes/replaces", ->
			assert.equal $.stringDistance('Hoy','aHi'), 3
		it "memoizes without corrupting results", ->
			assert.equal $.stringDistance('Hoy','aHi'), 3
	
	describe ".stringDiff()", ->
		it "handles all inserts", ->
			assert.deepEqual $.stringDiff("", "abc"), [{op:'ins',v:'abc'}]
		it "handles all deletes", ->
			assert.deepEqual $.stringDiff("abc", ""), [{op:'del',v:'abc'}]
		it "handles replaces", ->
			assert.deepEqual $.stringDiff("a", "b"), [{op:'sub',v:'a',w:'b'}]
		it "handles all replaces", ->
			assert.deepEqual $.stringDiff("aaa", "bbb"), [{op:'sub',v:'aaa',w:'bbb'}]
		it "handles saves", ->
			assert.deepEqual $.stringDiff('a','a'), [{op:'sav',v:'a'}]
		it "handles all saves", ->
			assert.deepEqual $.stringDiff('aaa','aaa'), [{op:'sav',v:'aaa'}]
		it "handles mixed operations", ->
			assert.deepEqual $.stringDiff("ab", "bbd"), [{op:'sub',v:'a',w:'b'},{op:'sav',v:'b'},{op:'ins',v:'d'}]
		it "renders HTML", ->
			assert.deepEqual $.stringDiff("Hello", "Hi").toHTML(), "H<del>e</del><ins>i</ins><del>llo</del>"
	
	describe "$.Promise()", ->
		p = $.Promise()
		pass = false
		it "can be waited on", ->
			p.wait (err, data) -> pass = data
		it "can be finished", ->
			p.finish true
		it "passes the finished data to listeners", ->
			assert pass
		it "calls back instantly if already finished", ->
			pass = false
			p.wait (err, data) -> pass = data
			assert pass
		it "can be checked", ->
			assert.equal $.Promise().finished, false
			assert.equal $.Promise().finish().finished, true
			assert.equal $.Promise().failed, false
			assert.equal $.Promise().fail().failed, true
		it "can be reset", ->
			pass = false
			p.reset()
			p.wait (err, data) -> pass = data
			assert.equal pass, false # not fired yet
			p.finish(true)
			assert pass
		it "clears callbacks after fire", ->
			id = 0
			p.wait (err, data) -> id += data # handler A
			p.finish 1
			p.wait (err, data) -> id += data # handler B
			p.finish 1
			assert.equal id, 2 # if handler A or B ran more than once, id would be >= 3

		it "ignores more than one call to .finish()", ->
			pass = 1
			a = $.Promise().wait -> pass += pass
			a.finish()
			a.finish()
			assert.equal pass, 2 # not 4, if it had run twice

		it "ignores more than one call to .fail()", ->
			pass = 1
			a = $.Promise().wait (err, data) -> pass += err
			a.fail pass
			a.fail pass
			assert.equal pass, 2 # not 4, if it had run twice

		describe "optional timeout", ->
			it "sets error to 'timeout'", (done) ->
				$.Promise().wait 300, (err, data) ->
					assert.equal err, 'timeout'
					done()
			it "does not fire if the promise is finished", (done) ->
				pass = false
				$.Promise().wait(300, (err, data) ->
					assert.equal err, null
					pass = data
				).finish true
				$.delay 500, ->
					assert.equal pass, true
					done()

		describe "inheritance", ->
			it "works with default constructor", ->
				class Foo extends $.Promise
				f = new Foo()
				f.wait (err, data) -> f.pass = data
				f.finish true
				assert.equal f.pass, true
			it "works with super", ->
				class Foo extends $.Promise
					constructor: (@pass) -> super @
				f = new Foo(false)
				f.wait (err, data) -> f.pass = data
				f.finish true
				assert f.pass
		describe ".compose()", ->
			it "composes promises", ->
				pass = false
				a = $.Promise()
				b = $.Promise()
				c = $.Promise.compose(a, b).wait -> pass = true
				a.finish()
				b.finish()
				assert pass

	describe "$.Progress", ->
		it "is a Promise", ->
			p = $.Progress()
			waiting = true
			p.wait (err, data) -> waiting = false
			p.finish()
			assert.equal waiting, false
		describe "is an incremental Promise", ->
			p = $.Progress(10)
			_cur = _max = _done = 0
			p.on "progress", (cur, max) ->
				_cur = cur; _max = max
			p.wait (err, data) -> _done = data
			it "p.finish(n) adjusts progress by n", ->
				p.finish(1)
				assert.equal _cur, 1
				assert.equal _max, 10
			it "progress() with no args returns current progress", ->
				assert.equal p.progress(), _cur
			it "progress(cur) is a setter", ->
				p.progress(9)
				assert.equal p.progress(), 9
				assert.equal _done, 0
			it "completing progress finishes the Promise", ->
				p.progress(10)
				assert.equal _done, 10
			it "result of finished Progress is the final progress value", ->
				p.progress(11.1)
				assert.equal _done, 10 # the value at the time it was completed
			it "emits 'progress' events", ->
				a = $.Progress(2)
				data = []
				a.on 'progress', (cur, max) -> data.push [cur, max]
				a.finish 1
				a.finish 1
				assert.deepEqual data, [ [1,2], [2,2] ]

