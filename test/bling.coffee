dom = require("jldom")
dom.registerGlobals(global)
global.document = dom.createDocument()
global.window = global
require "../dist/bling.js"
assert = require 'assert'

describe "Object", ->
	it "should have a keys method", ->
		assert typeof Object.keys is "function"
	it "should have a values method", ->
		assert typeof Object.values is "function"
	describe "#keys()", ->
		it "should return the list of keys", ->
			assert.deepEqual Object.keys( "a": 1, b: 2 ), ['a', 'b']
	describe "#values()", ->
		it "should return the list of values", ->
			assert.deepEqual Object.values( "a": 1, b: 2 ), [1, 2]

describe "$.type()", ->
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
describe "$.is()", ->
	describe "should identify", ->
		it "'array'", -> assert $.is "array", []
		it "'function'", -> assert $.is "function", ->
describe "$.inherit(a,b)", ->
	a = a: 1
	b = b: 2
	$.inherit a, b
	it "should set b's __proto__ to a", ->
		assert.equal b.__proto__, a
	it "b should inherit properties from a", ->
		assert.equal b.a, 1
	it "but b should not own those properties", ->
		assert not b.hasOwnProperty "a"
describe "$.extend(a,b)", ->
	a = a: 1
	b = b: 2
	c = $.extend a, b
	it "should return the modified a", -> assert.equal c, a
	it "should give a properties from b", -> assert.equal a.b, 2
	it "should copy those properties", ->
		a.b = 3
		assert.equal b.b, 2
describe "$.defineProperty()", ->
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
describe "$.isType()", ->
	it "should compare against actual types", ->
		assert $.isType Array, []
	it "or against names of constructors", ->
		assert( $.isType('Array', []) )
	it "should work on non-builtin types", ->
		class Foo
		f = new Foo()
		assert $.isType Foo, f
describe "$.isSimple()", ->
	describe "should accept", ->
		it "strings", -> assert $.isSimple ""
		it "numbers", -> assert $.isSimple 42.0
		it "bools", -> assert( $.isSimple false )
	describe "should reject", ->
		it "objects", -> assert not $.isSimple {}
		it "arrays", -> assert not $.isSimple []
describe "$.isEmpty()", ->
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
describe "$.toArray()", ->
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
describe "$.as()", ->
	describe "should convert", ->
		it "strings to numbers", -> assert.equal ($.as "number", "1234"), 1234

describe "$.identity", ->
	it "should be a function", -> assert $.is "function", $.identity
	it "should echo anything", -> assert.equal $.identity(a = {}), a
describe "$.bound", ->
	f = -> @value
	a = value:'a'
	b = value:'b'
	it "binding to a should return a's value", ->
		assert.equal do $.bound(a, f), 'a'
	it "binding to b should return b's value", ->
		assert.equal do $.bound(b, f), 'b'
describe "$.trace", ->
	f = -> 42
	g = [] # an output buffer
	h = $.trace "label", f, (a...) ->
		g.push a.join ''
	it "should not trace the original function", ->
		f()
	it "should trace the returned function", ->
		h "one", "two" # but this will
		assert.deepEqual g, [ "global.label('one','two')" ]

describe "$.px()", ->
	describe "converts ... to pixel strings", ->
		it "integers", -> assert.equal $.px(100), "100px"
		it "floats", -> assert.equal $.px(-100.0), "-100px"
		it "negatives", -> assert.equal $.px(-100.0), "-100px"
		it "pixel strings", -> assert.equal $.px("100.0px"), "100px"
describe "$.padLeft()", ->
	it "adds padding when needed", ->
		assert.equal $.padLeft("foo", 5), "  foo"
	it "does not add padding when not needed", ->
		assert.equal $.padLeft("foo", 2), "foo"
	it "does not add padding when barely not needed", ->
		assert.equal $.padLeft("foo", 3), "foo"
	it "can pad with non-default character", ->
		assert.equal $.padLeft("foo", 5, "X"), "XXfoo"
describe "$.padRight()", ->
	it "adds padding when needed", -> assert.equal $.padRight("foo", 5), "foo  "
	it "doesnt when not", -> assert.equal $.padRight("foo", 2), "foo"
	it "doesnt when not", -> assert.equal $.padRight("foo", 3), "foo"
	it "can pad with non-default character", -> assert.equal $.padRight("foo", 5, "X"), "fooXX"
