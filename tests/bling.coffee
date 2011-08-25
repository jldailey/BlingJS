assert = (c, msg) ->
	if not c
		throw Error msg
assertEqual = (a, b, label) ->
	if a isnt b
		throw Error "#{label or ''} (#{a?.toString()}) should equal (#{b?.toString()})"
assertArrayEqual = (a, b, label) ->
	for i in [0...a.length]
		try
			assertEqual(a[i], b[i], label)
		catch err
			throw Error "#{label or ''} #{a?.toString()} should equal #{b?.toString()}"

dom = require("./domjs/dom")
dom.registerGlobals(global)
global.document = dom.createDocument()
global.window = global
require("../bling.coffee")

output = (a...) -> console.log.apply console, a

total = [0,0,0]
red = "[0;31;40m"
green = "[0;32;40m"
yellow = "[0;33;40m"
normal = "[0;37;40m"
testGroup = (name, tests...) ->
	output "Test: #{name}"
	failed = passed = 0
	for test in tests
		total[0] += 1
		try
			test()
			passed += 1
			total[1] += 1
		catch err
			output "Failed: #{test.toString()}"
			output "Error String: '#{err.toString()}'"
			failed += 1
			total[2] += 1
	output "#{green}Pass: #{passed}#{normal}" +
		( if failed > 0 then "#{yellow}/#{passed+failed}#{red} Fail: #{failed}#{normal}" else "" )

