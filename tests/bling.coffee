common = require('./common')

testGroup("Object",
	Keys: -> assertArrayEqual Object.keys({a: 1, b: 2}), ['a','b']
	Extend: -> assertArrayEqual Object.keys($.extend({A:1},{B:2})), ['A','B']
	Type_string: -> assertEqual $.type(""), "string"
	Type_number:-> assertEqual $.type(42), "number"
	Type_undef: -> assertEqual $.type(), "undefined"
	Type_null: -> assertEqual $.type(null), "null"
	Type_array: -> assertEqual $.type([]), "array"
	Type_function: -> assertEqual $.type(() -> null), "function"
	Type_bool: -> assertEqual $.type(true), "bool"
	Type_regexp: -> assertEqual $.type(//), "regexp"
	Type_window: -> assertEqual $.type(window), "global"
)

testGroup("Function",
	Identity: -> assertEqual $.type($.identity), "function"
	Bound: ->
		f = -> @value
		a = { value: 'a' }
		b = { value: 'b' }
		g = $.bound(a, f)
		h = $.bound(b, f)
		assertEqual(g(), 'a')
		assertEqual(h(), 'b')
	Trace: ->
		f = -> 42
		g = []
		h = $.trace f, "label", (a...) ->
			g.push a.join ''
		f() # this will not be traced
		h() # but this will, putting one "window.lable()" in the output
		assertArrayEqual(g, [ 'Trace: label created.', 'global.label()' ])
)

testGroup("String",
	Px1: -> assertEqual($.px(100), "100px")
	Px2: -> assertEqual($.px(-100.0), "-100px")
	PadLeft1: -> assertEqual($.padLeft("foo", 5), "  foo")
	PadLeft2: -> assertEqual($.padLeft("foo", 3), "foo")
	PadLeft3: -> assertEqual($.padLeft("foo", 2), "foo")
	PadLeft4: -> assertEqual($.padLeft("foo", 5, "X"), "XXfoo")
	PadRight1: -> assertEqual($.padRight("foo", 5), "foo  ")
	PadRight2: -> assertEqual($.padRight("foo", 3), "foo")
	PadRight3: -> assertEqual($.padRight("foo", 2), "foo")
	PadRight4: -> assertEqual($.padRight("foo", 5, "X"), "fooXX")
	Splice1: -> assertEqual($.stringSplice("foobar",3,3,"baz"), "foobazbar")
	Splice2: -> assertEqual($.stringSplice("foobar",1,5,"baz"), "fbazr")
	Splice3: -> assertEqual($.stringSplice("foobar",0,6,"baz"), "baz")
	Splice4: -> assertEqual($.stringSplice("foobar",0,0,"baz"), "bazfoobar")
	Checksum1: -> assertEqual($.checksum("foobar"), 145425018) # test values are from python's adler32 in zlib
	Checksum2: -> assertEqual($.checksum("foobarbaz"), 310051767)
)

testGroup("Plugins",
	new_plugin: ->
		$.plugin ->
			$:
				testGlobal: -> 9
			testOp: -> 42
		assertEqual $.testGlobal?(), 9
		assertEqual $().testOp?(), 42
		assertEqual $.testOp?(), 42
)

testGroup("Symbol",
	exists: -> assert( Bling?, "bling should exist")
	current: ->
		assertEqual( Bling.symbol, "$" )
		assertEqual( $, Bling )
	set: ->
		Bling.symbol = "_"
		assertEqual( _, Bling )
	preserve: ->
		global.$ = "before"
		Bling.symbol = "$"
		assertEqual($, Bling)
		Bling.symbol = "_"
		assertEqual($, "before")
	reset: ->
		Bling.symbol = "$"
		assertEqual($, Bling)
)

# set up a test document, to run DOM tests against
document.body.innerHTML = "
	<table>
	<tr><td>1,1</td><td>1,2</td></tr>
	<tr><td>2,1</td><td>2,2</td></tr>
	<tr><td>3,1</td><td class='d'>3,2</td></tr>
	<tr><td>4,1</td><td>4,2</td></tr>
	</table>
	<div class='c'>C</div>
	<p><span>foobar</span></p>
"
testGroup("Core",
	new1: ->
		b = $([1,2,3])
		assertEqual(b[0], 1)
		assertEqual(b[1], 2)
		assertEqual(b[2], 3)
		assertEqual(b.__proto__, Bling.prototype)
	eq: -> assertEqual($([1,2,3]).eq(1)[0], 2)
	each: ->
		sum = 0
		$([1,2,3,4]).each ->
			sum += @
		assertEqual(sum, 10)
	map: -> assertArrayEqual( $([1,2,3,4]).map( (x) -> x * x ), [1,4,9,16] )
	map2: ->
		d = [1,2,3,4,5]
		assertArrayEqual($(d).map(-> @ * 2), [2,4,6,8,10])
		# check that we get the same results when called twice (the original was not modified)
		assertArrayEqual($(d).map(-> @ * 2), [2,4,6,8,10])
	coalesce1: -> assertEqual($.coalesce(null, 42, 22), 42)
	coalesce2: -> assertEqual($.coalesce([null, 14, 42]), 14)
	coalesce3: -> assertEqual($.coalesce([null, [null, 14], 42]), 14)
	reduce: -> assertEqual( $([1,2,3,4]).reduce( (a,x) -> a + x ), 10)
	union: -> assertArrayEqual($([1,2,3,4]).union([2,3,4,5]), [1,2,3,4,5])
	intersect: -> assertArrayEqual($([1,2,3,4]).intersect([2,3,4,5]), [2,3,4])
	distinct: -> assertArrayEqual($([1,2,2,3,4,3]).distinct(), [1,2,3,4])
	contains1: -> assert $([1,2,3,4]).contains(3)
	contains2: -> assert $(["foo","bar","baz"]).contains("bar")
	count: -> assertEqual( $([1,2,2,3,4,3]).count(3), 2 )
	select: -> assertArrayEqual($([ {id:1}, {id:2}, {id:3} ]).select('id'), [1,2,3])
	select1: -> assertArrayEqual($([
		{a:{b:2}},
		{a:{b:4}},
		{a:{b:6}}
	]).select("a.b"), [2,4,6])
	select2: -> assertArrayEqual($([
		{a:[{b:3}]},
		{a:[{b:6}]},
		{a:[{b:9}]}
	]).select("a.0.b"), [3,6,9])
	select3: -> assertArrayEqual($([
		{a:{b:{c:4}}},
		{a:{b:{c:5}}},
		{a:{b:{c:6}}}
	]).select("a.b.c"), [4,5,6])
	zap: -> assertArrayEqual($([ {id:1}, {id:2}, {id:3} ]).zap('id', 13).select('id'), [13,13,13])
	zapf: -> assertArrayEqual($([ {id:1}, {id:2}, {id:3} ]).zap('id', () -> @ * 2).select('id'), [2,4,6])
	zapf2: -> assertArrayEqual( $([ {sub:{id:1}}, {sub:{id:2}}, {sub:{id:3}} ]).zap('sub.id', -> @*2).select('sub.id'), [2,4,6])
	take3: -> assertArrayEqual($([1,2,3,4]).take(0), [])
	take4: -> assertArrayEqual($([1,2,3,4]).take(1), [1])
	take5: -> assertArrayEqual($([1,2,3,4]).take(2), [1,2])
	take6: -> assertArrayEqual($([1,2,3,4]).take(3), [1,2,3])
	take7: -> assertArrayEqual($([1,2,3,4]).take(4), [1,2,3,4])
	take8: -> assertArrayEqual($([1,2,3,4]).take(5), [1,2,3,4])
	skip2: -> assertArrayEqual($([1,2,3,4]).skip(0), [1,2,3,4])
	skip3: -> assertArrayEqual($([1,2,3,4]).skip(1), [2,3,4])
	skip4: -> assertArrayEqual($([1,2,3,4]).skip(2), [3,4])
	skip5: -> assertArrayEqual($([1,2,3,4]).skip(3), [4])
	skip6: -> assertArrayEqual($([1,2,3,4]).skip(4), [])
	skip7: -> assertArrayEqual($([1,2,3,4]).skip(5), [])
	first1: -> assertEqual($([1,2,3,4]).first(), 1)
	first2: -> assertArrayEqual($([1,2,3,4]).first(5), [1,2,3,4])
	first3: -> assertArrayEqual($([1,2,3,4]).first(2), [1,2])
	first4: -> assertArrayEqual($([1,2,3,4]).first(0), [])
	last1: -> assertEqual($([1,2,3,4]).last(), 4)
	last2: -> assertArrayEqual($([1,2,3,4]).last(5), [1,2,3,4])
	last3: -> assertArrayEqual($([1,2,3,4]).last(2), [3,4])
	last4: -> assertArrayEqual($([1,2,3,4]).last(0), [])
	slice1: -> assertArrayEqual($([1,2,3,4,5]).slice(0,5), [1,2,3,4,5])
	slice2: -> assertArrayEqual($([1,2,3,4,5]).slice(1,5), [2,3,4,5])
	slice3: -> assertArrayEqual($([1,2,3,4,5]).slice(2,5), [3,4,5])
	slice4: -> assertArrayEqual($([1,2,3,4,5]).slice(3,5), [4,5])
	slice5: -> assertArrayEqual($([1,2,3,4,5]).slice(4,5), [5])
	slice6: -> assertArrayEqual($([1,2,3,4,5]).slice(1,-2), [2,3])
	slice7: -> assertArrayEqual($([1,2,3,4,5]).slice(-1,-3), [5,4])
	slice8: -> assertArrayEqual($([1,2,3,4,5]).slice(-1,-4), [5,4,3])
	# concat: -> assertArrayEqual($([1,2,3]).concat([3,4,4]), [1,2,3,3,4,4])
	push: -> assertArrayEqual($([1,2,3]).push(4), [1,2,3,4])
	filter1: -> assertArrayEqual($([1,2,3,4,5]).filter((x) -> x % 2), [1,3,5])
	filter2: -> assertArrayEqual($(["foo","bar","baz"]).filter(/^ba/), ["bar","baz"])
	filter3: -> assertArrayEqual($("*").filter("td").length, 8)
	filter4: -> assertEqual($("*").filter("td").filter(".d").length, 1)
	filter5: -> assertEqual($("*").filter("td").filter(".none").length, 0)
	matches: -> assertArrayEqual($("td").matches(".d"), [false,false,false,false,false,true,false,false])
	querySelectorAll: -> assertArrayEqual($("tr").querySelectorAll("td.d")[0].className, "d")
	weave1: -> assertArrayEqual($([1,1,1]).weave([2,2,2]), [2,1,2,1,2,1])
	weave2: -> assertArrayEqual($([1,1,1]).weave($([2,2,2])), [2,1,2,1,2,1])
	fold: -> assertArrayEqual($([1,1,1]).weave([2,2,2]).fold( (a,b) -> a+b ), [3,3,3])
	flatten: -> assertArrayEqual($([[1,2],[3,4]]).flatten(), [1,2,3,4])
	call: -> assertArrayEqual($([((x) -> x*2), ((x) -> x*x)]).call(4), [8, 16])
	apply: -> assertArrayEqual($([((x) -> @+x), ((x) -> @*x)]).apply(4,[2]), [6, 8])
	corrected_length: ->
		assertEqual(Array(10).length,10)
		assertEqual(Bling(10).length, 0)
)

testGroup("HTML",
	parse: ->
		d = $.HTML.parse("<div><a></a><b></b><c></c></div>")
		assertEqual( $.type(d), "node")
		assertEqual( d.nodeName, "DIV")
	stringify: ->
		h = "<div><a/><b/><c/></div>"
		assertEqual( $.HTML.stringify($.HTML.parse(h)), h)
	select_childNodes: -> assertEqual( $("<div><a></a><b></b><c></c></div>").select("childNodes").flatten().map($.type).toString(), "$([node, node, node])" )
	child: -> i = 0; d = $("<div><a></a><b></b><c></c></div>"); assertEqual( d.select('childNodes').flatten().map( () -> d.child(i++) ).toString(), "$([$([<a/>]), $([<b/>]), $([<c/>])])")
	textData: ->
		d = $("<div>&nbsp;</div>")
		assertEqual( d.toString(), "$([<div>&nbsp;</div>])" )
		t = d.child(0)
		assertEqual( t.toString(), "$([&nbsp;])")
		t.zap('data', '<p>')
		assertEqual( d.select('innerHTML').first(), '&lt;p&gt;' )
	escape: -> assertEqual($.HTML.escape("<p>"), "&lt;p&gt;")
	dashName1: -> assertEqual($.dashize("fooBar"), "foo-bar")
	dashName2: -> assertEqual($.dashize("FooBar"), "-foo-bar")
	html: -> assertEqual($("tr").html().first(), "<td>1,1</td><td>1,2</td>")
	append: ->
		try
			assertEqual($("tr td.d").append("<span>Hi</span>").html().first(), "3,2<span>Hi</span>")
		finally
			$("tr td.d span").remove()
	appendTo1:-> assertEqual($("<span>Hi</span>").toString(), "$([<span>Hi</span>])")
	appendTo2:->
		try
			assertEqual($("<span>Hi</span>").appendTo("tr td.d").toString(), "$([<span>Hi</span>])")
		finally
			$("tr td.d span").remove()
	appendTo3:->
		try
			assertEqual($("<span>Hi</span>").appendTo("tr td.d").select('parentNode').toString(), '$([<td class="d">3,2<span>Hi</span></td>])')
		finally
			$("tr td.d span").remove()
	appendTo4:->
		try
			assertEqual($("<span>Hi</span>").appendTo("tr td.d").select('parentNode').html().first(), "3,2<span>Hi</span>")
		finally
			$("tr td.d span").remove()
	prepend: ->
		try
			assertEqual($("tr td.d").prepend("<span>Hi</span>").html().first(), "<span>Hi</span>3,2")
		finally
			$("tr td.d span").remove()
	prependTo: ->
		try
			assertEqual($("<span>Hi</span>").prependTo("tr td.d").select('parentNode').html().first(), "<span>Hi</span>3,2")
		finally
			$("tr td.d span").remove()
	before: -> assertEqual($("<a><b></b></a>").find("b").before("<c></c>").select('parentNode').toString(), "$([<a><c/><b/></a>])")
	after1: -> assertEqual($("<a><b></b></a>").find("b").after("<c></c>").select('parentNode').toString(), "$([<a><b/><c/></a>])")
	after2: -> assertEqual($("<b></b>").after("<c></c>").select('parentNode').toString(), "$([<b/><c/>])")
	wrap: -> assertEqual($("<b></b>").wrap("<a></a>").select('parentNode').toString(), "$([<a><b/></a>])")
	unwrap: -> assertEqual($("<a><b/></a>").find("b").unwrap().first().parentNode, null)
	replace: -> assertEqual($("<a><b/><c/><b/></a>").find("b").replace("<p/>").select('parentNode').eq(0).toString(), "$([<a><p/><c/><p/></a>])")
	attr: -> assertEqual($("<a href='#'></a>").attr("href").first(), "#")
	attr2: -> assertEqual($("<a data-lazy-href='#'></a>").attr("data-lazy-href").first(), "#")
	attr3: -> assertEqual($("<a data-lazy-href='#'></a>").attr("data-lazy-href","poop").attr("data-lazy-href").first(), "poop")
	data: -> assertEqual($("<a data-lazy-href='#'></a>").data("lazyHref").first(), "#")
	data2: -> assertEqual($("<a data-lazy-href='#'></a>").data("lazyHref","poop").data("lazyHref").first(), "poop")
	removeClass: -> assertEqual($("<a class='test'></a>").removeClass('test').toString(), "$([<a/>])")
	removeClass2: -> assertEqual($("<a></a>").removeClass('test').toString(), "$([<a/>])")
	addClass: -> assertEqual($("<a></a>").addClass("test").toString(), '$([<a class="test"/>])')
	addClass2: -> assertEqual($("<a class='test'></a>").addClass("test").toString(), '$([<a class="test"/>])')
	addClass3: -> assertEqual($("<a class='test test'></a>").addClass("test").toString(), '$([<a class="test"/>])')
	toggleClass: -> assertEqual($("<a class='on'></a>").toggleClass("on").toString(), "$([<a/>])")
	toggleClass2: -> assertEqual($("<a class='off'></a>").toggleClass("on").toString(), '$([<a class="off on"/>])')
	toggleClass3: -> assertEqual($("<a class=''></a>").toggleClass("on").toString(), '$([<a class="on"/>])')
	toggleClass4: -> assertEqual($("<a></a>").toggleClass("on").toString(), '$([<a class="on"/>])')
	hasClass: -> assertEqual($("<a class='foo'></a>").hasClass("foo").first(), true)
	hasClass2: -> assertEqual($("<a class='bar'></a>").hasClass("foo").first(), false)
	text1: -> assertEqual($("<a>Hello<b>World</b></a>").select('innerText').toString(), "$([HelloWorld])")
	text3: -> assertEqual($("<a>Hello<b>World</b></a>").text().toString(), "$([HelloWorld])")
	text2: -> assertEqual($("<a>Hello<b>World</b></a>").text("Goodbye").toString(), "$([<a>Goodbye</a>])")
	value1: -> assertEqual($("<input type='text' value='foo'/>").val().toString(), "$([foo])")
	value2: -> assertEqual($("<input />").val().toString(), "$([])")
	value3: -> assertEqual($("<input type='checkbox' checked />").val().toString(), "$([on])")

)

testReport()