describe "$.stringSplice()", ->
	it "should insert text", ->
		assert.equal $.stringSplice("foobar",3,3,"baz"), "foobazbar"
	it "should partially replace text", ->
		assert.equal $.stringSplice("foobar",1,5,"baz"), "fbazr"
	it "should completely replace text", ->
		assert.equal $.stringSplice("foobar",0,6,"baz"), "baz"
	it "should prepend text", ->
		assert.equal $.stringSplice("foobar",0,0,"baz"), "bazfoobar"
describe "$.checkSum()", ->
	it "should compute the same hash as adler32", ->
		assert.equal $.checksum("foobar"), 145425018
	it "should not just hash the one thing", ->
		assert.equal $.checksum("foobarbaz"), 310051767
describe "$.toString()", ->
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
describe "$.stringTruncate()", ->
	it "should truncate long strings and add ellipses", ->
		assert.equal ($.stringTruncate "long string", 6), "long..."

describe "$.plugin()", ->
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

describe "Bling", ->
	it "should have it's global name", ->
		assert Bling?
	it "should start with the default symbol", ->
		assert.equal Bling.symbol, "$"
	it "should have mapped that symbol into globals", ->
		assert.equal global[Bling.symbol], Bling
	it "setting it should update globals", ->
		Bling.symbol = "_"
		assert.equal global[Bling.symbol], Bling
	it "should preserve value history"
###

describe "Symbol", ->
	it "exists", -> assert( Bling?, "bling should exist")
	it "current", ->
		Bling.assert.equal( Bling.symbol, "$" )
		Bling.assert.equal( $, Bling )
	it "set", ->
		Bling.symbol = "_"
		Bling.assert.equal( _, Bling )
	it "preserve", ->
		Bling.global.$ = "before"
		Bling.symbol = "$"
		Bling.assert.equal(Bling.global.$, Bling)
		Bling.symbol = "_"
		Bling.assert.equal(Bling.global.$, "before")
	it "reset", ->
		Bling.symbol = "$"
		Bling.assert.equal($, Bling)
	it "noConflict", ->
		Bling.global.noConflictTest = "magic"
		Bling.symbol = "noConflictTest"
		Bling.assert Bling.global.noConflictTest is Bling, 1
		foo = Bling.noConflict()
		Bling.assert Bling.symbol = "Bling", 2
		Bling.assert Bling.global[Bling.symbol] is Bling, 3
		Bling.assert foo is Bling, 4
		Bling.assert Bling.global.noConflictTest is "magic", 5
		Bling.symbol = "$"

describe "Math", ->
	it "avg0", -> assert.equal $([]).avg(), 0
	it "sum0", -> assert.equal($([]).sum(), 0)
	it "sum1", -> assert.equal($([1,2,3,4,5]).sum(), 15)
	it "sum2", -> assert.equal($([1,2,NaN,3]).sum(), 6)
	it "range1", -> assert.equal($.range(1,6).toRepr(), '$([1, 2, 3, 4, 5])')
	it "range2", -> assert.equal($.range(5).toRepr(), '$([0, 1, 2, 3, 4])')
	it "zeros1", -> assert.equal($.zeros(10).sum(), 0)
	it "zeros2", -> assert.equal($.zeros(5).toRepr(), '$([0, 0, 0, 0, 0])')
	it "ones", -> assert.equal($.ones(10).sum(), 10)
	it "floats", -> assert.equal($(["12.1","29.9"]).floats().sum(), 42)
	it "ints", -> assert.equal($(["12.1","29.9px"]).ints().sum(), 41)
	it "px", -> assert.equal( $(["12.1", "29.9"]).px(2).toRepr(), "$(['14px', '31px'])" )
	it "min1", -> assert.equal( $([12.1, 29.9]).min(), 12.1)
	it "min2", -> assert.equal( $([12.1, NaN, 29.9]).min(), 12.1)
	it "max1", -> assert.equal( $([12.1, 29.9]).max(), 29.9)
	it "max2", -> assert.equal( $([12.1, NaN, 29.9]).max(), 29.9)

