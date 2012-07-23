require('./common')

$.testGroup "Object",
	keys: -> $.assertArrayEqual Object.keys({a: 1, b: 2}), ['a','b']

$.testGroup "Type",
	string: -> $.assertEqual $.type(""), "string"
	number:-> $.assertEqual $.type(42), "number"
	undef: -> $.assertEqual $.type(), "undefined"
	null: -> $.assertEqual $.type(null), "null"
	array: -> $.assertEqual $.type([]), "array"
	function: -> $.assertEqual $.type(() -> null), "function"
	bool: -> $.assertEqual $.type(true), "bool"
	regexp: -> $.assertEqual $.type(//), "regexp"
	window: -> $.assertEqual $.type(window), "global"
	is: ->
		$.assert($.is "function", ->)
		$.assert($.is "array", [])
	inherit: ->
		a = { a: 1 }
		b = { b: 2 }
		$.inherit a, b
		$.assertEqual(b.__proto__, a)
		$.assertEqual(b.a, 1)
		$.assert( not b.hasOwnProperty("a") )
	extend: -> $.assertArrayEqual Object.keys($.extend({A:1},{B:2})), ['A','B']
	defineProperty: ->
		a = {}
		$.defineProperty a, "b",
			get: -> 2
		$.assert( "b" of a )
	isType1: ->
		$.assert( $.isType(Array, []) )
	isType2: ->
		$.assert( $.isType('Array', []) )
	isType3: ->
		class Foo
		f = new Foo()
		$.assert( $.isType Foo, f )
	isSimple1: -> $.assert( $.isSimple "" )
	isSimple2: -> $.assert( $.isSimple 42.0 )
	isSimple3: -> $.assert( $.isSimple false )
	isSimple4: -> $.assert( not $.isSimple {} )
	isEmpty1: -> $.assert( $.isEmpty "" )
	isEmpty2: -> $.assert( $.isEmpty null )
	isEmpty3: -> $.assert( $.isEmpty undefined )
	toArray1: ->
		a = $([1,2,3])
		b = a.toArray()
		$.assert b.constructor.name is "Array", "constructor name is Array"
		$.assert b[1] is 2, "still has data"
		$.assert b.length is 3, "length is preserved"
		$.assert not b.zap, "has shed bling"
	as1: ->
		$.log $.as "number", "1234"

$.testGroup "Function",
	identity1: -> $.assertEqual $.type($.identity), "function"
	identity2: -> $.assertEqual( $.identity(a = {}), a)
	bound: ->
		f = -> @value
		a = { value: 'a' }
		b = { value: 'b' }
		g = $.bound(a, f)
		h = $.bound(b, f)
		$.assertEqual(g(), 'a')
		$.assertEqual(h(), 'b')
	trace: ->
		f = -> 42
		g = []
		h = $.trace f, "label", (a...) ->
			g.push a.join ''
		f() # this will not be traced
		h() # but this will, putting one "window.lable()" in the output
		$.assertArrayEqual(g, [ 'Trace: label created.', 'global.label()' ])

$.testGroup "String",
	Px1: -> $.assertEqual($.px(100), "100px")
	Px2: -> $.assertEqual($.px(-100.0), "-100px")
	Px3: -> $.assertEqual $.px("100.0px"), "100px"
	PadLeft1: -> $.assertEqual($.padLeft("foo", 5), "  foo")
	PadLeft2: -> $.assertEqual($.padLeft("foo", 3), "foo")
	PadLeft3: -> $.assertEqual($.padLeft("foo", 2), "foo")
	PadLeft4: -> $.assertEqual($.padLeft("foo", 5, "X"), "XXfoo")
	PadRight1: -> $.assertEqual($.padRight("foo", 5), "foo  ")
	PadRight2: -> $.assertEqual($.padRight("foo", 3), "foo")
	PadRight3: -> $.assertEqual($.padRight("foo", 2), "foo")
	PadRight4: -> $.assertEqual($.padRight("foo", 5, "X"), "fooXX")
	Splice1: -> $.assertEqual($.stringSplice("foobar",3,3,"baz"), "foobazbar")
	Splice2: -> $.assertEqual($.stringSplice("foobar",1,5,"baz"), "fbazr")
	Splice3: -> $.assertEqual($.stringSplice("foobar",0,6,"baz"), "baz")
	Splice4: -> $.assertEqual($.stringSplice("foobar",0,0,"baz"), "bazfoobar")
	Checksum1: -> $.assertEqual($.checksum("foobar"), 145425018) # test values are from python's adler32 in zlib
	Checksum2: -> $.assertEqual($.checksum("foobarbaz"), 310051767)
	ToString: -> $.assertEqual($([2,3,4]).toString(), "$([2, 3, 4])")

$.testGroup "Plugins",
	new_plugin: ->
		$.plugin ->
			$:
				testGlobal: -> 9
			testOp: -> 42
		$.assertEqual $.testGlobal?(), 9
		$.assertEqual $().testOp?(), 42
		$.assertEqual $.testOp?(), 42

$.testGroup "Symbol",
	exists: -> $.assert( Bling?, "bling should exist")
	current: ->
		Bling.assertEqual( Bling.symbol, "$" )
		Bling.assertEqual( $, Bling )
	set: ->
		Bling.symbol = "_"
		Bling.assertEqual( _, Bling )
	preserve: ->
		Bling.global.$ = "before"
		Bling.symbol = "$"
		Bling.assertEqual(Bling.global.$, Bling)
		Bling.symbol = "_"
		Bling.assertEqual(Bling.global.$, "before")
	reset: ->
		Bling.symbol = "$"
		Bling.assertEqual($, Bling)
	noConflict: ->
		Bling.global.noConflictTest = "magic"
		Bling.symbol = "noConflictTest"
		Bling.assert Bling.global.noConflictTest is Bling, 1
		foo = Bling.noConflict()
		Bling.assert Bling.symbol = "Bling", 2
		Bling.assert Bling.global[Bling.symbol] is Bling, 3
		Bling.assert foo is Bling, 4
		Bling.assert Bling.global.noConflictTest is "magic", 5
		Bling.symbol = "$"

$.testGroup "Math",
	sum0: -> $.assertEqual($([]).sum(), 0)
	sum1: -> $.assertEqual($([1,2,3,4,5]).sum(), 15)
	sum2: -> $.assertEqual($([1,2,NaN,3]).sum(), 6)
	range1: -> $.assertEqual($.range(1,6).toRepr(), '$([1, 2, 3, 4, 5])')
	range2: -> $.assertEqual($.range(5).toRepr(), '$([0, 1, 2, 3, 4])')
	zeros1: -> $.assertEqual($.zeros(10).sum(), 0)
	zeros2: -> $.assertEqual($.zeros(5).toRepr(), '$([0, 0, 0, 0, 0])')
	ones: -> $.assertEqual($.ones(10).sum(), 10)
	floats: -> $.assertEqual($(["12.1","29.9"]).floats().sum(), 42)
	ints: -> $.assertEqual($(["12.1","29.9px"]).ints().sum(), 41)
	px: -> $.assertEqual( $(["12.1", "29.9"]).px(2).toRepr(), "$(['14px', '31px'])" )
	min1: -> $.assertEqual( $([12.1, 29.9]).min(), 12.1)
	min2: -> $.assertEqual( $([12.1, NaN, 29.9]).min(), 12.1)
	max1: -> $.assertEqual( $([12.1, 29.9]).max(), 29.9)
	max2: -> $.assertEqual( $([12.1, NaN, 29.9]).max(), 29.9)

$.testGroup "Random",
	random: ->
		$.assert 0.0 < $.random() < 1.0
	real: ->
		$.assert 10.0 < $.random.real(10,100) < 100.0
	integer: ->
		r = $.random.integer(3,9)
		$.assert 3 <= r <= 9, "r is in range"
		$.assert Math.floor(r) is r, "r is an integer"
	string: ->
		s = $.random.string(16)
		$.assert $.type(s) is "string", "s is a string"
		$.assert s.length is 16, "s has the right length"
	seed: ->
		$.random.seed = 42
		r = $.random.string(16)
		$.random.seed = 43
		s = $.random.string(16)
		$.random.seed = 42
		t = $.random.string(16)
		$.assert r is t, "same seed produces same output"
		$.assert r isnt s, "different seed produces different output"

$.testGroup "Hash",
	number: -> $.assert $.hash(42) isnt $.hash(43)
	string: -> $.assert $.hash("foo") isnt $.hash("bar")
	array:  -> $.assert $.hash("poop") isnt $.hash(["poop"])
	array_order: -> $.assert $.hash(["a","b"]) isnt $.hash(["b","a"])
	object: -> $.assert ($.hash a:1) isnt ($.hash a:2)
	bling:  -> $.assert ($.hash $)?
	bling_order: -> $.assert $.hash($(["a","b"])) isnt $.hash($(["b","a"]))

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
$.testGroup "Core",
	new1: ->
		b = $([1,2,3])
		$.assertEqual(b[0], 1)
		$.assertEqual(b[1], 2)
		$.assertEqual(b[2], 3)
		$.assertEqual(b.constructor.name, "Bling")
	pipe1: ->
		$.pipe('unit-test').append (x) -> x += 2
		$.pipe('unit-test').prepend (x) -> x *= 2
		$.assertEqual( $.pipe('unit-test', 4), 10)
	eq: -> $.assertEqual($([1,2,3]).eq(1)[0], 2)
	each: ->
		sum = 0
		$([1,2,3,4]).each ->
			sum += @
		$.assertEqual(sum, 10)
	map: -> $.assertArrayEqual( $([1,2,3,4]).map( (x) -> x * x ), [1,4,9,16] )
	map2: ->
		d = [1,2,3,4,5]
		$.assertArrayEqual($(d).map(-> @ * 2), [2,4,6,8,10])
		# check that we get the same results when called twice (the original was not modified)
		$.assertArrayEqual($(d).map(-> @ * 2), [2,4,6,8,10])
	coalesce1: -> $.assertEqual($.coalesce(null, 42, 22), 42)
	coalesce2: -> $.assertEqual($.coalesce([null, 14, 42]), 14)
	coalesce3: -> $.assertEqual($.coalesce([null, [null, 14], 42]), 14)
	reduce: -> $.assertEqual( $([1,2,3,4]).reduce( (a,x) -> a + x ), 10)
	union: -> $.assertArrayEqual($([1,2,3,4]).union([2,3,4,5]), [1,2,3,4,5])
	intersect: -> $.assertArrayEqual($([1,2,3,4]).intersect([2,3,4,5]), [2,3,4])
	distinct: -> $.assertArrayEqual($([1,2,2,3,4,3]).distinct(), [1,2,3,4])
	contains1: -> $.assert $([1,2,3,4]).contains(3)
	contains2: -> $.assert $(["foo","bar","baz"]).contains("bar")
	count: -> $.assertEqual( $([1,2,2,3,4,3]).count(3), 2 )
	select: -> $.assertArrayEqual($([ {id:1}, {id:2}, {id:3} ]).select('id'), [1,2,3])
	select1: -> $.assertArrayEqual($([
		{a:{b:2}},
		{a:{b:4}},
		{a:{b:6}}
	]).select("a.b"), [2,4,6])
	select2: -> $.assertArrayEqual($([
		{a:[{b:3}]},
		{a:[{b:6}]},
		{a:[{b:9}]}
	]).select("a.0.b"), [3,6,9])
	select3: -> $.assertArrayEqual($([
		{a:{b:{c:4}}},
		{a:{b:{c:5}}},
		{a:{b:{c:6}}}
	]).select("a.b.c"), [4,5,6])
	zap: -> $.assertArrayEqual($([ {id:1}, {id:2}, {id:3} ]).zap('id', 13).select('id'), [13,13,13])
	zapf: -> $.assertArrayEqual($([ {id:1}, {id:2}, {id:3} ]).zap('id', () -> @ * 2).select('id'), [2,4,6])
	zapf2: -> $.assertArrayEqual( $([ {sub:{id:1}}, {sub:{id:2}}, {sub:{id:3}} ]).zap('sub.id', -> @*2).select('sub.id'), [2,4,6])
	take3: -> $.assertArrayEqual($([1,2,3,4]).take(0), [])
	take4: -> $.assertArrayEqual($([1,2,3,4]).take(1), [1])
	take5: -> $.assertArrayEqual($([1,2,3,4]).take(2), [1,2])
	take6: -> $.assertArrayEqual($([1,2,3,4]).take(3), [1,2,3])
	take7: -> $.assertArrayEqual($([1,2,3,4]).take(4), [1,2,3,4])
	take8: -> $.assertArrayEqual($([1,2,3,4]).take(5), [1,2,3,4])
	skip2: -> $.assertArrayEqual($([1,2,3,4]).skip(0), [1,2,3,4])
	skip3: -> $.assertArrayEqual($([1,2,3,4]).skip(1), [2,3,4])
	skip4: -> $.assertArrayEqual($([1,2,3,4]).skip(2), [3,4])
	skip5: -> $.assertArrayEqual($([1,2,3,4]).skip(3), [4])
	skip6: -> $.assertArrayEqual($([1,2,3,4]).skip(4), [])
	skip7: -> $.assertArrayEqual($([1,2,3,4]).skip(5), [])
	first1: -> $.assertEqual($([1,2,3,4]).first(), 1)
	first2: -> $.assertArrayEqual($([1,2,3,4]).first(5), [1,2,3,4])
	first3: -> $.assertArrayEqual($([1,2,3,4]).first(2), [1,2])
	first4: -> $.assertArrayEqual($([1,2,3,4]).first(0), [])
	last1: -> $.assertEqual($([1,2,3,4]).last(), 4)
	last2: -> $.assertArrayEqual($([1,2,3,4]).last(5), [1,2,3,4])
	last3: -> $.assertArrayEqual($([1,2,3,4]).last(2), [3,4])
	last4: -> $.assertArrayEqual($([1,2,3,4]).last(0), [])
	slice1: -> $.assertArrayEqual($([1,2,3,4,5]).slice(0,5), [1,2,3,4,5])
	slice2: -> $.assertArrayEqual($([1,2,3,4,5]).slice(1,5), [2,3,4,5])
	slice3: -> $.assertArrayEqual($([1,2,3,4,5]).slice(2,5), [3,4,5])
	slice4: -> $.assertArrayEqual($([1,2,3,4,5]).slice(3,5), [4,5])
	slice5: -> $.assertArrayEqual($([1,2,3,4,5]).slice(4,5), [5])
	slice6: -> $.assertArrayEqual($([1,2,3,4,5]).slice(1,-2), [2,3])
	slice7: -> $.assertArrayEqual($([1,2,3,4,5]).slice(-1,-3), [5,4])
	slice8: -> $.assertArrayEqual($([1,2,3,4,5]).slice(-1,-4), [5,4,3])
	# concat: -> $.assertArrayEqual($([1,2,3]).concat([3,4,4]), [1,2,3,3,4,4])
	push: -> $.assertArrayEqual($([1,2,3]).push(4), [1,2,3,4])
	filter1: -> $.assertArrayEqual($([1,2,3,4,5]).filter((x) -> x % 2), [1,3,5])
	filter2: -> $.assertArrayEqual($(["foo","bar","baz"]).filter(/^ba/), ["bar","baz"])
	filter3: -> $.assertArrayEqual($("*").filter("td").length, 8)
	filter4: -> $.assertEqual($("*").filter("td").filter(".d").length, 1)
	filter5: -> $.assertEqual($("*").filter("td").filter(".none").length, 0)
	filter6: -> $.assertArrayEqual($(["one","two","three"]).filter(-> String(@) isnt "three"), ["one", "two"])
	matches: -> $.assertArrayEqual($("td").matches(".d"), [false,false,false,false,false,true,false,false])
	querySelectorAll: -> $.assertArrayEqual($("tr").querySelectorAll("td.d")[0].className, "d")
	weave1: -> $.assertArrayEqual($([1,1,1]).weave([2,2,2]), [2,1,2,1,2,1])
	weave2: -> $.assertArrayEqual($([1,1,1]).weave($([2,2,2])), [2,1,2,1,2,1])
	fold: -> $.assertArrayEqual($([1,1,1]).weave([2,2,2]).fold( (a,b) -> a+b ), [3,3,3])
	flatten: -> $.assertArrayEqual($([[1,2],[3,4]]).flatten(), [1,2,3,4])
	call: -> $.assertArrayEqual($([((x) -> x*2), ((x) -> x*x)]).call(4), [8, 16])
	apply: -> $.assertArrayEqual($([((x) -> @+x), ((x) -> @*x)]).apply(4,[2]), [6, 8])
	corrected_length: ->
		$.assertEqual(Array(10).length,10)
		$.assertEqual(Bling(10).length, 0)

$.testGroup "DOM",
	parse: ->
		d = $.HTML.parse "<div><a></a><b></b><c></c></div>"
		$.assertEqual $.type(d), "node"
		$.assertEqual d.nodeName, "DIV"
	stringify: -> $.assertEqual $.HTML.stringify($.HTML.parse(h = "<div><a/><b/><c/></div>")), h
	select_childNodes: -> $.assertEqual( $("<div><a></a><b></b><c></c></div>").select("childNodes").flatten().map($.type).toRepr(), "$(['node', 'node', 'node'])" )
	child: -> i = 0; d = $("<div><a></a><b></b><c></c></div>"); $.assertEqual( d.select('childNodes').flatten().map( () -> d.child(i++) ).toRepr(), "$([$([<a/>]), $([<b/>]), $([<c/>])])")
	child2: -> $.assertEqual($("tr").child(0).select('nodeName').toRepr(), "$(['TD', 'TD', 'TD', 'TD'])")
	textData: ->
		d = $("<div>&nbsp;</div>")
		$.assertEqual d.toRepr(), "$([<div>&nbsp;</div>])"
		t = d.child 0
		$.assertEqual t.toRepr(), "$([&nbsp;])"
		t.zap 'data', '<p>'
		$.assertEqual d.select('innerHTML').first(), '&lt;p&gt;'
	escape: -> $.assertEqual $.HTML.escape("<p>"), "&lt;p&gt;"
	dashName1: -> $.assertEqual $.dashize("fooBar"), "foo-bar"
	dashName2: -> $.assertEqual $.dashize("FooBar"), "-foo-bar"
	html: -> $.assertEqual $("tr").html().first(), "<td>1,1</td><td>1,2</td>"
	append: ->
		try
			$.assertEqual($("tr td.d").append("<span>Hi</span>").html().first(), "3,2<span>Hi</span>")
		finally
			$("tr td.d span").remove()
	appendTo1:-> $.assertEqual($("<span>Hi</span>").toRepr(), "$([<span>Hi</span>])")
	appendTo2:->
		try
			$.assertEqual($("<span>Hi</span>").appendTo("tr td.d").toRepr(), "$([<span>Hi</span>])")
		finally
			$("tr td.d span").remove()
	appendTo3:->
		try
			$.assertEqual($("<span>Hi</span>").appendTo("tr td.d").select('parentNode').toRepr(), '$([<td class="d">3,2<span>Hi</span></td>])')
		finally
			$("tr td.d span").remove()
	appendTo4:->
		try
			$.assertEqual($("<span>Hi</span>").appendTo("tr td.d").select('parentNode').html().first(), "3,2<span>Hi</span>")
		finally
			$("tr td.d span").remove()
	prepend: ->
		try
			$.assertEqual($("tr td.d").prepend("<span>Hi</span>").html().first(), "<span>Hi</span>3,2")
		finally
			$("tr td.d span").remove()
	prependTo: ->
		try
			$.assertEqual($("<span>Hi</span>").prependTo("tr td.d").select('parentNode').html().first(), "<span>Hi</span>3,2")
		finally
			$("tr td.d span").remove()
	before: -> $.assertEqual($("<a><b></b></a>").find("b").before("<c></c>").select('parentNode').toRepr(), "$([<a><c/><b/></a>])")
	after1: -> $.assertEqual($("<a><b></b></a>").find("b").after("<c></c>").select('parentNode').toRepr(), "$([<a><b/><c/></a>])")
	after2: -> $.assertEqual($("<b></b>").after("<c></c>").select('parentNode').toRepr(), "$([<b/><c/>])")
	wrap: -> $.assertEqual($("<b></b>").wrap("<a></a>").select('parentNode').toRepr(), "$([<a><b/></a>])")
	unwrap: -> $.assertEqual($("<a><b/></a>").find("b").unwrap().first().parentNode, null)
	replace: -> $.assertEqual($("<a><b/><c/><b/></a>").find("b").replace("<p/>").eq(0).select('parentNode').toRepr(), "$([<a><p/><c/><p/></a>])")
	attr: -> $.assertEqual($("<a href='#'></a>").attr("href").first(), "#")
	attr2: -> $.assertEqual($("<a data-lazy-href='#'></a>").attr("data-lazy-href").first(), "#")
	attr3: -> $.assertEqual($("<a data-lazy-href='#'></a>").attr("data-lazy-href","poop").attr("data-lazy-href").first(), "poop")
	data: -> $.assertEqual($("<a data-lazy-href='#'></a>").data("lazyHref").first(), "#")
	data2: -> $.assertEqual($("<a data-lazy-href='#'></a>").data("lazyHref","poop").data("lazyHref").first(), "poop")
	removeClass: -> $.assertEqual($("<a class='test'></a>").removeClass('test').toRepr(), "$([<a/>])")
	removeClass2: -> $.assertEqual($("<a></a>").removeClass('test').toRepr(), "$([<a/>])")
	addClass: -> $.assertEqual($("<a></a>").addClass("test").toRepr(), '$([<a class="test"/>])')
	addClass2: -> $.assertEqual($("<a class='test'></a>").addClass("test").toRepr(), '$([<a class="test"/>])')
	addClass3: -> $.assertEqual($("<a class='test test'></a>").addClass("test").toRepr(), '$([<a class="test"/>])')
	toggleClass: -> $.assertEqual($("<a class='on'></a>").toggleClass("on").toRepr(), "$([<a/>])")
	toggleClass2: -> $.assertEqual($("<a class='off'></a>").toggleClass("on").toRepr(), '$([<a class="off on"/>])')
	toggleClass3: -> $.assertEqual($("<a class=''></a>").toggleClass("on").toRepr(), '$([<a class="on"/>])')
	toggleClass4: -> $.assertEqual($("<a></a>").toggleClass("on").toRepr(), '$([<a class="on"/>])')
	hasClass: -> $.assertEqual($("<a class='foo'></a>").hasClass("foo").first(), true)
	hasClass2: -> $.assertEqual($("<a class='bar'></a>").hasClass("foo").first(), false)
	text1: -> $.assertEqual($("<a>Hello<b>World</b></a>").select('innerText').toRepr(), "$(['HelloWorld'])")
	text3: -> $.assertEqual($("<a>Hello<b>World</b></a>").text().toRepr(), "$(['HelloWorld'])")
	text2: -> $.assertEqual($("<a>Hello<b>World</b></a>").text("Goodbye").toRepr(), "$([<a>Goodbye</a>])")
	value1: -> $.assertEqual($("<input type='text' value='foo'/>").val().toRepr(), "$(['foo'])")
	value2: -> $.assertEqual($("<input />").val().toRepr(), "$([''])")
	value3: -> $.assertEqual($("<input type='checkbox' checked />").val().toRepr(), "$(['on'])")
	parents: -> $.assertEqual($("td.d").parents().first().select('nodeName').toRepr(), "$(['TR', 'TABLE', 'BODY', 'HTML'])")
	prev: -> $.assertEqual($("div.c").prev().first().select('nodeName').filter(-> String(@) isnt "#TEXT").toRepr(), "$(['TABLE'])")
	next: -> $.assertEqual($("div.c").next().first().select('nodeName').filter(-> String(@) isnt "#TEXT").toRepr(), "$(['P'])")
	remove: ->
		a = $("<a><b class='x'/><c class='x'/><d/></a>")
		b = a.find(".x")
			.assertEqual(2, -> @length)
			.assertEqual("$(['B', 'C'])", -> @select('nodeName').toRepr())
			.remove()
			.assertEqual("$([null, null])", -> @select('parentNode').toRepr() )
		$.assertEqual a.toRepr(), '$([<a><d/></a>])'
	find: ->
		a = $("<a><b class='x'/><c class='x'/><d/></a>")
			.find(".x")
			.assertEqual(2, -> @length)
			.assertEqual("$(['B', 'C'])", -> @select('nodeName').toRepr())
	clone: ->
		c = $("div.c").clone()[0]
		d = $("div.c")[0]
		c.a = "magic"
		$.assertEqual( typeof d.a, "undefined")
		$.assertEqual( typeof c.a, "string")
	toFragment: ->
		$.assertEqual($("td").clone().toFragment().childNodes.length, 8)

$.testGroup "EventEmitter",
	basic: ->
		v = null
		$().on("change", (data) -> v = data)
			.emit("change", "foo")
		$.assertEqual v, "foo"

$.testGroup "Date",
	stamp: ->
		$.assert $.date.stamp(new Date(1000000), "ms") is 1000000
	stamp_sec: ->
		$.assert $.date.stamp(new Date(1000000), "s") is 1000
	unstamp: ->
		d1 = new Date(1000000)
		d2 = $.date.unstamp $.date.stamp d1
		$.assert d1.toString() is d2.toString()
	convert: ->
		$.assert $.date.convert(1000000, "ms", "s") is 1000
	midnight: ->
		d2 = $.date.unstamp $.date.midnight new Date 1000000000
		$.assert d2.toString().indexOf("19:00:00 GMT-0500") > -1
	format: ->
		d1 = new Date(1000000000)
		d2 = new Date(1000000)
		$.assertEqual $.date.format(d1, "yyyy-mm-dd HH:MM:SS"), "1970-01-12 13:46:40"
		$.assertEqual $.date.format(d2, "yyyy-mm-dd HH:MM:SS"), "1970-01-01 00:16:40"
	parse: ->
		$.assert $.date.parse("1970-01-12 13:46:40", "yyyy-mm-dd HH:MM:SS", "ms") is 1000000000
	range: ->
		$.assertEqual $($.date.range(1000, 1000000, 3))
			.unstamp()
			.select("getUTCDate").call()
			.ints().sum(), 35 # == 1 + 4 + 7 + 10 + 13 (every 3 days from Jan 1 1970 for 2 weeks)
	chain_format: ->
		$.assertEqual $($.date.range 1000, 1000000, 3)
			.dateFormat("dd")
			.ints().sum(), 35
	chain_midnight: ->
		$.assertEqual $($.date.range 1000, 1000000, 3)
			.midnight()
			.dateFormat("HHMMSS")
			.ints().sum(), 0

$.testGroup "TNET",
	basic: ->
		obj = $.TNET.parse $.TNET.stringify a:1,b:[2,3]
		$.assert obj.a is 1, "1"
		$.assert obj.b[0] is 2, "2"
		$.assert obj.b[1] is 3, "3"
	basic2: ->
		a = $()

$.testGroup "StateMachine",
	hello: ->
		class TestMachine extends $.StateMachine
			@STATE_TABLE = [
				{ # 0
					enter: ->
						@output = "<"
						@GO(1)
				}
				{ # 1
					def: (c) -> @output += c.toUpperCase()
					eof: @GO(2)
				}
				{ # 2
					enter: -> @output += ">"
				}
			]
			constructor: ->
				super(TestMachine.STATE_TABLE)
				@output = ""
		m = new TestMachine()
		$.assertEqual(m.run("hello").output, "<HELLO>")
		$.assertEqual(m.run("hi").output, "<HI>")

$.testGroup "Synth",
	basic_node: -> $.assertEqual $.synth("style").toString(), "$([<style/>])"
	id_node: -> $.assertEqual $.synth('style#specialId').toString(), '$([<style id="specialId"/>])'
	class_node: -> $.assertEqual $.synth('style.specClass').toString(), '$([<style class="specClass"/>])'
	attr_node: -> $.assertEqual $.synth('style[foo=bar]').toString(), '$([<style foo="bar"/>])'
	combo_node: -> $.assertEqual $.synth("style[a=b].c#d").toString(), '$([<style id="d" class="c" a="b"/>])'
	text: -> $.assertEqual $.synth("style 'text'").toString(), "$([<style>text</style>])"
	entity1: -> $.assertEqual $.synth("style 'text&amp;stuff'").toString(), "$([<style>text&amp;stuff</style>])"
	entity2: -> $.assertEqual $.synth("style 'text&stuff'").toString(), "$([<style>text&stuff</style>])"

