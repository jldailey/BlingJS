dom = require("jldom")
dom.registerGlobals(global)
global.document = dom.createDocument()
global.window = global
window.innerWidth = 1234
window.innerHeight = 321
require "../dist/bling.js"
assert = require 'assert'
# set up a test document, to run DOM tests against
document.body.innerHTML = """
	<table>
		<tr><td>1,1</td><td>1,2</td></tr>
		<tr><td>2,1</td><td>2,2</td></tr>
		<tr><td>3,1</td><td class='d'>3,2</td></tr>
		<tr><td>4,1</td><td>4,2</td></tr>
	</table>
	<div class='c'>C</div>
	<p><span>foobar</span></p>
"""

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

	describe ".is()", ->
		describe "should identify", ->
			it "'array'", -> assert $.is "array", []
			it "'function'", -> assert $.is "function", ->

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

	describe ".trace", ->
		f = -> 42
		g = [] # an output buffer
		h = $.trace "label", f, (a...) ->
			g.push a.join ''
		it "should not trace the original function", ->
			f()
		it "should trace the returned function", ->
			h "one", "two" # but this will
			assert.deepEqual g, [ "global.label('one','two')" ]

	describe ".px()", ->
		describe "converts ... to pixel strings", ->
			it "integers", -> assert.equal $.px(100), "100px"
			it "floats", -> assert.equal $.px(-100.0), "-100px"
			it "negatives", -> assert.equal $.px(-100.0), "-100px"
			it "pixel strings", -> assert.equal $.px("100.0px"), "100px"

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
		it "should not fail", ->
			obj = a: 1
			$.defineProperty obj, 'xxx',
				get: -> throw new Error "forbidden"
			assert.equal $.toString(obj), "{a:1, xxx:[Error: forbidden]}"

	describe ".stringTruncate()", ->
		it "should truncate long strings and add ellipses", ->
			assert.equal ($.stringTruncate "long string", 6), "long..."

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

	describe ".avg()", ->
		it "average of an empty set is 0", ->
			assert.equal $([]).avg(), 0
		it "should compute the average", ->
			assert.equal $([1,2,3,4]).avg(), 2.5
		it "should be aliased as .mean()", ->
			assert.equal $.prototype.avg, $.prototype.mean

	describe ".sum()", ->
		it "should add an empty set as 0", ->
			assert.equal $([]).sum(), 0
		it "should compute the sum", ->
			assert.equal $([1,2,3,4,5]).sum(), 15
		it "should ignore non-numbers", ->
			assert.equal($([1,2,NaN,3]).sum(), 6)

	describe ".range(start,end)", ->
		it "should produce a sequence of ints from start to end", ->
			assert.equal($.range(1,6).toRepr(), '$([1, 2, 3, 4, 5])')
		it "start is optional, defaults to 0", ->
			assert.equal($.range(5).toRepr(), '$([0, 1, 2, 3, 4])')

	describe ".zeros()", ->
		it "should produce a set", ->
			assert $.is 'bling', $.zeros 10
		it "should produce all zeros", ->
			assert.equal 0, $.zeros(10).sum()

	describe ".ones()", ->
		it "should produce a set of ones", ->
			assert.equal $.ones(10).sum(), 10

	describe ".floats()", ->
		it "should convert everything to floats", ->
			assert.equal $(["12.1","29.9"]).floats().sum(), 42

	describe ".ints()", ->
		it "should convert everything to ints", ->
			assert.equal $(["12.1","29.9px"]).ints().sum(), 41

	describe ".px()", ->
		it "should convert everything to -px strings (for CSS)", ->
			assert.equal $(["12.1", "29.9"]).px(2).toRepr(), "$(['14px', '31px'])"

	describe ".min()", ->
		it "should return the smallest item", ->
			assert.equal $([12.1, 29.9]).min(), 12.1
		it "should ignore non-numbers", ->
			assert.equal( $([12.1, NaN, 29.9]).min(), 12.1)
		it "should return 0 for an empty set?"

	describe ".max()", ->
		it "should return the largest item", -> assert.equal( $([12.1, 29.9]).max(), 29.9)
		it "should ignore non-numbers", -> assert.equal( $([12.1, NaN, 29.9]).max(), 29.9)
		it "should return Infinity for an empty set?"
	
	describe ".dot()", ->
		it "computes the dot-product", ->
			assert.equal( $([1,2,3]).dot([4,5,6]), 4 + 10 + 18)
	
	describe ".angle()", ->
		it "computes the angle between vectors (in radians)", ->
			assert.equal( $(0,1,0).angle($ 1,0,0), $.deg2rad 90 )
			assert.equal( $(1,0,0).angle($ 1,0,0), $.deg2rad 0 )
		it "does not convert NaN to zero", ->
			assert not isFinite $(0,0,0).angle($ 0,0,0)
	
	describe ".cross()", ->
		it "computes the cross product of two vectors", ->
			assert.deepEqual( $(0,1,0).cross($ 1,0,0), [0,0,-1] )
		it "preserves order/direction", ->
			assert.deepEqual( $(1,0,0).cross($ 0,1,0), [0,0,1] )

	describe ".maxBy()", ->
		it "should return the largest item", ->
			assert.deepEqual $( {a:1}, {a:3}, {a:2} ).maxBy('a'), a:3
		it "accepts a value function", ->
			assert.deepEqual $( {a:1}, {a:3}, {a:2} ).maxBy((o) -> Math.pow(o.a,2)), a:3
	
	describe ".minBy()", ->
		it "should return the smallest item", ->
			assert.deepEqual $( {a:3}, {a:1}, {a:2} ).minBy('a'), a:1
		it "accepts a value function", ->
			assert.deepEqual $( {a:1}, {a:3}, {a:2} ).minBy((o) -> Math.pow(o.a,2)), a:1
	
	describe ".product()", ->
		it "computes the product of everything (like .sum() with *)", ->
			assert.equal $(2,4,6).product(), 48
	
	describe ".squares()", ->
		it "squares everything", -> assert.deepEqual $(2,4,6).squares(), [4, 16, 36]
	
	describe ".pow(n)", ->
		it "maps Math.pow", -> assert.deepEqual $(2,4,6).pow(3), [8,64,6*6*6]
	
	describe ".magnitude()", ->
		it "computes the vector length", -> assert.equal $(2,4,6).magnitude(), 7.483314773547883
	
	describe ".scale(r)", ->
		it "mulitiplies everything by a constant factor", -> assert.deepEqual $(2,4,6).scale(3), [6,12,18]
	
	describe ".add(n)", ->
		it "does vector addition (with a scalar)", ->
			assert.deepEqual $(2,4,6).add(2), [4,6,8]
		it "adds two vectors", ->
			assert.deepEqual $(2,4,6).add([3,5,9]), [5,9,15]
		it "truncates the longer vector if mis-sized", ->
			assert.deepEqual $(2,4,6,8).add([3,5,9]), [5,9,15]
		it "is also known as .plus()", ->
			assert.deepEqual $(2,4,6).plus(2), [4,6,8]
	describe ".sub(n)", ->
		it "does vector addition (with a scalar)", ->
			assert.deepEqual $(2,4,6).sub(2), [0,2,4]
		it "adds two vectors", ->
			assert.deepEqual $(2,4,6).sub([3,5,9]), [-1,-1,-3]
		it "truncates the longer vector if mis-sized", ->
			assert.deepEqual $(2,4,6,8).sub([3,5,9]), [-1,-1,-3]
		it "is also known as .minus()", ->
			assert.deepEqual $(2,4,6).minus(2), [0,2,4]
	
	describe ".normalize()", ->
		it "scales so that .magnitude() is 1", -> assert.equal $(2,4,6).normalize().magnitude(), 1
	
	describe ".deg2rad()", ->
		it "works as a global", -> assert.equal $.deg2rad(180), Math.PI
		it "works on a set", -> assert.deepEqual $(0,180).deg2rad(), [0, Math.PI]
	describe ".rad2deg()", ->
		it "works as a global", -> assert.equal $.rad2deg(Math.PI), 180
		it "works on a set", -> assert.deepEqual $(0,Math.PI).rad2deg(), [0, 180]

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

	describe ".hook()", ->
		it "is a function", ->
			assert $.is 'function', $.hook
		it "returns a hook with append/prepend", ->
			p = $.hook('unit-test')
			assert $.is 'function', p.append
			assert $.is 'function', p.prepend
		it "computes values when called", ->
			$.hook('unit-test').append (x) -> x += 2
			$.hook('unit-test').prepend (x) -> x *= 2
			assert.equal $.hook('unit-test', 4), 10

	describe ".eq()", ->
		it "selects a new set with only one element", ->
			assert.equal $([1,2,3]).eq(1)[0], 2

	describe ".each(f)", ->
		it "repeats f for each element", ->
			check = 0
			$([1,2,3]).each -> check += 1
			assert.equal check, 3

	describe ".map(f)", ->
		it "returns a new set", ->
			a = $([1,2,3])
			b = a.map (->)
			assert.notEqual a,b
		it "containing the results of f(each item)", ->
			assert.deepEqual $([1,2,3]).map(->@*@), [1,4,9]
	
	describe ".filterMap(f)", ->
		it "works like map, but can omit some results", ->
			assert.deepEqual $(1,2,3,4).filterMap(->
				if @ % 2 then @*@
				else null
			), [1, 9]
	
	describe ".tap(f)", ->
		it "applies f to this", ->
			assert.deepEqual $([1,2]).tap(-> @push 3), [1,2,3]
		it "chains on f's return value", ->
			assert.equal $([1,2]).tap(-> { n: @length }).n, 2
		it "passes the set as `this` and as the only argument", ->
			$([1,2]).tap (set) ->
				assert.equal $.type(@), "bling"
				assert.equal $.type(set), "bling"
	
	describe ".replaceWith", ->
		it "copies values from array to this", ->
			assert.deepEqual $(1,2,3,4).replaceWith([5,6,7,8]), [5,6,7,8]
		it "does not create a new Bling", ->
			d = $(1,2,3,4)
			e = d.replaceWith([5,6,7])
			assert.deepEqual d, [5,6,7,4]

	describe ".coalesce()", ->
		it "should return the first non-null item", ->
			assert.equal $.coalesce(null, 42, 22), 42
		it "should accept an array as argument", ->
			assert.equal($.coalesce([null, 14, 42]), 14)
		it "should descend arrays if nested", ->
			assert.equal($.coalesce([null, [null, 14], 42]), 14)
		it "should span arrays if given multiple", ->
			assert.equal $.coalesce([null, null], [null, [null, 14], 42]), 14

	describe ".reduce()", ->
		it "applies a combiner to accumulate a single result", ->
			assert.equal $([1,2,3,4]).reduce( (a,x) -> a + x ), 10

	describe ".union()", ->
		it "combines two sets, eliminating duplicates", ->
			assert.deepEqual $([1,2,3,4]).union([2,3,4,5]), [1,2,3,4,5]

	describe ".intersect()", ->
		it "combines two sets, leaving only the duplicates", ->
			assert.deepEqual($([1,2,3,4]).intersect([2,3,4,5]), [2,3,4])

	describe ".distinct()", ->
		it "removes duplicates from a single set", ->
			assert.deepEqual($([1,2,2,3,4,3]).distinct(), [1,2,3,4])

	describe ".contains()", ->
		it "returns true if an item is found in the set", ->
			assert $([1,2,3]).contains 3
		it "returns false if an item is not found", ->
			assert not $([1,2,3]).contains 4

	describe ".count()", ->
		it "returns the number of matching items, if given an item", ->
			assert.equal $([1,2,2,3,4,3]).count(3), 2
		it "returns the total count if no item is given", ->
			assert.equal $([1,2,2,3,4,3]).count(), 6

	describe ".select()", ->
		selectObjects = $ [
			{id: 1, pX: 2, pY: 3, parent: { id: 2 }, children: [ { id: 3 } ] },
			{id: 2, pX: 3, pY: 4, parent: { id: 4 }, children: [ { id: 6 } ] },
			{id: 3, pX: 4, pY: 5, parent: { id: 6 }, children: [ { id: 9 } ] },
		]
		it "extracts values from properties of items in a set", ->
			assert.deepEqual selectObjects.select('id'), [1,2,3]
		it "supports nested property names", ->
			assert.deepEqual selectObjects.select("parent.id"), [2,4,6]
		it "supports nesting into arrays", ->
			assert.deepEqual selectObjects.select("children.0.id"), [3,6,9]
		it "supports multiple arguments (creating simplified objects)", ->
			assert.deepEqual selectObjects.select("pX","pY"), [
				{ pX: 2, pY: 3 },
				{ pX: 3, pY: 4 },
				{ pX: 4, pY: 5 }
			]
		it "supports passing a regex, in lieu of multiple arguments", ->
			assert.deepEqual selectObjects.select(/^p[XY]/), [
				{ pX: 2, pY: 3 },
				{ pX: 3, pY: 4 },
				{ pX: 4, pY: 5 }
			]
		it "supports mixing a regex and string arguments", ->
			assert.deepEqual selectObjects.select(/^p[XY]/,"parent.id"), [
				{ pX: 2, pY: 3, id: 2 },
				{ pX: 3, pY: 4, id: 4 },
				{ pX: 4, pY: 5, id: 6 }
			]
			

	describe ".zap()", ->
		it "assigns values to properties of items in a set", ->
			assert.deepEqual $([ {id:1}, {id:2}, {id:3} ]).zap('id', 13).select('id'), [13,13,13]
		it "supports using a function to compute the assigned values", ->
			assert.deepEqual $([ {id:1}, {id:2}, {id:3} ]).zap('id', -> @ * 2).select('id'), [2,4,6]
		it "supports nested property names", ->
			assert.deepEqual $([ {sub:{id:1}}, {sub:{id:2}}, {sub:{id:3}} ]).zap('sub.id', -> @*2).select('sub.id'), [2,4,6]

		it "can be given an object of key/value pairs to zap", ->
			assert.deepEqual $( {a: 1}, {a: 2}, {a: 3} ).zap({b: 2, c: 3}),
				[ {a:1,b:2,c:3}, {a:2,b:2,c:3}, {a:3,b:2,c:3} ]

	describe ".take()", ->
		it "take0", -> assert.deepEqual $([1,2,3,4]).take(0), []
		it "take1", -> assert.deepEqual $([1,2,3,4]).take(1), [1]
		it "take2", -> assert.deepEqual $([1,2,3,4]).take(2), [1,2]
		it "take3", -> assert.deepEqual $([1,2,3,4]).take(3), [1,2,3]
		it "take4", -> assert.deepEqual $([1,2,3,4]).take(4), [1,2,3,4]
		it "take5", -> assert.deepEqual $([1,2,3,4]).take(5), [1,2,3,4]

	describe ".skip()", ->
		it "skip0", -> assert.deepEqual $([1,2,3,4]).skip(0), [1,2,3,4]
		it "skip1", -> assert.deepEqual $([1,2,3,4]).skip(1), [2,3,4]
		it "skip2", -> assert.deepEqual $([1,2,3,4]).skip(2), [3,4]
		it "skip3", -> assert.deepEqual $([1,2,3,4]).skip(3), [4]
		it "skip4", -> assert.deepEqual $([1,2,3,4]).skip(4), []
		it "skip5", -> assert.deepEqual $([1,2,3,4]).skip(5), []

	describe ".first()", ->
		a = $([1,2,3,4])
		it "returns a single element", -> assert.equal a.first(), 1
		it "acts like take", -> assert.deepEqual a.first(5), [1,2,3,4]
		it "acts like take", -> assert.deepEqual a.first(2), [1,2]
		it "acts like take", -> assert.deepEqual a.first(0), []

	describe ".last()", ->
		a = $([1,2,3,4])
		it "returns last element", -> assert.equal a.last(), 4
		it "returns multiple if asked", -> assert.deepEqual a.last(5), [1,2,3,4]
		it "returns multiple if asked", -> assert.deepEqual a.last(2), [3,4]
		it "returns multiple if asked", -> assert.deepEqual a.last(0), []

	describe ".slice()", ->
		a = $([1,2,3,4,5])
		it "slice1", -> assert.deepEqual $([1,2,3,4,5]).slice(0,5), [1,2,3,4,5]
		it "slice2", -> assert.deepEqual $([1,2,3,4,5]).slice(1,5), [2,3,4,5]
		it "slice3", -> assert.deepEqual $([1,2,3,4,5]).slice(2,5), [3,4,5]
		it "slice4", -> assert.deepEqual $([1,2,3,4,5]).slice(3,5), [4,5]
		it "slice5", -> assert.deepEqual $([1,2,3,4,5]).slice(4,5), [5]
		it "slice6", -> assert.deepEqual $([1,2,3,4,5]).slice(1,-2), [2,3]
		it "slice7", -> assert.deepEqual $([1,2,3,4,5]).slice(-1,-3), [5,4]
		it "slice8", -> assert.deepEqual $([1,2,3,4,5]).slice(-1,-4), [5,4,3]

	describe ".push()", ->
		it "appends to the set", ->
			assert.deepEqual $([1,2]).push(3), [1,2,3]
		it "overrides Array::push()", ->
			assert.notEqual Array::push, Bling::push
		it "returns the resulting set", ->
			assert $.is 'bling', $([1,2]).push(3)

	describe ".filter()", ->
		it "filters by a function", -> assert.deepEqual $([1,2,3,4,5]).filter((x) -> x % 2), [1,3,5]
		it "supports regular expressions", -> assert.deepEqual $(["foo","bar","baz"]).filter(/^ba/), ["bar","baz"]
		it "can chain DOM filters", -> assert.equal $("*").filter("td").filter(".d").length, 1
		it "filters might remove all nodes", -> assert.equal $("*").filter("td").filter(".none").length, 0
		it "filters DOM nodes by CSS selector", -> assert.deepEqual $("*").filter("td").length, 8
		it "supports an optional limit", -> assert.deepEqual $(["foo","bar","baz"]).filter(/^b/, 0), []
		it "supports an optional limit", -> assert.deepEqual $(["foo","bar","baz"]).filter(/^b/, 1), ["bar"]
		it "supports an optional limit", -> assert.deepEqual $(["foo","bar","baz"]).filter(/^b/, 2), ["bar","baz"]

	describe ".matches()", ->
		describe "supports", ->
			it "CSS selectors", ->
				assert.deepEqual $("td").matches(".d"), [false,false,false,false,false,true,false,false]
			it "regular expressions", ->
				assert.deepEqual $(["one","two","three"]).matches(/o/), [true, true, false]

	describe ".weave()", ->
		it "interleaves items from two sets", ->
			assert.deepEqual($([1,1,1]).weave([2,2,2]), [2,1,2,1,2,1])
		it "supports blinged arguments", ->
			assert.deepEqual($([1,1,1]).weave($([2,2,2])), [2,1,2,1,2,1])

	describe ".querySelectorAll()", ->
		it "queries children for DOM nodes", ->
			assert.deepEqual($("tr").querySelectorAll("td.d")[0].className, "d")

	describe ".fold()", ->
		it "is like a partial reduce", ->
			assert.deepEqual $([1,1,1]).weave([2,2,2]).fold( (a,b) -> a+b ), [3,3,3]
		it "returns half the items", ->
			assert.deepEqual $([1,2,3,4,5,6]).fold( (a,b) -> a+b ).length, 3

	describe ".flatten()", ->
		it "combines subsets", ->
			assert.deepEqual $([[1,2],[3,4]]).flatten(), [1,2,3,4]
		it "allows duplicates (unlike union)", ->
			assert.deepEqual $([[1,2],[1,2]]).flatten(), [1,2,1,2]

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

	describe "EventEmitter", ->
		it "works", ->
			a = $.EventEmitter a:1
			v = false
			a.on "event", -> v = true
			a.emit "event"
			assert v
		it "works on new blings automatically", ->
			b = $()
			v = false
			b.on "event", -> v = true
			b.emit "event"
			assert v
		it "provides (almost) the same API as node's EventEmitter", ->
			b = $()
			["addListener", "emit", "listeners", "on", "removeAllListeners", "removeListener", "setMaxListeners"].forEach (k) ->
				assert $.is 'function', b[k]
		it "can bless an object in-place", ->
			a = a:1
			b = $.EventEmitter(a)
			assert $.is 'function', a.emit
			assert $.is 'function', b.emit
		it "does not leak listeners", ->
			a = $.EventEmitter a:1
			a.on "smoke", -> "fire"
			a.on "smoke", -> "flee"
			assert.equal a.listeners("smoke").length, 2
			a.listeners("smoke").push("water")
			assert.equal a.listeners("smoke").length, 2
		describe "class extends support", ->
			class Foo extends $.EventEmitter
				constructor: ->
					super @
					@x = 1
				method: ->
			f = new Foo()
			it "gives new instances the EE interface", ->
				assert.equal $.type(f.on), "function"
			it "does not clobber instance methods", ->
				assert.equal $.type(f.method), "function"
			it "does not clobber instance properties", ->
				assert.equal $.type(f.x), "number"
			it "works", ->
				flag = false
				f.on 'event', -> flag = true
				f.emit 'event'
				assert.equal flag, true
			describe "inheritance chain", ->
				class A extends $.EventEmitter
					A: ->
				class B extends A
					B: ->
				class C extends B
					constructor: ->
						super(@)
				a = new A()
				b = new B()
				c = new C()
				it "goes through one level", ->
					assert.equal $.type(a.on), "function"
				it "goes through two levels", ->
					assert.equal $.type(b.on), "function"
				it "goes through three levels", ->
					assert.equal $.type(c.on), "function"


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

	describe ".TNET", ->
		describe ".parse()", ->
			it "parses TNET format strings into objects", ->
				assert.deepEqual $.TNET.parse("23:1:a'1:1#1:b'8:1:2#1:3']}"), {a:1,b:[2,"3"]}
		describe ".stringify()", ->
			it "creates TNET strings from objects", ->
				assert.equal $.TNET.stringify(a:1,b:[2,"3"]), "23:1:a'1:1#1:b'8:1:2#1:3']}"

	describe ".StateMachine", ->
		it "allows subclassing to define machines", ->
			class T extends $.StateMachine
			t = new T
			assert $.is 'function', t.run
		describe ".run()", ->
			it "reads input and rules from @STATE_TABLE", ->
				class Capper extends $.StateMachine
					@STATE_TABLE = [
						{
							enter: ->
								@output = "<<"
								@GO 1
						}
						{
							def: (c) -> @output += c.toUpperCase()
							eof: @GO 2
						}
						{
							enter: -> @output += ">>"
						}
					]
					constructor: ->
						super(Capper.STATE_TABLE)

				assert.equal new Capper().run("hello").output, "<<HELLO>>"

	describe ".synth()", ->
		it "creates DOM nodes", ->
			assert $.is 'node', $.synth('div').first()
		it "uses CSS-like selectors", ->
			assert.equal $.synth('div.cls#id[a=b][c=d] span p "text"').first().toString(), '<div id="id" class="cls" a="b" c="d"><span><p>text</p></span></div>'
		describe "supports CSS selectors:", ->
			it "id", -> assert.equal $.synth('div#id').first().id, "id"
			it "class", -> assert.equal $.synth('div.cls').first().className, "cls"
			it "attributes", -> assert.equal $.synth('div[foo=bar]').first().attributes.foo, "bar"
			it "attributes (multiple)", -> assert.deepEqual $.synth('div[a=b][c=d]').first().attributes, {a:'b',c:'d'}
			it "text (single quotes)", -> assert.equal $.synth("div 'text'").first().toString(), "<div>text</div>"
			it "text (double quotes)", -> assert.equal $.synth('div "text"').first().toString(), "<div>text</div>"
			it "entity escaped", -> assert.equal $.synth('div "text&amp;stuff"').first().toString(), "<div>text&amp;stuff</div>"
			it "entity un-escaped", -> assert.equal $.synth('div "text&stuff"').first().toString(), "<div>text&stuff</div>"

	describe "delay", ->
		describe ".delay(ms, f)", ->
			it "runs f after a delay of ms", (done) ->
				t = $.now
				$.delay 100, ->
					delta = Math.abs(($.now - t) - 100)
					assert delta < 25
					done()
		describe ".immediate(f)", ->
			it "runs f on the next tick", (done) ->
				pass = false
				$.immediate ->
					assert pass = true
					done()

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