describe "Random", ->
	it "random", ->
		assert 0.0 < $.random() < 1.0
	it "real", ->
		assert 10.0 < $.random.real(10,100) < 100.0
	it "integer", ->
		r = $.random.integer(3,9)
		assert 3 <= r <= 9, "r is in range"
		assert Math.floor(r) is r, "r is an integer"
	it "string", ->
		s = $.random.string(16)
		assert $.type(s) is "string", "s is a string"
		assert s.length is 16, "s has the right length"
	it "seed", ->
		$.random.seed = 42
		r = $.random.string(16)
		$.random.seed = 43
		s = $.random.string(16)
		$.random.seed = 42
		t = $.random.string(16)
		assert r is t, "same seed produces same output"
		assert r isnt s, "different seed produces different output"

describe "Hash", ->
	it "number", -> assert $.hash(42) isnt $.hash(43)
	it "string", -> assert $.hash("foo") isnt $.hash("bar")
	it "array", -> assert $.hash("poop") isnt $.hash(["poop"])
	it "array_order", -> assert $.hash(["a","b"]) isnt $.hash(["b","a"])
	it "object", -> assert ($.hash a:1) isnt ($.hash a:2)
	it "object2", -> assert isFinite $.hash a:1
	it "object3", -> assert isFinite $.hash {}
	it "object4", -> assert ($.hash {}) isnt ($.hash [])
	it "bling", -> assert ($.hash $)?
	it "bling_order", -> assert $.hash($(["a","b"])) isnt $.hash($(["b","a"]))

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
describe "Core", ->
	it "new1", ->
		b = $([1,2,3])
		assert.equal(b[0], 1)
		assert.equal(b[1], 2)
		assert.equal(b[2], 3)
		assert.equal(b.constructor.name, "Bling")
	it "pipe1", ->
		$.pipe('unit-test').append (x) -> x += 2
		$.pipe('unit-test').prepend (x) -> x *= 2
		assert.equal( $.pipe('unit-test', 4), 10)
	it "eq", -> assert.equal($([1,2,3]).eq(1)[0], 2)
	it "each", ->
		sum = 0
		$([1,2,3,4]).each ->
			sum += @
		assert.equal(sum, 10)
	it "map", -> assert.deepEqual( $([1,2,3,4]).map( (x) -> x * x ), [1,4,9,16] )
	it "map2", ->
		d = [1,2,3,4,5]
		assert.deepEqual($(d).map(-> @ * 2), [2,4,6,8,10])
		# check that we get the same results when called twice (the original was not modified)
		assert.deepEqual($(d).map(-> @ * 2), [2,4,6,8,10])
	it "coalesce1", -> assert.equal($.coalesce(null, 42, 22), 42)
	it "coalesce2", -> assert.equal($.coalesce([null, 14, 42]), 14)
	it "coalesce3", -> assert.equal($.coalesce([null, [null, 14], 42]), 14)
	it "reduce", -> assert.equal( $([1,2,3,4]).reduce( (a,x) -> a + x ), 10)
	it "union", -> assert.deepEqual($([1,2,3,4]).union([2,3,4,5]), [1,2,3,4,5])
	it "intersect", -> assert.deepEqual($([1,2,3,4]).intersect([2,3,4,5]), [2,3,4])
	it "distinct", -> assert.deepEqual($([1,2,2,3,4,3]).distinct(), [1,2,3,4])
	it "contains1", -> assert $([1,2,3,4]).contains(3)
	it "contains2", -> assert $(["foo","bar","baz"]).contains("bar")
	it "count", -> assert.equal( $([1,2,2,3,4,3]).count(3), 2 )
	it "select", -> assert.deepEqual($([ {id:1}, {id:2}, {id:3} ]).select('id'), [1,2,3])
	it "select1", -> assert.deepEqual($([
		{it "a", {b:2}},
		{it "a", {b:4}},
		{it "a", {b:6}}
	]).select("a.b"), [2,4,6])
	it "select2", -> assert.deepEqual($([
		{it "a", [{b:3}]},
		{it "a", [{b:6}]},
		{it "a", [{b:9}]}
	]).select("a.0.b"), [3,6,9])
	it "select3", -> assert.deepEqual($([
		{it "a", {b:{c:4}}},
		{it "a", {b:{c:5}}},
		{it "a", {b:{c:6}}}
	]).select("a.b.c"), [4,5,6])
	it "zap", -> assert.deepEqual($([ {id:1}, {id:2}, {id:3} ]).zap('id', 13).select('id'), [13,13,13])
	it "zapf", -> assert.deepEqual($([ {id:1}, {id:2}, {id:3} ]).zap('id', () -> @ * 2).select('id'), [2,4,6])
	it "zapf2", -> assert.deepEqual( $([ {sub:{id:1}}, {sub:{id:2}}, {sub:{id:3}} ]).zap('sub.id', -> @*2).select('sub.id'), [2,4,6])
	it "take3", -> assert.deepEqual($([1,2,3,4]).take(0), [])
	it "take4", -> assert.deepEqual($([1,2,3,4]).take(1), [1])
	it "take5", -> assert.deepEqual($([1,2,3,4]).take(2), [1,2])
	it "take6", -> assert.deepEqual($([1,2,3,4]).take(3), [1,2,3])
	it "take7", -> assert.deepEqual($([1,2,3,4]).take(4), [1,2,3,4])
	it "take8", -> assert.deepEqual($([1,2,3,4]).take(5), [1,2,3,4])
	it "skip2", -> assert.deepEqual($([1,2,3,4]).skip(0), [1,2,3,4])
	it "skip3", -> assert.deepEqual($([1,2,3,4]).skip(1), [2,3,4])
	it "skip4", -> assert.deepEqual($([1,2,3,4]).skip(2), [3,4])
	it "skip5", -> assert.deepEqual($([1,2,3,4]).skip(3), [4])
	it "skip6", -> assert.deepEqual($([1,2,3,4]).skip(4), [])
	it "skip7", -> assert.deepEqual($([1,2,3,4]).skip(5), [])
	it "first1", -> assert.equal($([1,2,3,4]).first(), 1)
	it "first2", -> assert.deepEqual($([1,2,3,4]).first(5), [1,2,3,4])
	it "first3", -> assert.deepEqual($([1,2,3,4]).first(2), [1,2])
	it "first4", -> assert.deepEqual($([1,2,3,4]).first(0), [])
	it "last1", -> assert.equal($([1,2,3,4]).last(), 4)
	it "last2", -> assert.deepEqual($([1,2,3,4]).last(5), [1,2,3,4])
	it "last3", -> assert.deepEqual($([1,2,3,4]).last(2), [3,4])
	it "last4", -> assert.deepEqual($([1,2,3,4]).last(0), [])
	it "slice1", -> assert.deepEqual($([1,2,3,4,5]).slice(0,5), [1,2,3,4,5])
	it "slice2", -> assert.deepEqual($([1,2,3,4,5]).slice(1,5), [2,3,4,5])
	it "slice3", -> assert.deepEqual($([1,2,3,4,5]).slice(2,5), [3,4,5])
	it "slice4", -> assert.deepEqual($([1,2,3,4,5]).slice(3,5), [4,5])
	it "slice5", -> assert.deepEqual($([1,2,3,4,5]).slice(4,5), [5])
	it "slice6", -> assert.deepEqual($([1,2,3,4,5]).slice(1,-2), [2,3])
	it "slice7", -> assert.deepEqual($([1,2,3,4,5]).slice(-1,-3), [5,4])
	it "slice8", -> assert.deepEqual($([1,2,3,4,5]).slice(-1,-4), [5,4,3])
	# it "concat", -> assert.deepEqual($([1,2,3]).concat([3,4,4]), [1,2,3,3,4,4])
	it "push", -> assert.deepEqual($([1,2,3]).push(4), [1,2,3,4])
	it "filter1", -> assert.deepEqual($([1,2,3,4,5]).filter((x) -> x % 2), [1,3,5])
	it "filter2", -> assert.deepEqual($(["foo","bar","baz"]).filter(/^ba/), ["bar","baz"])
	it "filter3", -> assert.deepEqual($("*").filter("td").length, 8)
	it "filter4", -> assert.equal($("*").filter("td").filter(".d").length, 1)
	it "filter5", -> assert.equal($("*").filter("td").filter(".none").length, 0)
	it "filter6", -> assert.deepEqual($(["one","two","three"]).filter(-> String(@) isnt "three"), ["one", "two"])
	it "matches", -> assert.deepEqual($("td").matches(".d"), [false,false,false,false,false,true,false,false])
	it "querySelectorAll", -> assert.deepEqual($("tr").querySelectorAll("td.d")[0].className, "d")
	it "weave1", -> assert.deepEqual($([1,1,1]).weave([2,2,2]), [2,1,2,1,2,1])
	it "weave2", -> assert.deepEqual($([1,1,1]).weave($([2,2,2])), [2,1,2,1,2,1])
	it "fold", -> assert.deepEqual($([1,1,1]).weave([2,2,2]).fold( (a,b) -> a+b ), [3,3,3])
	it "flatten", -> assert.deepEqual($([[1,2],[3,4]]).flatten(), [1,2,3,4])
	it "call", -> assert.deepEqual($([((x) -> x*2), ((x) -> x*x)]).call(4), [8, 16])
	it "apply", -> assert.deepEqual($([((x) -> @+x), ((x) -> @*x)]).apply(4,[2]), [6, 8])
	it "corrected_length", ->
		assert.equal(Array(10).length,10)
		assert.equal(Bling(10).length, 0)
	it "keysOf1", -> assert.deepEqual $.keysOf({a:1,b:2}), ["a","b"]
	it "keysOf2", ->
		a = it "a", 1
		$.defineProperty a, "b", it "get", -> 2
		assert.deepEqual $.keysOf(a), ["a", "b"]
	it "valuesOf1", -> assert.deepEqual $.valuesOf({a:1,b:2}), [1,2]
	it "valuesOf2", ->
		a = it "a", 1
		$.defineProperty a, "b", it "get", -> 2
		assert.deepEqual $.valuesOf(a), [1,2]

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
			.assert.equal(2, -> @length)
			.assert.equal("$(['B', 'C'])", -> @select('nodeName').toRepr())
			.remove()
			.assert.equal("$([null, null])", -> @select('parentNode').toRepr() )
		assert.equal a.toRepr(), '$([<a><d/></a>])'
	it "find", ->
		a = $("<a><b class='x'/><c class='x'/><d/></a>")
			.find(".x")
			.assert.equal(2, -> @length)
			.assert.equal("$(['B', 'C'])", -> @select('nodeName').toRepr())
	it "clone", ->
		c = $("div.c").clone()[0]
		d = $("div.c")[0]
		c.a = "magic"
		assert.equal( typeof d.a, "undefined")
		assert.equal( typeof c.a, "string")
	it "toFragment", ->
		assert.equal($("td").clone().toFragment().childNodes.length, 8)