testGroup("Object",
	() ->
		assertArrayEqual(Object.Keys({a: 1, b: 2}), ['a','b'])
	() ->
		a = {A:1}
		assertArrayEqual(Object.Keys(Object.Extend({A:1},{B:2})), ['A','B'])
	() -> assertEqual(Object.Type(""), "string")
	() -> assertEqual(Object.Type(42), "number")
	() -> assertEqual(Object.Type(), "undefined")
	() -> assertEqual(Object.Type(null), "null")
	() -> assertEqual(Object.Type([]), "array")
	() -> assertEqual(Object.Type(() -> null), "function")
	() -> assertEqual(Object.Type(true), "boolean")
	() -> assertEqual(Object.Type(//), "regexp")
	() -> assertEqual(Object.Type(window), "window")
	() ->
		assertEqual(typeof new Number(9), "object")
		assertEqual(typeof Object.Unbox(new Number(42)), "number")
)

testGroup("Function",
	() -> assertEqual(Object.Type(Function.Empty), "function")
	() ->
		f = () -> @value
		a = { value: 'a' }
		b = { value: 'b' }
		g = Function.Bound(f, a)
		h = Function.Bound(f, b)
		assertEqual(g(), 'a')
		assertEqual(h(), 'b')
	() ->
		f = () -> 42
		g = []
		h = Function.Trace(f, "label", (a...) ->
			g.push(a.join(''))
		)
		f()
		h()
		assertArrayEqual(g, [ 'Function.Trace: label created.', 'label[object global].()' ])
)

testGroup("Array",
	() -> assertEqual(Array.Coalesce(null, 42, 22), 42)
	() -> assertEqual(Array.Coalesce([null, 14, 42]), 14)
	() -> assertArrayEqual(Array.Extend([1,2,3],[3,4,5]), [1,2,3,3,4,5])
)

testGroup("Number",
	() -> assertEqual(Number.Px(100), "100px")
	() -> assertEqual(Number.Px(-100.0), "-100px")
	() -> assertEqual(Number.AtLeast(5)(-2), 5)
	() -> assertEqual(Number.AtLeast(5)(12), 12)
	() -> assertEqual(Number.AtMost(5)(12), 5)
	() -> assertEqual(Number.AtMost(5)(2), 2)
)

testGroup("String",
	() -> assertEqual(String.PadLeft("foo", 5), "  foo")
	() -> assertEqual(String.PadLeft("foo", 3), "foo")
	() -> assertEqual(String.PadLeft("foo", 2), "foo")
	() -> assertEqual(String.PadRight("foo", 5), "foo  ")
	() -> assertEqual(String.PadRight("foo", 3), "foo")
	() -> assertEqual(String.PadRight("foo", 2), "foo")
	() -> assertEqual(String.PadLeft("foo", 5, "X"), "XXfoo")
	() -> assertEqual(String.PadRight("foo", 5, "X"), "fooXX")
	() -> assertEqual(String.Splice("foobar",3,3,"baz"), "foobazbar")
	() -> assertEqual(String.Splice("foobar",1,5,"baz"), "fbazr")
	() -> assertEqual(String.Splice("foobar",0,6,"baz"), "baz")
	() -> assertEqual(String.Splice("foobar",0,0,"baz"), "bazfoobar")
	() -> assertEqual(String.Checksum("foobar"), 145425018) # test values are from python's adler32 in zlib
	() -> assertEqual(String.Checksum("foobarbaz"), 310051767)
)

testGroup("Plugins",
	() ->
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
	() -> assert( Bling?, "bling should exist")
	() ->
		assertEqual( Bling.symbol, "$" )
		assertEqual( $, Bling )
	() ->
		Bling.symbol = "_"
		assertEqual( _, Bling )
		assert( not $? )
	() ->
		Bling.symbol = "$"
		assertEqual($, Bling)
)

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
	() ->
		tds = $("td")
		assertEqual(tds.length, 8)
		assertEqual($("td").eq(0).text()[0], "1,1")
	() ->
		sum = 0
		$([1,2,3,4]).each () ->
			sum += @
		assertEqual(sum, 10)
	() -> assertArrayEqual( $([1,2,3,4]).map( (x) -> x * x ), [1,4,9,16] )
	() -> assertEqual( $([1,2,3,4]).reduce( (a,x) -> a + x ), 10)
	() -> assertArrayEqual($([1,2,3,4]).union([2,3,4,5]), [1,2,3,4,5])
	() -> assertArrayEqual($([1,2,3,4]).intersect([2,3,4,5]), [2,3,4])
	() -> assertArrayEqual($([1,2,2,3,4,3]).distinct(), [1,2,3,4])
	() ->
		assert $([1,2,3,4]).contains(3)
		assert $(["foo","bar","baz"]).contains("bar")
	() -> assert $([1,2,2,3,4,3]).count(3) is 2
	() ->
		objs = [ {id:1}, {id:2}, {id:3} ]
		assertArrayEqual($(objs).zip('id'), [1,2,3])
	() ->
		objs = [ {id:1}, {id:2}, {id:3} ]
		assertArrayEqual($(objs).zap('id', 13).zip('id'), [13,13,13])
	() ->
		objs = [ {id:1}, {id:2}, {id:3} ]
		assertArrayEqual($(objs).zipzapmap('id', () -> @ * 2).zip('id'), [2,4,6])
	() -> assertArrayEqual($([1,2,3,4]).take(-2), [3,4])
	() -> assertArrayEqual($([1,2,3,4]).take(-1), [4])
	() -> assertArrayEqual($([1,2,3,4]).take(0), [])
	() -> assertArrayEqual($([1,2,3,4]).take(1), [1])
	() -> assertArrayEqual($([1,2,3,4]).take(2), [1,2])
	() -> assertArrayEqual($([1,2,3,4]).take(3), [1,2,3])
	() -> assertArrayEqual($([1,2,3,4]).take(4), [1,2,3,4])
	() -> assertArrayEqual($([1,2,3,4]).take(5), [1,2,3,4])
	() -> assertArrayEqual($([1,2,3,4]).skip(-1), [1,2,3,4])
	() -> assertArrayEqual($([1,2,3,4]).skip(0), [1,2,3,4])
	() -> assertArrayEqual($([1,2,3,4]).skip(1), [2,3,4])
	() -> assertArrayEqual($([1,2,3,4]).skip(2), [3,4])
	() -> assertArrayEqual($([1,2,3,4]).skip(3), [4])
	() -> assertArrayEqual($([1,2,3,4]).skip(4), [])
	() -> assertArrayEqual($([1,2,3,4]).skip(5), [])
	() -> assertEqual($([1,2,3,4]).first(), 1)
	() -> assertEqual($([1,2,3,4]).last(), 4)
	() -> assertArrayEqual($([1,2,3,4]).first(5), [1,2,3,4])
	() -> assertArrayEqual($([1,2,3,4]).first(2), [1,2])
	() -> assertArrayEqual($([1,2,3,4]).first(0), [])
	() -> assertArrayEqual($([1,2,3,4]).last(5), [1,2,3,4])
	() -> assertArrayEqual($([1,2,3,4]).last(2), [3,4])
	() -> assertArrayEqual($([1,2,3,4]).last(0), [])
	() -> assertArrayEqual($([1,2,3,4,5]).slice(0,5), [1,2,3,4,5])
	() -> assertArrayEqual($([1,2,3,4,5]).slice(1,5), [2,3,4,5])
	() -> assertArrayEqual($([1,2,3,4,5]).slice(2,5), [3,4,5])
	() -> assertArrayEqual($([1,2,3,4,5]).slice(3,5), [4,5])
	() -> assertArrayEqual($([1,2,3,4,5]).slice(4,5), [5])
	() -> assertArrayEqual($([1,2,3,4,5]).slice(1,-2), [2,3])
	() -> assertArrayEqual($([1,2,3,4,5]).slice(-1,-3), [5,4])
	() -> assertArrayEqual($([1,2,3,4,5]).slice(-1,-4), [5,4,3])
	() -> assertArrayEqual($([1,2,3]).concat([3,4,4]), [1,2,3,3,4,4])
	() -> assertArrayEqual($([1,2,3]).push(4), [1,2,3,4])
	() -> assertArrayEqual($([1,2,3,4,5]).filter((x) -> x % 2), [1,3,5])
	() -> assertArrayEqual($(["foo","bar","baz"]).filter(/^ba/), ["bar","baz"])
	() -> assertArrayEqual($("*").filter("td").length, 8)
	() -> assertEqual($("*").filter("td").filter(".d").length, 1)
	() -> assertEqual($("*").filter("td").filter(".none").length, 0)
	() -> assertArrayEqual($(["foo","bar","baz"]).test(/^ba/), [false, true, true])
	() -> assertArrayEqual($("td").matches(".d"), [false,false,false,false,false,true,false,false])
	() -> assertArrayEqual($("tr").querySelectorAll("td.d")[0].className, "d")
	() -> assertArrayEqual($([1,1,1]).weave([2,2,2]), [2,1,2,1,2,1])
	() -> assertArrayEqual($([1,1,1]).weave($([2,2,2])), [2,1,2,1,2,1])
	() -> assertArrayEqual($([1,1,1]).weave([2,2,2]).fold( (a,b) -> a+b ), [3,3,3])
	() -> assertArrayEqual($([[1,2],[3,4]]).flatten(), [1,2,3,4])
	() -> assertArrayEqual($([((x) -> x*2), ((x) -> x*x)]).call(4), [8, 16])
	() -> assertArrayEqual($([((x) -> @+x), ((x) -> @*x)]).apply(4,[2]), [6, 8])
	() ->
		assertEqual(Array(10).length,10)
		assertEqual($(Array(10)).length, 0)
)

testGroup("HTML",
	() -> assertEqual($.HTML.escape("<p>"), "&lt;p&gt;")
)

output "Total: #{total[0]} Passed: #{total[1]} Failed: #{total[2]}"

### write tests for all of these:
Object.Keys
Object.Extend
Object.Type
  'plugin',
  'symbol',
  'HTML',
  'duration',
  'http',
  'post',
  'get',
  'render',
  'synth'
]
[ 'eq',
  'each',
  'map',
  'reduce',
  'union',
  'intersect',
  'distinct',
  'contains',
  'count',
  'zip',
  'zap',
  'zipzapmap',
  'take',
  'skip',
  'first',
  'last',
  'slice',
  'concat',
  'push',
  'filter',
  'test',
  'matches',
  'querySelectorAll',
  'weave',
  'fold',
  'flatten',
  'call',
  'apply',
  'toString',
  'delay',
  'log',
  'len',
  'dataName',
  'html',
  'append',
  'appendTo',
  'prepend',
  'prependTo',
  'before',
  'after',
  'wrap',
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