describe "DOM", ->
	it "parse", ->
		d = $.HTML.parse "<div><a></a><b></b><c></c></div>"
		assert.equal $.type(d), "node"
		assert.equal d.nodeName, "DIV"
	it "stringify", -> assert.equal $.HTML.stringify($.HTML.parse(h = "<div><a/><b/><c/></div>")), h
	it "select_childNodes", -> assert.equal( $("<div><a></a><b></b><c></c></div>").select("childNodes").flatten().map($.type).toRepr(), "$(['node', 'node', 'node'])" )
	it "child", -> i = 0; d = $("<div><a></a><b></b><c></c></div>"); assert.equal( d.select('childNodes').flatten().map( () -> d.child(i++) ).toRepr(), "$([$([<a/>]), $([<b/>]), $([<c/>])])")
	it "child2", -> assert.equal($("tr").child(0).select('nodeName').toRepr(), "$(['TD', 'TD', 'TD', 'TD'])")
	it "textData", ->
		d = $("<div>&nbsp;</div>")
		assert.equal d.toRepr(), "$([<div>&nbsp;</div>])"
		t = d.child 0
		assert.equal t.toRepr(), "$([&nbsp;])"
		t.zap 'data', '<p>'
		assert.equal d.select('innerHTML').first(), '&lt;p&gt;'
	it "escape", -> assert.equal $.HTML.escape("<p>"), "&lt;p&gt;"
	it "dashName1", -> assert.equal $.dashize("fooBar"), "foo-bar"
	it "dashName2", -> assert.equal $.dashize("FooBar"), "-foo-bar"
	it "html1", -> assert.equal $("tr").html().first(), "<td>1,1</td><td>1,2</td>"
	it "html2", -> assert.equal $("div").html("<span>C</span>").html().first(), "<span>C</span>"
	it "append", ->
		try
			assert.equal($("tr td.d").append("<span>Hi</span>").html().first(), "3,2<span>Hi</span>")
		finally
			$("tr td.d span").remove()
	it "appendTo1", -> assert.equal($("<span>Hi</span>").toRepr(), "$([<span>Hi</span>])")
	it "appendTo2", ->
		try
			assert.equal($("<span>Hi</span>").appendTo("tr td.d").toRepr(), "$([<span>Hi</span>])")
		finally
			$("tr td.d span").remove()
	it "appendTo3", ->
		try
			assert.equal($("<span>Hi</span>").appendTo("tr td.d").select('parentNode').toRepr(), '$([<td class="d">3,2<span>Hi</span></td>])')
		finally
			$("tr td.d span").remove()
	it "appendTo4", ->
		try
			assert.equal($("<span>Hi</span>").appendTo("tr td.d").select('parentNode').html().first(), "3,2<span>Hi</span>")
		finally
			$("tr td.d span").remove()
	it "prepend", ->
		try
			assert.equal($("tr td.d").prepend("<span>Hi</span>").html().first(), "<span>Hi</span>3,2")
		finally
			$("tr td.d span").remove()
	it "prependTo", ->
		try
			assert.equal($("<span>Hi</span>").prependTo("tr td.d").select('parentNode').html().first(), "<span>Hi</span>3,2")
		finally
			$("tr td.d span").remove()
	it "before", -> assert.equal($("<a><b></b></a>").find("b").before("<c></c>").select('parentNode').toRepr(), "$([<a><c/><b/></a>])")
	it "after1", -> assert.equal($("<a><b></b></a>").find("b").after("<c></c>").select('parentNode').toRepr(), "$([<a><b/><c/></a>])")
	it "after2", -> assert.equal($("<b></b>").after("<c></c>").select('parentNode').toRepr(), "$([<b/><c/>])")
	it "wrap", -> assert.equal($("<b></b>").wrap("<a></a>").select('parentNode').toRepr(), "$([<a><b/></a>])")
	it "unwrap", -> assert.equal($("<a><b/></a>").find("b").unwrap().first().parentNode, null)
	it "replace", -> assert.equal($("<a><b/><c/><b/></a>").find("b").replace("<p/>").eq(0).select('parentNode').toRepr(), "$([<a><p/><c/><p/></a>])")
	it "attr", -> assert.equal($("<a href='#'></a>").attr("href").first(), "#")
	it "attr2", -> assert.equal($("<a data-lazy-href='#'></a>").attr("data-lazy-href").first(), "#")
	it "attr3", -> assert.equal($("<a data-lazy-href='#'></a>").attr("data-lazy-href","poop").attr("data-lazy-href").first(), "poop")
	it "data", -> assert.equal($("<a data-lazy-href='#'></a>").data("lazyHref").first(), "#")
	it "data2", -> assert.equal($("<a data-lazy-href='#'></a>").data("lazyHref","poop").data("lazyHref").first(), "poop")
	it "removeClass", -> assert.equal($("<a class='test'></a>").removeClass('test').toRepr(), "$([<a/>])")
	it "removeClass2", -> assert.equal($("<a></a>").removeClass('test').toRepr(), "$([<a/>])")
	it "addClass", -> assert.equal($("<a></a>").addClass("test").toRepr(), '$([<a class="test"/>])')
	it "addClass2", -> assert.equal($("<a class='test'></a>").addClass("test").toRepr(), '$([<a class="test"/>])')
	it "addClass3", -> assert.equal($("<a class='test test'></a>").addClass("test").toRepr(), '$([<a class="test"/>])')
	it "toggleClass", -> assert.equal($("<a class='on'></a>").toggleClass("on").toRepr(), "$([<a/>])")
	it "toggleClass2", -> assert.equal($("<a class='off'></a>").toggleClass("on").toRepr(), '$([<a class="off on"/>])')
	it "toggleClass3", -> assert.equal($("<a class=''></a>").toggleClass("on").toRepr(), '$([<a class="on"/>])')
	it "toggleClass4", -> assert.equal($("<a></a>").toggleClass("on").toRepr(), '$([<a class="on"/>])')
	it "hasClass", -> assert.equal($("<a class='foo'></a>").hasClass("foo").first(), true)
	it "hasClass2", -> assert.equal($("<a class='bar'></a>").hasClass("foo").first(), false)
	it "text1", -> assert.equal($("<a>Hello<b>World</b></a>").select('innerText').toRepr(), "$(['HelloWorld'])")
	it "text3", -> assert.equal($("<a>Hello<b>World</b></a>").text().toRepr(), "$(['HelloWorld'])")
	it "text2", -> assert.equal($("<a>Hello<b>World</b></a>").text("Goodbye").toRepr(), "$([<a>Goodbye</a>])")
	it "value1", -> assert.equal($("<input type='text' value='foo'/>").val().toRepr(), "$(['foo'])")
	it "value2", -> assert.equal($("<input />").val().toRepr(), "$([''])")
	it "value3", -> assert.equal($("<input type='checkbox' checked />").val().toRepr(), "$(['on'])")
	it "parents", -> assert.equal($("td.d").parents().first().select('nodeName').toRepr(), "$(['TR', 'TABLE', 'BODY', 'HTML'])")
	it "prev", -> assert.equal($("div.c").prev().first().select('nodeName').filter(-> String(@) isnt "#TEXT").toRepr(), "$(['TABLE'])")
	it "next", -> assert.equal($("div.c").next().first().select('nodeName').filter(-> String(@) isnt "#TEXT").toRepr(), "$(['P'])")
	it "remove", ->
		a = $("<a><b class='x'/><c class='x'/><d/></a>")
		b = a.find(".x")
		assert.equal b.length, 2
		assert.deepEqual b.select('nodeName'), ['B', 'C']
		b.remove()
		assert.deepEqual b.select('parentNode'), [null, null]
		assert.equal a.toRepr(), '$([<a><d/></a>])'
	it "find", ->
		a = $("<a><b class='x'/><c class='x'/><d/></a>")
			.find(".x")
		assert.equal a.length, 2
		assert.deepEqual a.select('nodeName'), ['B', 'C']
	it ".find(css, limit)", ->
		a = $("<a><b class='x'/><c class='x'/><d/></a>")
			.find(".x", 1)
		assert.equal a.length, 1
		assert.deepEqual a.select('nodeName'), ['B']
	it "clone", ->
		c = $("div.c").clone()[0]
		d = $("div.c")[0]
		c.a = "magic"
		assert.equal( typeof d.a, "undefined")
		assert.equal( typeof c.a, "string")
	it "toFragment", ->
		assert.equal($("td").clone().toFragment().childNodes.length, 8)
	describe ".rect()", ->
		it "returns a ClientRect for each DOM node", ->
			assert.deepEqual $("td").take(2)
				.rect().map(-> $.isType "ClientRect", @),
				[true,true]
		it "will shim in a fake rect for the window", ->
			assert.deepEqual $(window).rect().first(), {
				width: window.innerWidth
				height: window.innerHeight
				top: 0
				left: 0
				right: window.innerWidth
				bottom: window.innerHeight
			}
		
	describe "Events", ->
		it ".bind/trigger()", ->
			pass = false
			td = $("td").take(1).bind 'dummy', (evt) ->
				pass = (evt.type is 'dummy')
			td.trigger 'dummy'
			assert pass
		it ".click()", ->
			pass = 0
			td = $("td").click (evt) -> pass += 1
			td = $("td").bind 'click', (evt) -> pass += 1
			td.trigger 'click'
			# assert.equal pass, 2
		it ".un/delegate()", ->
			counter = 0
			cb = (evt) -> counter += 1
			$("table").delegate "td.d", "dummy", cb
			$("table td.d").trigger "dummy"
			$("table td").take(1).trigger "dummy"
			assert.equal counter, 1
			$("table td").trigger "dummy"
			assert.equal counter, 2
			$("table").undelegate "td.d", "dummy", cb
			$("table td").trigger "dummy"
			assert.equal counter, 2