describe "EventEmitter", ->
	it "basic", ->
		v = null
		$().on("change", (data) -> v = data)
			.emit("change", "foo")
		assert.equal v, "foo"

describe "Date", ->
	it "stamp", ->
		assert $.date.stamp(new Date(1000000), "ms") is 1000000
	it "stamp_sec", ->
		assert $.date.stamp(new Date(1000000), "s") is 1000
	it "unstamp", ->
		d1 = new Date(1000000)
		d2 = $.date.unstamp $.date.stamp d1
		assert d1.toString() is d2.toString()
	it "convert", ->
		assert $.date.convert(1000000, "ms", "s") is 1000
	it "midnight", ->
		d2 = $.date.unstamp $.date.midnight new Date 1000000000
		assert d2.toString().indexOf("it "19", 00:00 GMT-0500") > -1
	it "format", ->
		d1 = new Date(1000000000)
		d2 = new Date(1000000)
		assert.equal $.date.format(d1, "yyyy-mm-dd it "HH", MM:SS"), "1970-01-12 13:46:40"
		assert.equal $.date.format(d2, "yyyy-mm-dd it "HH", MM:SS"), "1970-01-01 00:16:40"
	it "parse", ->
		assert $.date.parse("1970-01-12 it "13", 46:40", "yyyy-mm-dd HH:MM:SS", "ms") is 1000000000
	it "range", ->
		assert.equal $($.date.range(1000, 1000000, 3))
			.unstamp()
			.select("getUTCDate").call()
			.ints().sum(), 35 # == 1 + 4 + 7 + 10 + 13 (every 3 days from Jan 1 1970 for 2 weeks)
	it "chain_format", ->
		assert.equal $($.date.range 1000, 1000000, 3)
			.dateFormat("dd")
			.ints().sum(), 35
	it "chain_midnight", ->
		assert.equal $($.date.range 1000, 1000000, 3)
			.midnight()
			.dateFormat("HHMMSS")
			.ints().sum(), 0
	it "dateAsString", ->
		assert.equal ($.as "string", new Date 1,2,3,4,5,6), "1901-03-03 it "09", 05:06"
	it "stringAsDate", ->
		assert.equal ($.as "date", "1901-03-03 it "09", 05:06").toString(), new Date(1,2,3,4,5,6).toString()
	it "dateAsNumber", ->
		assert.equal ($.as "number", new Date 1,2,3,4,5,6), -2172149694
	it "numberAsDate", ->
		assert.equal ($.as "date", -2172149694).toString(), (new Date 1,2,3,4,5,6).toString()

