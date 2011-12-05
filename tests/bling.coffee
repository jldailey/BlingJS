common = require('./common')

testGroup("Object",
	Keys: () -> assertArrayEqual Object.Keys({a: 1, b: 2}), ['a','b']
	Extend: () -> assertArrayEqual Object.Keys(Object.Extend({A:1},{B:2})), ['A','B']
	Type_string: () -> assertEqual Object.Type(""), "string"
	Type_number:() -> assertEqual Object.Type(42), "number"
	Type_undef: () -> assertEqual Object.Type(), "undefined"
	Type_null: () -> assertEqual Object.Type(null), "null"
	Type_array: () -> assertEqual Object.Type([]), "array"
	Type_function: () -> assertEqual Object.Type(() -> null), "function"
	Type_boolean: () -> assertEqual Object.Type(true), "boolean"
	Type_regexp: () -> assertEqual Object.Type(//), "regexp"
	Type_window: () -> assertEqual Object.Type(window), "window"
	Unbox: () ->
		assertEqual(typeof new Number(9), "object")
		assertEqual(typeof Object.Unbox(new Number(42)), "number")
)

testGroup("Function",
	Empty: () -> assertEqual(Object.Type(Function.Empty), "function")
	Bound: () ->
		f = () -> @value
		a = { value: 'a' }
		b = { value: 'b' }
		g = Function.Bound(f, a)
		h = Function.Bound(f, b)
		assertEqual(g(), 'a')
		assertEqual(h(), 'b')
	Trace: () ->
		f = () -> 42
		g = []
		h = Function.Trace(f, "label", (a...) ->
			g.push(a.join(''))
		)
		f() # this will not be traced
		h() # but this will, putting one "window.lable()" in the output
		assertArrayEqual(g, [ 'Function.Trace: label created.', 'window.label()' ])
)

testGroup("Array",
	Coalesce1: () -> assertEqual(Array.Coalesce(null, 42, 22), 42)
	Coalesce2: () -> assertEqual(Array.Coalesce([null, 14, 42]), 14)
	Extend: () -> assertArrayEqual(Array.Extend([1,2,3],[3,4,5]), [1,2,3,3,4,5])
	Compact1: () -> assertEqual(Array.Compact([1,2,3]), "123")
	Compact2: () -> assertEqual(Array.Compact([1,{a:1},3]).toString(), "1,[object Object],3")
	Compact3: () -> assertEqual(Array.Compact([1,[2,3],4]), "1234")
	Compact4: () -> assertEqual(Array.Compact([1,[2,3],[4,5]]), "12345")
	Compact5: () -> assertEqual(Array.Compact([1,[2,3],[4,{a:1},5]]).toString(), "1234,[object Object],5")
	Compact6: () -> assertEqual(Array.Compact([1,[2,3],[4,{a:1},[5],[6]]]).toString(), "1234,[object Object],56")
)

testGroup("Number",
	Px1: () -> assertEqual(Number.Px(100), "100px")
	Px2: () -> assertEqual(Number.Px(-100.0), "-100px")
	AtLeast1: () -> assertEqual(Number.AtLeast(5)(-2), 5)
	AtLeast2: () -> assertEqual(Number.AtLeast(5)(12), 12)
	AtMost1: () -> assertEqual(Number.AtMost(5)(12), 5)
	AtMost2: () -> assertEqual(Number.AtMost(5)(2), 2)
)

testGroup("String",
	PadLeft1: () -> assertEqual(String.PadLeft("foo", 5), "  foo")
	PadLeft2: () -> assertEqual(String.PadLeft("foo", 3), "foo")
	PadLeft3: () -> assertEqual(String.PadLeft("foo", 2), "foo")
	PadLeft4: () -> assertEqual(String.PadLeft("foo", 5, "X"), "XXfoo")
	PadRight1: () -> assertEqual(String.PadRight("foo", 5), "foo  ")
	PadRight2: () -> assertEqual(String.PadRight("foo", 3), "foo")
	PadRight3: () -> assertEqual(String.PadRight("foo", 2), "foo")
	PadRight4: () -> assertEqual(String.PadRight("foo", 5, "X"), "fooXX")
	Splice1: () -> assertEqual(String.Splice("foobar",3,3,"baz"), "foobazbar")
	Splice2: () -> assertEqual(String.Splice("foobar",1,5,"baz"), "fbazr")
	Splice3: () -> assertEqual(String.Splice("foobar",0,6,"baz"), "baz")
	Splice4: () -> assertEqual(String.Splice("foobar",0,0,"baz"), "bazfoobar")
	Checksum1: () -> assertEqual(String.Checksum("foobar"), 145425018) # test values are from python's adler32 in zlib
	Checksum2: () -> assertEqual(String.Checksum("foobarbaz"), 310051767)
)

testGroup("Plugins",
	new_plugin: () ->
		$.plugin () ->
			name: "Test Plugin"
			$:
				testGlobal: () -> 9
			testOp: () -> 42
		assert $.plugins.join(",").indexOf("Test Plugin") > -1
		assertEqual $?.testGlobal(), 9
		assertEqual $()?.testOp(), 42
)

testGroup("Symbol",
	exists: () -> assert( Bling?, "bling should exist")
	current: () ->
		assertEqual( Bling.symbol, "$" )
		assertEqual( $, Bling )
	set: () ->
		Bling.symbol = "_"
		assertEqual( _, Bling )
	preserve: () ->
		global.$ = "before"
		Bling.symbol = "$"
		assertEqual($, Bling)
		Bling.symbol = "_"
		assertEqual($, "before")
	reset: () ->
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
	eq: () ->
		tds = $("td")
		assertEqual(tds.length, 8)
		assertEqual($("td").eq(0).text()[0], "1,1")
	each: () ->
		sum = 0
		$([1,2,3,4]).each () ->
			sum += @
		assertEqual(sum, 10)
	map: () -> assertArrayEqual( $([1,2,3,4]).map( (x) -> x * x ), [1,4,9,16] )
	map2: () ->
		d = [1,2,3,4,5]
		assertArrayEqual($(d).map(() -> @ * 2), [2,4,6,8,10])
		# check that we get the same results when called twice (the original was not modified)
		assertArrayEqual($(d).map(() -> @ * 2), [2,4,6,8,10])
	reduce: () -> assertEqual( $([1,2,3,4]).reduce( (a,x) -> a + x ), 10)
	union: () -> assertArrayEqual($([1,2,3,4]).union([2,3,4,5]), [1,2,3,4,5])
	intersect: () -> assertArrayEqual($([1,2,3,4]).intersect([2,3,4,5]), [2,3,4])
	distinct: () -> assertArrayEqual($([1,2,2,3,4,3]).distinct(), [1,2,3,4])
	contains1: () -> assert $([1,2,3,4]).contains(3)
	contains2: () -> assert $(["foo","bar","baz"]).contains("bar")
	count: () -> assertEqual( $([1,2,2,3,4,3]).count(3), 2 )
	zip: () -> assertArrayEqual($([ {id:1}, {id:2}, {id:3} ]).zip('id'), [1,2,3])
	zap: () -> assertArrayEqual($([ {id:1}, {id:2}, {id:3} ]).zap('id', 13).zip('id'), [13,13,13])
	zapf: () -> assertArrayEqual($([ {id:1}, {id:2}, {id:3} ]).zap('id', () -> @ * 2).zip('id'), [2,4,6])
	zapf2: () -> assertArrayEqual($([ {sub:{id:1}}, {sub:{id:2}}, {sub:{id:3}} ]).zap('sub.id', () -> @ * 2).zip('sub.id'), [2,4,6])
	take1: () -> assertArrayEqual($([1,2,3,4]).take(-2), [3,4])
	take2: () -> assertArrayEqual($([1,2,3,4]).take(-1), [4])
	take3: () -> assertArrayEqual($([1,2,3,4]).take(0), [])
	take4: () -> assertArrayEqual($([1,2,3,4]).take(1), [1])
	take5: () -> assertArrayEqual($([1,2,3,4]).take(2), [1,2])
	take6: () -> assertArrayEqual($([1,2,3,4]).take(3), [1,2,3])
	take7: () -> assertArrayEqual($([1,2,3,4]).take(4), [1,2,3,4])
	take8: () -> assertArrayEqual($([1,2,3,4]).take(5), [1,2,3,4])
	skip1: () -> assertArrayEqual($([1,2,3,4]).skip(-1), [1,2,3,4])
	skip2: () -> assertArrayEqual($([1,2,3,4]).skip(0), [1,2,3,4])
	skip3: () -> assertArrayEqual($([1,2,3,4]).skip(1), [2,3,4])
	skip4: () -> assertArrayEqual($([1,2,3,4]).skip(2), [3,4])
	skip5: () -> assertArrayEqual($([1,2,3,4]).skip(3), [4])
	skip6: () -> assertArrayEqual($([1,2,3,4]).skip(4), [])
	skip7: () -> assertArrayEqual($([1,2,3,4]).skip(5), [])
	first1: () -> assertEqual($([1,2,3,4]).first(), 1)
	first2: () -> assertArrayEqual($([1,2,3,4]).first(5), [1,2,3,4])
	first3: () -> assertArrayEqual($([1,2,3,4]).first(2), [1,2])
	first4: () -> assertArrayEqual($([1,2,3,4]).first(0), [])
	last1: () -> assertEqual($([1,2,3,4]).last(), 4)
	last2: () -> assertArrayEqual($([1,2,3,4]).last(5), [1,2,3,4])
	last3: () -> assertArrayEqual($([1,2,3,4]).last(2), [3,4])
	last4: () -> assertArrayEqual($([1,2,3,4]).last(0), [])
	slice1: () -> assertArrayEqual($([1,2,3,4,5]).slice(0,5), [1,2,3,4,5])
	slice2: () -> assertArrayEqual($([1,2,3,4,5]).slice(1,5), [2,3,4,5])
	slice3: () -> assertArrayEqual($([1,2,3,4,5]).slice(2,5), [3,4,5])
	slice4: () -> assertArrayEqual($([1,2,3,4,5]).slice(3,5), [4,5])
	slice5: () -> assertArrayEqual($([1,2,3,4,5]).slice(4,5), [5])
	slice6: () -> assertArrayEqual($([1,2,3,4,5]).slice(1,-2), [2,3])
	slice7: () -> assertArrayEqual($([1,2,3,4,5]).slice(-1,-3), [5,4])
	slice8: () -> assertArrayEqual($([1,2,3,4,5]).slice(-1,-4), [5,4,3])
	concat: () -> assertArrayEqual($([1,2,3]).concat([3,4,4]), [1,2,3,3,4,4])
	push: () -> assertArrayEqual($([1,2,3]).push(4), [1,2,3,4])
	filter1: () -> assertArrayEqual($([1,2,3,4,5]).filter((x) -> x % 2), [1,3,5])
	filter2: () -> assertArrayEqual($(["foo","bar","baz"]).filter(/^ba/), ["bar","baz"])
	filter3: () -> assertArrayEqual($("*").filter("td").length, 8)
	filter4: () -> assertEqual($("*").filter("td").filter(".d").length, 1)
	filter5: () -> assertEqual($("*").filter("td").filter(".none").length, 0)
	test: () -> assertArrayEqual($(["foo","bar","baz"]).test(/^ba/), [false, true, true])
	matches: () -> assertArrayEqual($("td").matches(".d"), [false,false,false,false,false,true,false,false])
	querySelectorAll: () -> assertArrayEqual($("tr").querySelectorAll("td.d")[0].className, "d")
	weave1: () -> assertArrayEqual($([1,1,1]).weave([2,2,2]), [2,1,2,1,2,1])
	weave2: () -> assertArrayEqual($([1,1,1]).weave($([2,2,2])), [2,1,2,1,2,1])
	fold: () -> assertArrayEqual($([1,1,1]).weave([2,2,2]).fold( (a,b) -> a+b ), [3,3,3])
	flatten: () -> assertArrayEqual($([[1,2],[3,4]]).flatten(), [1,2,3,4])
	call: () -> assertArrayEqual($([((x) -> x*2), ((x) -> x*x)]).call(4), [8, 16])
	apply: () -> assertArrayEqual($([((x) -> @+x), ((x) -> @*x)]).apply(4,[2]), [6, 8])
	corrected_length: () ->
		assertEqual(Array(10).length,10)
		assertEqual($(Array(10)).length, 0)
)

testGroup("HTML",
	parse: () ->
		d = $.HTML.parse("<div><a></a><b></b><c></c></div>")
		assertEqual( Object.Type(d), "node")
		assertEqual( d.nodeName, "DIV")
	stringify: () ->
		h = "<div><a/><b/><c/></div>"
		assertEqual( $.HTML.stringify($.HTML.parse(h)), h)
	zip_childNodes: () -> assertEqual( $("<div><a></a><b></b><c></c></div>").zip("childNodes").flatten().map(Object.Type).toString(), "$([node, node, node])" )
	child: () -> i = 0; d = $("<div><a></a><b></b><c></c></div>"); assertEqual( d.zip('childNodes').flatten().map( () -> d.child(i++) ).toString(), "$([$([<a/>]), $([<b/>]), $([<c/>])])")
	textData: () ->
		d = $("<div>&nbsp;</div>")
		assertEqual( d.toString(), "$([<div>&nbsp;</div>])" )
		t = d.child(0)
		assertEqual( t.toString(), "$([&nbsp;])")
		t.zap('data', '<p>')
		assertEqual( d.zip('innerHTML').first(), '&lt;p&gt;' )
	escape: () -> assertEqual($.HTML.escape("<p>"), "&lt;p&gt;")
	dashName1: () -> assertEqual($.dashName("fooBar"), "foo-bar")
	dashName2: () -> assertEqual($.dashName("FooBar"), "-foo-bar")
	html: () -> assertEqual($("tr").html().first(), "<td>1,1</td><td>1,2</td>")
	append: () ->
		try
			assertEqual($("tr td.d").append("<span>Hi</span>").html().first(), "3,2<span>Hi</span>")
		finally
			$("tr td.d span").remove()
	appendTo:() ->
		try
			assertEqual($("<span>Hi</span>").appendTo("tr td.d").parent().html().first(), "3,2<span>Hi</span>")
		finally
			$("tr td.d span").remove()
	prepend: () ->
		try
			assertEqual($("tr td.d").prepend("<span>Hi</span>").html().first(), "<span>Hi</span>3,2")
		finally
			$("tr td.d span").remove()
	prependTo: () ->
		try
			assertEqual($("<span>Hi</span>").prependTo("tr td.d").parent().html().first(), "<span>Hi</span>3,2")
		finally
			$("tr td.d span").remove()
	before: () -> assertEqual($("<a><b></b></a>").find("b").before("<c></c>").parent().toString(), "$([<a><c/><b/></a>])")
	after1: () -> assertEqual($("<a><b></b></a>").find("b").after("<c></c>").parent().toString(), "$([<a><b/><c/></a>])")
	after2: () -> assertEqual($("<b></b>").after("<c></c>").parent().toString(), "$([<b/><c/>])")
	wrap: () -> assertEqual($("<b></b>").wrap("<a></a>").parent().toString(), "$([<a><b/></a>])")
	unwrap: () -> assertEqual($("<a><b/></a>").find("b").unwrap().first().parentNode, null)
	replace: () -> assertEqual($("<a><b/><c/><b/></a>").find("b").replace("<p/>").parent().eq(0).toString(), "$([<a><p/><c/><p/></a>])")
	attr: () -> assertEqual($("<a href='#'></a>").attr("href").first(), "#")
	attr2: () -> assertEqual($("<a data-lazy-href='#'></a>").attr("data-lazy-href").first(), "#")
	attr3: () -> assertEqual($("<a data-lazy-href='#'></a>").attr("data-lazy-href","poop").attr("data-lazy-href").first(), "poop")
	data: () -> assertEqual($("<a data-lazy-href='#'></a>").data("lazyHref").first(), "#")
	data2: () -> assertEqual($("<a data-lazy-href='#'></a>").data("lazyHref","poop").data("lazyHref").first(), "poop")
	removeClass: () -> assertEqual($("<a class='test'></a>").removeClass('test').toString(), "$([<a/>])")
	removeClass2: () -> assertEqual($("<a></a>").removeClass('test').toString(), "$([<a/>])")
	addClass: () -> assertEqual($("<a></a>").addClass("test").toString(), '$([<a class="test"/>])')
	addClass2: () -> assertEqual($("<a class='test'></a>").addClass("test").toString(), '$([<a class="test"/>])')
	addClass3: () -> assertEqual($("<a class='test test'></a>").addClass("test").toString(), '$([<a class="test"/>])')
	toggleClass: () -> assertEqual($("<a class='on'></a>").toggleClass("on").toString(), "$([<a/>])")
	toggleClass2: () -> assertEqual($("<a class='off'></a>").toggleClass("on").toString(), '$([<a class="off on"/>])')
	toggleClass3: () -> assertEqual($("<a class=''></a>").toggleClass("on").toString(), '$([<a class="on"/>])')
	toggleClass4: () -> assertEqual($("<a></a>").toggleClass("on").toString(), '$([<a class="on"/>])')
	hasClass: () -> assertEqual($("<a class='foo'></a>").hasClass("foo").first(), true)
	hasClass2: () -> assertEqual($("<a class='bar'></a>").hasClass("foo").first(), false)
	text1: () -> assertEqual($("<a>Hello<b>World</b></a>").zip('innerText').toString(), "$([HelloWorld])")
	text3: () -> assertEqual($("<a>Hello<b>World</b></a>").text().toString(), "$([HelloWorld])")
	text2: () -> assertEqual($("<a>Hello<b>World</b></a>").text("Goodbye").toString(), "$([<a>Goodbye</a>])")
	value1: () -> assertEqual($("<input type='text' value='foo'/>").val().toString(), "$([foo])")
	value2: () -> assertEqual($("<input />").val().toString(), "$([])")
	value3: () -> assertEqual($("<input type='checkbox' checked />").val().toString(), "$([on])")

)

testGroup("StateMachine",
	hello: () ->
		class TestMachine extends $.StateMachine
			@STATE_TABLE = [
				{ # 0
					enter: () ->
						@output = "<"
						@GO(1)
				}
				{ # 1
					def: (c) -> @output += c.toUpperCase()
					eof: @GO(2)
				}
				{ # 2
					enter: () -> @output += ">"
				}
			]
			constructor: () ->
				super(TestMachine.STATE_TABLE)
				@output = ""
		m = new TestMachine()
		assertEqual(m.run("hello").output, "<HELLO>")
		assertEqual(m.run("hi").output, "<HI>")
)


testGroup("Synth",
	basic_node: () -> assertEqual($.synth("style").toString(), "$([<style/>])")
	id_node: () -> assertEqual($.synth('style#specialId').toString(), '$([<style id="specialId"/>])')
	class_node: () -> assertEqual($.synth('style.specClass').toString(), '$([<style class="specClass"/>])')
	attr_node: () -> assertEqual($.synth('style[foo=bar]').toString(), '$([<style foo="bar"/>])')
	combo_node: () -> assertEqual($.synth("style[a=b].c#d").toString(), '$([<style id="d" class="c" a="b"/>])')
	text: () -> assertEqual($.synth("style 'text'").toString(), "$([<style>text</style>])")
	entity1: () -> assertEqual($.synth("style 'text&amp;stuff'").toString(), "$([<style>text&amp;stuff</style>])")
	entity2: () -> assertEqual($.synth("style 'text&stuff'").toString(), "$([<style>text&stuff</style>])")
)

testReport()

