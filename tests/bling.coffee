common = require('./common')

testGroup("Object",
	Keys: () ->
		assertArrayEqual(Object.Keys({a: 1, b: 2}), ['a','b'])
	Extend: () ->
		a = {A:1}
		assertArrayEqual(Object.Keys(Object.Extend({A:1},{B:2})), ['A','B'])
	Type_string: () -> assertEqual(Object.Type(""), "string")
	Type_number:() -> assertEqual(Object.Type(42), "number")
	Type_undef: () -> assertEqual(Object.Type(), "undefined")
	Type_null: () -> assertEqual(Object.Type(null), "null")
	Type_array: () -> assertEqual(Object.Type([]), "array")
	Type_function: () -> assertEqual(Object.Type(() -> null), "function")
	Type_boolean: () -> assertEqual(Object.Type(true), "boolean")
	Type_regexp: () -> assertEqual(Object.Type(//), "regexp")
	Type_window: () -> assertEqual(Object.Type(window), "window")
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
		f()
		h()
		assertArrayEqual(g, [ 'Function.Trace: label created.', 'window.label()' ])
)

testGroup("Array",
	Coalesce1: () -> assertEqual(Array.Coalesce(null, 42, 22), 42)
	Coalesce2: () -> assertEqual(Array.Coalesce([null, 14, 42]), 14)
	Extend: () -> assertArrayEqual(Array.Extend([1,2,3],[3,4,5]), [1,2,3,3,4,5])
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
		assert( not $? )
	reset: () ->
		Bling.symbol = "$"
		assertEqual($, Bling)
)

# set up a test document, to run DOM tests agains
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
	reduce: () -> assertEqual( $([1,2,3,4]).reduce( (a,x) -> a + x ), 10)
	union: () -> assertArrayEqual($([1,2,3,4]).union([2,3,4,5]), [1,2,3,4,5])
	intersect: () -> assertArrayEqual($([1,2,3,4]).intersect([2,3,4,5]), [2,3,4])
	distinct: () -> assertArrayEqual($([1,2,2,3,4,3]).distinct(), [1,2,3,4])
	contains: () ->
		assert $([1,2,3,4]).contains(3)
		assert $(["foo","bar","baz"]).contains("bar")
	count: () -> assert $([1,2,2,3,4,3]).count(3) is 2
	zip: () -> assertArrayEqual($([ {id:1}, {id:2}, {id:3} ]).zip('id'), [1,2,3])
	zap: () -> assertArrayEqual($([ {id:1}, {id:2}, {id:3} ]).zap('id', 13).zip('id'), [13,13,13])
	zipzapmap: () -> assertArrayEqual($([ {id:1}, {id:2}, {id:3} ]).zipzapmap('id', () -> @ * 2).zip('id'), [2,4,6])
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
	HTMLparse: () ->
		d = $.HTML.parse("<div><a></a><b></b><c></c></div>")
		assertEqual( Object.Type(d), "node")
		assertEqual( d.nodeName, "DIV")
	zip_childNodes: () ->
		d = $("<div><a></a><b></b><c></c></div>")
		assertEqual( Object.Type(d), "bling")
		assertEqual( d.length, 1)
		assertEqual( Object.Type(d[0]), "node")
		d = d.zip("childNodes")
		assertEqual( Object.Type(d), "bling")
		assertEqual( Object.Type(d[0]), "array" )
		assertEqual( d[0].length, 3)
	childN: () ->
		d = $("<div><a></a><b></b><c></c></div>")
		a = d.child(0)
		assertEqual( Object.Type(a), "bling")
		assertEqual( a.length, 1)
		assertEqual( a[0].nodeName, "A")
		b = d.child(1)
		assertEqual( Object.Type(b), "bling")
		assertEqual( b.length, 1)
		assertEqual( b[0].nodeName, "B")
		c = d.child(2)
		assertEqual( Object.Type(c), "bling")
		assertEqual( c.length, 1)
		assertEqual( c[0].nodeName, "C")
	textData: () ->
		d = $("<div>&nbsp;</div>")
		assertEqual( Object.Type(d), "bling")
		assertEqual( d.length, 1 )
		d = d.child(0)
		assertEqual( Object.Type(d), "bling")
		assertEqual( d.length, 1 )
		assertEqual( Object.Type(d[0]), "node")
		d.zap('data', '<p>')
		# console.log("innerHTML: " + d[0].innerHTML)
		# console.log("toString: " + d[0].toString())
		assertEqual( d.zip('innerHTML').toString(), '&lt;p&gt;' )
	HTMLescape: () -> assertEqual($.HTML.escape("<p>"), "&lt;p&gt;")
	dataName1: () -> assertEqual($.dataName("fooBar"), "foo-bar")
	dataName2: () -> assertEqual($.dataName("FooBar"), "-foo-bar")
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
	replace: () -> assertEqual($("<a><b/><c/><b/></a>").find("b").replace("<d/>").toString(), "$([<a><d/><c/><d/></a>])")
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

### still need tests for all of these:
  'HTML',
  'duration',
  'http',
  'post',
  'get',
  'render',
  'synth'
]
[ 
  'toString',
  'delay',
  'log',
  'len',
  'unwrap',
  'replace',
  'attr',
  'addClass',
  'removeClass',
  'toggleClass',
  'hasClass',
  'text',
  'val',
  'css',
  'defaultCss',
  'empty',
  'rect',
  'width',
  'height',
  'top',
  'left',
  'bottom',
  'right',
  'position',
  'center',
  'scrollToCenter',
  'child',
  'children',
  'parent',
  'parents',
  'prev',
  'next',
  'remove',
  'find',
  'clone',
  'data',
  'toFragment',
  'floats',
  'ints',
  'px',
  'min',
  'max',
  'average',
  'sum',
  'squares',
  'magnitude',
  'scale',
  'normalize',
  'bind',
  'unbind',
  'once',
  'cycle',
  'trigger',
  'live',
  'die',
  'liveCycle',
  'click',
  'ready',
  'mousemove',
  'mousedown',
  'mouseup',
  'mouseover',
  'mouseout',
  'blur',
  'focus',
  'load',
  'unload',
  'reset',
  'submit',
  'keyup',
  'keydown',
  'change',
  'abort',
  'cut',
  'copy',
  'paste',
  'selection',
  'drag',
  'drop',
  'orientationchange',
  'touchstart',
  'touchmove',
  'touchend',
  'touchcancel',
  'gesturestart',
  'gestureend',
  'gesturecancel',
  'hashchange',
  'transform',
  'hide',
  'show',
  'toggle',
  'fadeIn',
  'fadeOut',
  'fadeLeft',
  'fadeRight',
  'fadeUp',
  'fadeDown',
  'template',
  'render',
  'synth' ]
###