describe "TNET", ->
	it "basic", ->
		obj = $.TNET.parse $.TNET.stringify it "a", 1,b:[2,"3"]
		assert obj.a is 1, "1"
		assert obj.b[0] is 2, "2"
		assert obj.b[1] is "3", "3"

describe "StateMachine", ->
	it "hello", ->
		class TestMachine extends $.StateMachine
			@STATE_TABLE = [
				{ # 0
					it "enter", ->
						@output = "<"
						@GO 1
				}
				{ # 1
					it "def", (c) -> @output += c.toUpperCase()
					it "eof", @GO 2
				}
				{ # 2
					it "enter", -> @output += ">"
				}
			]
			it "constructor", ->
				super(TestMachine.STATE_TABLE)
				@output = ""
		m = new TestMachine
		assert.equal m.run("hello").output, "<HELLO>"
		assert.equal m.run("hi").output, "<HI>"

describe "Synth", ->
	it "basic_node", -> assert.equal $.synth("style").toString(), "$([<style/>])"
	it "id_node", -> assert.equal $.synth('style#specialId').toString(), '$([<style id="specialId"/>])'
	it "class_node", -> assert.equal $.synth('style.specClass').toString(), '$([<style class="specClass"/>])'
	it "attr_node", -> assert.equal $.synth('style[foo=bar]').toString(), '$([<style foo="bar"/>])'
	it "combo_node", -> assert.equal $.synth("style[ab=bc].cd#de").toString(), '$([<style id="de" class="cd" ab="bc"/>])'
	it "text", -> assert.equal $.synth("style 'text'").toString(), "$([<style>text</style>])"
	it "entity1", -> assert.equal $.synth("style 'text&amp;stuff'").toString(), "$([<style>text&amp;stuff</style>])"
	it "entity2", -> assert.equal $.synth("style 'text&stuff'").toString(), "$([<style>text&stuff</style>])"

