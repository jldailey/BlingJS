
[$, assert] = require './setup'

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

describe "DOM", ->
	describe "$.HTML", ->
		it "can parse HTML strings", ->
			d = $.HTML.parse "<div><a></a><b></b><c></c></div>"
			assert.equal $.type(d), "node"
			assert.equal d.nodeName, "DIV"
		it "can stringify DOM nodes", ->
			assert.equal $.HTML.stringify($.HTML.parse(h = "<div><a/><b/><c/></div>")), h
		it "can escape HTML strings", ->
			assert.equal $.HTML.escape("<p>"), "&lt;p&gt;"
	describe ".child(n)", ->
		it "exists", ->
			assert 'child' of $("<div><a/></div>")
		it "returns the n-th child", ->
			i = 0
			d = $("<div><a></a><b></b><c></c></div>")
			assert.equal d.child(0).toRepr(), "$([<a/>])"
			assert.equal d.child(1).toRepr(), "$([<b/>])"
			assert.equal d.child(2).toRepr(), "$([<c/>])"
		it "works on found nodes", ->
			assert.equal $("tr").child(0).select('nodeName').toRepr(),
				"$(['TD', 'TD', 'TD', 'TD'])"
	describe "Text Nodes", ->
		d = $("<div>&nbsp;</div>")
		t = d.child 0
		it "are rendered by toRepr()", ->
			assert.equal d.toRepr(), "$([<div>&nbsp;</div>])"
		it "are rendered even when on their own", ->
			assert.equal t.toRepr(), "$([&nbsp;])"
		it "escape data assigned to .data", ->
			t.zap 'data', '<p>'
			assert.equal d.select('innerHTML').first(), '&lt;p&gt;'
	describe ".html()", ->
		it "renders a DOM node's contents as HTML", ->
			assert.equal $("tr").html().first(), "<td>1,1</td><td>1,2</td>"
		it "replaces a node's content with (parsed) HTML", ->
			assert.equal $("div").html("<span>C</span>").html().first(), "<span>C</span>"
	describe ".append()", ->
		it "appends simple HTML", ->
			try
				assert.equal($("tr td.d").append("<span>Hi</span>").html().first(), "3,2<span>Hi</span>")
			finally
				$("tr td.d span").remove()
		it "appends HTML fragments", ->
			try
				assert.equal($("tr td.d").append("<span>Hi</span><br>").html().first(), "3,2<span>Hi</span><br/>")
			finally
				$("tr td.d span").remove()
				$("tr td.d br").remove()
	describe ".appendText()", ->
		it "appends plain text", ->
			try
				assert.equal($("tr td.d").appendText("Hi").html().first(), "3,2Hi")
			finally
				$("tr td.d").html("3,2")
	
	describe ".appendTo() appends nodes", ->
		it "to CSS selectors", ->
			try assert.equal($("<span>Hi</span>").appendTo("tr td.d").toRepr(), "$([<span>Hi</span>])")
			finally $("tr td.d span").remove()
		it "to Blings", ->
			try assert.equal($("<span>Hi</span>").appendTo($ "tr td.d").toRepr(), "$([<span>Hi</span>])")
			finally $("tr td.d span").remove()
		it "to HTML", ->
			assert.equal($("<span>Hi</span>").appendTo("<div></div>").select('parentNode').toRepr(), "$([<div><span>Hi</span></div>])")
		it "always at the end", ->
			try assert.equal($("<span>Hi</span>").appendTo("tr td.d").select('parentNode').toRepr(), '$([<td class="d">3,2<span>Hi</span></td>])')
			finally $("tr td.d span").remove()
	describe ".prepend(x)", ->
		it "makes x the first child of this", ->
			try assert.equal $("tr td.d").prepend("<span>Hi</span>").html().first(),
				"<span>Hi</span>3,2"
			finally $("tr td.d span").remove()
	describe ".prependTo(x)", ->
		it "makes this the first child of x", ->
			try assert.equal $("<span>Hi</span>").prependTo("tr td.d").select('parentNode').html().first(),
				"<span>Hi</span>3,2"
			finally $("tr td.d span").remove()
	it "before", -> assert.equal($("<a><b></b></a>").find("b").before("<c></c>").select('parentNode').toRepr(), "$([<a><c/><b/></a>])")
	it "after1", -> assert.equal($("<a><b></b></a>").find("b").after("<c></c>").select('parentNode').toRepr(), "$([<a><b/><c/></a>])")
	it "after2", -> assert.equal($("<b></b>").after("<c></c>").select('parentNode').toRepr(), "$([<b/><c/>])")
	it "wrap", -> assert.equal($("<b></b>").wrap("<a></a>").select('parentNode').toRepr(), "$([<a><b/></a>])")
	it "unwrap", -> assert.equal($("<a><b/></a>").find("b").unwrap().first().parentNode, null)
	it "replace", -> assert.equal($("<a><b/><c/><b/></a>").find("b").replace("<p/>").eq(0).select('parentNode').toRepr(), "$([<a><p/><c/><p/></a>])")
	describe ".attr()", ->
		it "can read attributes from DOM nodes", ->
			assert.equal "#", $("<a href='#'></a>").attr("href").first()
		it "can read attributes with complicated names", ->
			assert.equal "#", $("<a data-lazy-href='#'></a>").attr("data-lazy-href").first()
		it "can set attributes", ->
			assert.equal "new", $("<a data-lazy-href='#'></a>").attr("data-lazy-href","new").attr("data-lazy-href").first()
		it "can set multiple attributes at once", ->
			node = $("<a lazy-href='/home'></a>")
			node.attr {
				"lazy-href": "/away"
				"color": "yellow"
			}
			assert.equal node.attr("lazy-href").first(), "/away"
			assert.equal node.attr("color").first(), "yellow"
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

	describe ".synth()", ->
		it "creates DOM nodes", ->
			assert $.is 'node', $.synth('div').first()
		it "uses CSS-like selectors", ->
			assert.equal $.synth('div.cls#id[a=b][c=d] span p "text"').first().toString(), '<div id="id" class="cls" a="b" c="d"><span><p>text</p></span></div>'
		describe "supports CSS selectors:", ->
			it "id", -> assert.equal $.synth('div#id').first().id, "id"
			it "class", -> assert.equal $.synth('div.cls').first().className, "cls"
			it "multiple classes", ->
				assert.equal $.synth('div.clsA.clsB').first().className, "clsA clsB"
			it "attributes", -> assert.equal $.synth('div[foo=bar]').first().attributes.foo, "bar"
			it "attributes (multiple)", -> assert.deepEqual $.synth('div[a=b][c=d]').first().attributes, {a:'b',c:'d'}
			it "text (single quotes)", -> assert.equal $.synth("div 'text'").first().toString(), "<div>text</div>"
			it "text (double quotes)", -> assert.equal $.synth('div "text"').first().toString(), "<div>text</div>"
			it "entity escaped", -> assert.equal $.synth('div "text&amp;stuff"').first().toString(), "<div>text&amp;stuff</div>"
			it "entity un-escaped", -> assert.equal $.synth('div "text&stuff"').first().toString(), "<div>text&stuff</div>"
		it "accepts multiline templates", ->
			assert.equal $.synth("""
				div.clsA[type=text]
					p + span
				b 'Hello'
			""").first().toString(), '<div class="clsA" type="text"><p/><span><b>Hello</b></span></div>'

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
	
	describe ".css()", ->
		it "accepts a single argument", ->
			assert.deepEqual $('td').css('width'), $.zeros(8).map -> ''
		it "sets when called with two arguments", ->
			$("td").css("width", "100px")
			assert.deepEqual $('td').css('width'), $.zeros(8).map -> '100px'
		
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