describe "Delay", ->
	it "delayAsync", (callback) ->
		t = $.now
		ferry_errors = (callback, f) ->
			return (a...) ->
				try f(a...)
				catch err
					callback err
		$.delay 1000, ferry_errors callback, ->
			delta = Math.abs(($.now - t) - 1000)
			assert delta < 15, "delta too it "large", #{delta}"
			callback false

describe "Config", ->
	it "hasDefault", ->
		assert.equal $.config.get("does-not-exist","default"), "default"
	it "canCall", ->
		assert.equal $.config("foo","default"), $.config.get("foo","default")

describe "Index", ->
	it "index", ->
		keyFunc = (obj) -> obj.a
		c = $([ {it "a", 1, b:2}, {a:2, b:3} ]).index(keyFunc).query a:1
		assert c?, "query result should exist"
		assert.equal c.b, 2
	it "compoundKey", ->
		keyFunc = (obj) -> obj.a + "-" + obj.b
		b = $([ {it "a", 1, b:2, c:3}, {a:2, b:2, c:4 }]).index(keyFunc)
		c = b.query it "a", 1,b:2
		d = b.query it "a", 2,b:2
		assert c?, "query result should exist"
		assert.equal c.c, 3
		assert d?, "query result should exist"
		assert.equal d.c, 4
	it "failIfNoIndex", -> $([ a:1 ]).query a:1 # should throw
###
