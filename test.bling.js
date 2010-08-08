true == (function UnitTests() {

	// define a unit testing framework:
	// any function can be tested inline
	// function f() { ... }.test(function() { ... }) === f
	// f.test().test() === f
	/*var*/ tests = {} // keys are functions to test, values are lists of test functions
	Function.prototype.test = function test(t) {
		var f = this
		tests[f] = tests[f] || []
		tests[f].push({
			run: function run() {
				try { t.call(f); } catch ( e ) {
					this.error = e
					return false
				}
				return true
			},
			test: t,
			func: f, // this implementation has circular references
			error: undefined,
		})
		f.tested = true
		return f
	}
	// first thing: test the test framework!
	Function.prototype.test.test(function testtest() {
		assert(true)
	})
	function runAllTests() {
		$(document.body).future(0, function() {
			var stub = {passed:[], tested: 0, total: 0, failed: [], untested: [], covered: 0, public: 0}
			// iterate over all functions with tests
			for( var f in tests ) {
				stub.tested++;
				// get the testing set
				var set = tests[f]
				// run all the tests in the set
				for( var j = 0, nn = set.length; j < nn; j++ ) {
					stub.total++;
					var test = set[j]
					if( test.run() ) stub.passed.push(test)
					else stub.failed.push(test)
				}
			}
			var report = function report(obj) {
				for( var i in obj) {
					if( isFunc(obj[i]) ) {
						stub.public++
						if( obj[i].tested ) {
							stub.covered++
						} else
							stub.untested.push(i)
					}
				}
			}
			report(Bling)
			report(Bling.prototype)
			var score = Math.floor((stub.passed.length*100/stub.total) * (stub.covered/stub.public))
			var toggle = "style='cursor:pointer' onclick='event.stopPropagation();this.style.height = this.style.height == \"auto\" ? \"20px\" : \"auto\"'"
			var report_html = "<div id='code-report'><span class='score'>Score: "+score+"%</span>"
				+"<div>(covered/public * pass/total)</div>"
				+"<div>("+stub.covered+"/"+stub.public+" * "+stub.passed.length+"/"+stub.total+")</div>"
				+"<ul>"
				+"<li "+toggle+">untested ("+stub.untested.length+"):<ul>"
				+"<li>"
				+ stub.untested.join("</li><li>") 
				+ "</li></ul></li>"
				+"<li "+toggle+">failed("+stub.failed.length+"):<ul>";
			for( var i = 0, nn = stub.failed.length; i < nn; i++) {
				var ii = stub.failed[i]
				report_html += "<li class='fail' "+toggle+">function "+ii.test.name+"(...)"+ii.error+"</li>"
			}
			report_html += "</ul></li><li "+toggle+">passed("+stub.passed.length+"):<ul>"
			for( var i = 0, nn = stub.passed.length; i < nn; i++) {
				var ii = stub.passed[i]
				report_html += "<li class='pass' style='height:30px;' onclick='event.stopPropagation();this.style.height = this.style.height == \"auto\" ? \"30px\" : \"auto\"'><pre>"+Function.HtmlEscape(ii.test.toString())+"</pre></li>"
			}
			report_html += "</ul></li></ul></div>"
			this.zap('innerHTML',report_html);
		})
	}

		// define our asserts for use in tests
		function assert(a, msg) {
			assertEqual(!(a), false, msg)
		}
		function assertEqual(a, b, msg) {
			if( a != b ) throw new Error("assertion error: "+(a)+" != "+(b)+" "+ msg)
		}
		function assertFloatEqual(a, b, msg) {
			return assert( (1-(a/b)) < .001, msg)
		}

		isString.test(function isStringTest(){
			assert(isString("foo"))
		})

		isNumber.test(function isNumberTest(){
			assert(isNumber(1.0), "proto: " + Bling.dumpHtml((1.0).__proto__) + " <hr> " + ((1.0).__proto__ == Number.prototype))
		})

		isFunc.test(function isFuncTest() {
			assert(isFunc(Function.Empty))
		}).test(function isFuncTestTwo() {
			assert(isFunc(function(){}))
		}).test(function isFuncTestThree() {
			assert(!isFunc("function (){}"))
		})

		isNode.test(function isNodeTest() {
			assert(isNode(document.body))
		})

		isFragment.test(function isFragmentTest() {
			var df = document.createDocumentFragment()
			assert(isFragment(df))
		})

		// register some tests for basic Bling creation
		Bling.test(function BlingEmpty() { /* bling can be empty */
			assertEqual(new Bling().length, 0)
		})
		.test(function BlingFromHtml() { /* bling can create new html */
			assertEqual(new Bling("<div><p><p><p></div>").zip('nodeName').join(" "), "DIV");
		})
		.test(function BlingFromFragment() { /* the html does not need to be well formed at all, you will just get a fragment in return */
			var b = new Bling("<a><a><a>");
			assertEqual(b.zip('nodeName').join(" "), "#document-fragment")
		})
		.test(function BlingFromList() { /* blings can hold anything if you give a list */
			assertEqual(new Bling([1, "foo", 3.14]).join(" "), "1 foo 3.14")
		})
	.test(function BlingFromSize() { /* just a number: pre-allocate but dont fill */
		assertEqual(new Bling(100).length, 0)
	})
	.test(function BlingFromUnknown() {
		assertEqual(new Bling({a:'b'}).zip('a').join(""), "b")
	})
	.test(function BlingTestDivValue() { /* make sure the _right_ div is the one returned */
		assertEqual(new Bling("<div id='a'><div id='b' /><div id='c' /></div>").zip('id').join(" "), "a")
	})
	.test(function BlingWithContext() { /* create a bling using a context */
		assertEqual(new Bling("div", new Bling("<div id='a'><div id='b' /><div id='c' /></div>")).zip('id').toString(), 'Bling{[b, c]}')
	})

	// add tests for the most basic globals
	Bling.extend.test(function extend() {
		var a = {a: 0, c: 3}
		var b = {a: 1, b: 2}
		var c = Bling.extend(a,b)
		assertEqual(c['a'], 1)
		assertEqual(c['b'], 2)
		assertEqual(c['c'], 3)
	})

	Bling.addMethods.test(function addMethods() {
		Bling.addMethods({"nop": function nop(){ return this; }})
		assert(isFunc(Bling.prototype.nop))
		Bling.prototype.nop = undefined
	})

	Bling.addGlobals.test(function addGlobals() {
		Bling.addGlobals({"nop": function nop(x){ return x; }})
		assert(isFunc(Bling.nop))
		Bling.nop = undefined
	})

	Bling.bound.test(function bound() {
		var f = "abc".toUpperCase.bound("xyz")
		assertEqual(f(), "XYZ")
	})

	Bling.inheritsFrom.test(function inheritsFrom() {
		function NewType() {
			Bling.apply(this, [])
			this.newAttribute = 42;
		}
		NewType.inheritsFrom(Bling)
		var n = new NewType()
		assertEqual(n.newAttribute, 42)
		assertEqual(n.length, 0) // inherited from Bling, which inherits from Array
	})

	Bling.operator.test(function operator() {
		assert(isFunc(Bling.operator))
		assert(isBling(Bling.operator()))
	})

	Bling.__copy__.test(Function.Empty)
	Bling.__init__.test(Function.Empty)

	Bling.dumpText
		.test(function dumpText() { assertEqual( this({a: 'b'}), '{\n\ta: "b",\n}'); })
		.test(function dumpText() { assertEqual( this("a"), '"a"') })

	Bling.dumpHtml
		.test(function dumpHtml() { assertEqual( this({a: 'b'}), '{<br>&nbsp;&nbsp;a: "b",<br>}' ) })

	Bling.prototype.each
		.test(function each() {
			var visit = {3: 2, 2: 3, 1: 1};
			var b = new Bling([1,2,3,2,3,2]);
			b.each(function() {
				visit[this] -= 1;
			});
			assertEqual(visit[1], 0);
			assertEqual(visit[2], 0);
			assertEqual(visit[3], 0);
		})

	Bling.prototype.map
		.test(function map() {
			var b = new Bling([1,2,3,4,5]);
			var c = this.call(b, function() {
				return this * this;
			});
			assertEqual(b.length, c.length);
			for( var i = 0; i < c.length; i++) {
				assertEqual(b[i],i+1);
				assertEqual(c[i],(i+1)*(i+1));
			}
		})

	Bling.prototype.reduce
		.test(function reduce() {
			var b = new Bling(["a", "b", "c"]);
			assertEqual(b.reduce(function(a){ return this + a; }), "cba");
			assertEqual(new Bling().reduce(function(a){ return this + a; }), undefined);
		})

	Bling.prototype.filter
		.test(function filter() {
			assertEqual(new Bling([1,2,3,4,5,6,7,8,9,10]).filter(function() { return this % 2 == 0; }).join(" "), "2 4 6 8 10")
		})

	Bling.prototype.distinct
		.test(function distinct() {
			assertEqual(new Bling([1,2,1,3,4,5,2,3,3,2,1,1,4,5]).distinct().join(" "), "1 2 3 4 5")
		})
		.test(function distinct2() {
			var a = new Bling("<div>");
			a = a.concat(new Bling("body")).concat([a[0]])
			assertEqual(a.length, 3)
			assertEqual(a.distinct().length, 2)
		})

	Bling.prototype.zip
		.test(function zip() { assertEqual(new Bling(["one", "two", "three"]).zip('length').join(" "), "3 3 5"); })

	Bling.prototype.zap
			.test(function zap() {
				assertEqual(new Bling([{a:0}, {a:1}, {a:2}]).zap('a', 3).zip('a').join(" "), "3 3 3")
			})

	Bling.prototype.take
			.test(function take() {
				var c = new Bling([1,2,3,4,5]).take(3);
				assertEqual(c.length, 3);
				assertEqual(c[3], undefined);
			})

	Bling.prototype.skip
			.test(function skip() {
				var b = new Bling([1,2,3,4,5]).skip(2);
				assertEqual(b.length, 3);
				assertEqual(b[0], 3);
				assertEqual(b[2], 5);
				assertEqual(b[3], undefined);
			})

	Bling.prototype.last
			.test(function last() {
				assertEqual(new Bling([1,2,3,4,5]).last(), 5);
			})
			.test(function last2() {
				assertEqual(new Bling([1,2,3,4,5]).last(2).join(" "), "4 5");
			})

	Bling.prototype.first
			.test(function first() {
				var b = new Bling([1,2,3,4,5]);
				assertEqual(b.first(), 1);
				assertEqual(b.first(2).join(", "), "1, 2");
			})

	Bling.prototype.join
			.test(function join() { assertEqual(new Bling([1,2,3,4,5]).join(", "), "1, 2, 3, 4, 5") } )

	Bling.prototype.slice
		.test(function slice() {
			var b = new Bling([1,2,3,4,5,6,7,8]);
			assertEqual(b.slice(2,4).join(""), "34");
			assertEqual(b.slice(4,6).join(""), "56");
			assertEqual(b.slice(4).join(""), "5678");
			assertEqual(b.slice(4,-1).join(""), "567");
			assertEqual(b.slice(4,-2).join(""), "56");
		})

	Bling.prototype.concat
		.test(function concat(){ assertEqual(new Bling([1,2,3]).concat(new Bling([4,5,6])).join(""), "123456") })

	Bling.prototype.weave
		.test(function weave() {
			assertEqual(new Bling([1,2,3]).weave(new Bling(["a","b","c"])).join(""), "a1b2c3")
		})

	Bling.prototype.toString
		.test(function toString() { assertEqual(new Bling([1,2,3,4,5]).toString(), "Bling{[1, 2, 3, 4, 5]}") })
		.test(function toString2() { assertEqual(new Bling(["a","b"]).toString(), 'Bling{[a, b]}') })
		.test(function toString3() { assertEqual(new Bling([]).toString(), 'Bling{[]}') })

	Bling.prototype.floats
		.test(function floats() { assertEqual(new Bling([1, "3.5", "200px"]).floats().join(", "), "1, 3.5, 200"); })

	Bling.prototype.ints
		.test(function ints() { assertEqual(new Bling([1, "3.5", "200px"]).ints().join(", "), "1, 3, 200"); })

	Bling.prototype.squares
		.test(function squares() { assertEqual(new Bling([1, 2, 3]).squares().join(", "), "1, 4, 9"); })

	Bling.prototype.sum
		.test(function sum() { assertEqual(new Bling([1, 2, 3, 4]).sum(), 10); })

	Bling.prototype.max
		.test(function max() { assertEqual(new Bling([1, 2, 3, 4]).max(), 4); })

	Bling.prototype.min
		.test(function min() { assertEqual(new Bling([1, 2, 3, 4]).min(), 1); })

	Bling.prototype.average
		.test(function average() { assertEqual(new Bling([1, 2, 3, 4]).average(), 2.5); })

	Bling.prototype.magnitude
		.test(function magnitude() { assertEqual(new Bling([1, 2, 3]).magnitude(), Math.sqrt(14)); })

	Bling.prototype.scale
		.test(function scale() { assertEqual(new Bling([1, 2, 3]).scale(2).join(", "), "2, 4, 6") })

	Bling.prototype.call
		.test(function call() { assertEqual(new Bling(["a","b","c"]).zip('toUpperCase').call().join(""), "ABC") })
		.test(function call2() { assertEqual(new Bling(["a","b","c"]).zip('concat').call(".").join(""), "a.b.c.") })

	Bling.prototype.apply
		.test(function apply() { assertEqual(new Bling([String.prototype.toUpperCase]).apply("xyz").first(), "XYZ") })
		.test(function apply2() { assertEqual(new Bling([Array.prototype.join]).apply(["x","y","z"], ["."]).first(), "x.y.z") })

	Bling.prototype.future
		.test(function future() {
			var b = new Bling(['f','u','t','u','r','e'])
				// spawn a future chain, pointed at b's current state
				.future(0, function() {
					assert(isBling(this));
					// in the future, we will see the old b
					assertEqual(this.join(""), "future")
					this.pop() // remove one before the next future
				})
				// schedule several in a row close together, to test that order is preserved
				.future(1, function() {
					assert(isBling(this))
					assertEqual(this.join(""), "futur")
					this.pop() // remove another
				})
				.future(2, function() {
					assert(isBling(this))
					assertEqual(this.join(""), "futu")
				})
				// back in the past, modify b, grabbing only the last 2
				.last(2);
			// and before the future, verify that our local b has changed
			assertEqual(b.join(""), "re")
		})

	// Bling.prototype.rgb
		// .test(function rgb3() { assertEqual(Bling.rgb("#343434").scale(2).rgb(), "rgb(104, 104, 104)") })
		// .test(function rgb4() { assertEqual(new Bling([1, 2, 3]).rgb(), "rgb(1, 2, 3)") })
		// .test(function rgb5() { assertEqual(new Bling([1, 2, 3, .5]).rgb(), "rgba(1, 2, 3, 0.5)") })
		// .test(function rgb6() { assertEqual(new Bling(["foo"]).rgb(), undefined) })

	Bling.prototype.html
		.test(function html() {
			var h = '<p class="foo">This is a paragraph.</p>';
			var b = new Bling("<div>"+h+"</div>");
			assertEqual(b.html().first(), h);
		})

	Bling.prototype.append
		.test(function append() {
			assertEqual(new Bling("<div></div>").append(new Bling("<p>")).child(0).zip('nodeName').join(" "), "P")
		})
		.test(function append2() {
			assertEqual(new Bling("<div></div>").append("<p>").child(0).zip('nodeName').join(" "), "P")
		})

	Bling.prototype.appendTo
		.test(function appendTo() {
			assertEqual(new Bling("<p>").appendTo(new Bling("<div id='a'></div>")).zip('parentNode.id').join(" "), "a")
		})

	Bling.prototype.prepend
		.test(function prepend() {
			assertEqual(new Bling("<div><span>text</span></div>").prepend("<h1>headline</h1>")
				.child(0).zip('nodeName').join(" "), "H1")
		})

	Bling.prototype.prependTo
		.test(function prependTo() {
			assertEqual(new Bling("<h2>headline").prependTo("<div><span>text</span></div>")
				.zip('parentNode.nodeName').join(" "), "DIV")
		})

	Bling.prototype.before
		.test(function before() {
			var b = new Bling("<div><span>text</span></div>");
			b.find("span").before("<a>");
			assertEqual(b.children().merge().zip('nodeName').join(" "), "A SPAN")
		})

	Bling.prototype.after
		.test(function after() {
			var b = new Bling("<div><span>text</span></div>");
			var d = b.find("span").after("<a>");
			// check ordering
			assertEqual(b.children().merge().zip('nodeName').join(" "), "SPAN A");
			// check return value
			assertEqual(d.zip('nodeName').join(" "), "SPAN");
		})
	
	Bling.prototype.wrap
		.test(function wrap() {
			var b = new Bling("<a>link</a><span>text</span>");
			var d = b.wrap("<div>");
			// check the return value
			assertEqual(d.zip('nodeName').join(" "), "DIV")
			// check that the children are attached
			assertEqual(d.zip('childNodes').merge().zip('nodeName').join(" "), "A SPAN")
		})

	Bling.prototype.text
		.test(function text() {
			var h = "<p class='foo'>This is a paragraph.</p>";
			var b = new Bling("<div>"+h+"</div>");
			assertEqual(b.text().first(), "This is a paragraph.");
		})

	Bling.prototype.val
		.test(function val() {
			var b = new Bling("<input value='1'><input value='2'><select><option>3</option><option>4</option></select>");
			assertEqual(b.children().merge().val().join(", "), "1, 2, 3");
		})

	Bling.prototype.css
		.test(function css() {
			new Bling("<div id='cssTestDiv' style='background-color:transparent;' />")
				.appendTo("body")
				.future(10, function() { assertEqual(this.css('background-color').first(), 'transparent') })
				.future(11, function() { assertEqual(this.css('background-color', "#ffffff").css("background-color").first(), "rgb(255, 255, 255)", this.toString()) })
				.future(12, function() { this.remove() })
		})

	Bling.prototype.child
		.test(function child() {
			var d = new Bling("<div><p><span>here.</span></p></div>");
			assertEqual(d.child(0).zip('nodeName').join(", "), "P");
			assertEqual(d.child(0).child(0).zip('nodeName').join(", "), "SPAN");
		})
	
	Bling.prototype.children
		.test(function children() {
			var d = new Bling("<div><a></a><p></p><span></span></div>");
			assertEqual(d.children().merge().zip('nodeName').join(" "), "A P SPAN");
		})

	Bling.prototype.parent
		.test(function parent() {
			var d = new Bling("<div><p><span>here.</span></p></div>");
			assertEqual(d.parent().first(), null);
			assertEqual(d.child(0).parent().first().nodeName, "DIV");
		})

	Bling.prototype.parents
		.test(function parents() {
			assert(isBling(new Bling("<div><p><span>here</span></p></div>").find("span").parents().first()))
		})
		.test(function parents2() {
			assertEqual(
				new Bling("span", new Bling("<div><p><span>here.</span></p></div>"))
					.parents().first()
					.zip('nodeName')
					.join(", "),
				"P, DIV");
		})

	Bling.prototype.remove
		.test(function remove() {
			assertEqual(new Bling("<p>").appendTo("<div>").remove().zip('parentNode').first(), null)
		})

	Bling.prototype.find
		.test(function find(){
			assertEqual(new Bling("<div><p><span id='a'>text</span></div>").find("span").zip('id').join(" "), "a")
		})

	function eventtester(e) {
		return function eventtest() {
			var ret = false
			var handler = function(evt) { evt.preventDefault(); evt.stopPropagation(); ret = true }
			new Bling("<div id='a'></div>").bind(e, handler).trigger(e)
			assert(ret, "event: "+e+" did not fire in time")
		}
	}
	var events = [
		"click", "mousemove", "mousedown", "mouseup", "mouseover", "mouseout", "click", "blur", "focus", "load", "unload", "reset", "submit", "change", "abort", "cut", "copy", "paste", "selection", "drag", "drop", "orientationchange", "touchstart", "touchmove", "touchend", "touchcancel", "gesturestart", "gestureend", "gesturecancel",
	];
	for( var i = 0; i < events.length; i++) {
		Bling.prototype[events[i]].test(eventtester(events[i]))
	}


	Bling.duration
		.test(function duration() {
			assertEqual( this("slow"), 700 );
			assertEqual( this("fast"), 100 );
			assertEqual( this(1000), 1000 );
		})

	Bling.db
		.test(function db() { assert( isType( Bling.db()[0], "Database" ) ) })

	// TODO: these tests test nothing right now
	Bling.prototype.transaction
		.test(function transaction() {
			Bling.db()
				.transaction(function(t) {
					t.executeSql("create temp table foo ( id int primary key not null );")
				}, [], function(t, r) {
					console.log("create table",t, r)
				})
		})
		.test(function transaction2() {
			Bling.db()
				.transaction(function(t) {
					t.executeSql("insert into foo (id) values (?);")
				}, [42], function(t, r) {
					console.log("insert",t,r)
				})
		})
		.test(function transaction3() {
			Bling.db()
				.transaction(function(t) {
					t.executeSql("select id from foo;")
				}, [], function(t, r) {
					console.log("select",t, r)
				})
		})
		.test(function transaction4() {
			Bling.db()
				.transaction(function(t) {
					t.executeSql("drop table foo;")
				}, [], function(t, r) {
					console.log("drop",t, r)
				})
		})

	Bling.http
		.test(function http1() {
			$.http("test.bling.js", function(data){ assertEqual(this.status, 200); });
		})
		.test(function http2() {
			var lastState = 1, expectState = 2;
			$.http("test.bling.js", {state: function() {
				if( this.readyState == expectState ) expectState++
				else if( this.readyState == lastState ) expectState = lastState + 1
				else throw new Error("http test failed: wrong state " + this.readyState + " expected: " + lastState + " or " + expectState)
				lastState = this.readyState
			}})
		})

	Bling.get.test(function http_get() {
			$.get("test.bling.js", function(data) { assertEqual(this.status, 200) })
		})

	Bling.post.test(function http_post() {
			$.post("test.bling.js", {
				data: {some:"fool data"},
				success: function() { assertEqual(this.status, 200) }
			})
		})

/*
	Bling.prototype.hide.test(function hide(){
		var d = $("<div id='hideTestDiv'>cant see me!</div>")
		$("body").append(d)
		assertEqual(d[0].parentNode, document.body, "hide attached, no dupes")
		assert($("#hideTestDiv")[0] === d[0], "hide find finds the right node")
		$("#hideTestDiv").hide(function() {
			// console.log('in hide callback '+this.zip('guid')+" "+this.zip("parentNode.toString").call().join(" "))
			// console.log(this)
			try {
				assert(this[0] === d[0], "hide callback gets the right node")
				assertEqual(this.zip('id').join(" "), "hideTestDiv")
				assertEqual(this.parent().join(" "), "BODY", "hide test still attached 2: " + this.zip('parentNode').join(" "))
				assertEqual(this.css('display').join(" "), "none", "hide display ")
				assertEqual(this.css('opacity').join(" "), "0", "hide opacity ")
			} finally {
				this.remove()
			}
		})
	})
	*/

	Bling.prototype.show.test(function showTest(){
		// create an unattached div
		var d = $("<div id='showTestDiv' style='display:none'>show</div>")
		// find the body
		var b = $("body")
		// attach div to the bdy
		b.append(d)
		assertEqual(d.zip('parentNode').toString(), "Bling{[[object HTMLBodyElement]]}", 'd parent');
		// search for a div attached to the body
		var e = b.find("#showTestDiv")
		// verify that we found the exact node we inserted
		assert( d[0] === e[0], "single item wont be duped")
		// then show the found node
		e.show();
		assertEqual(e.zip('parentNode').toString(), "Bling{[[object HTMLBodyElement]]}", 'e parent');
		e.future(0, function() {
			try {
				// verify that the callback got a Bling of the exact same node
				assert(isBling(this), "this is bling")
				assertEqual(this.length, 1, "this length")
				assert( this[0] === d[0], "this callback did not recieve a duped node")
				// and verify that it has been shown
				assertEqual(this.zip('guid').toString(), "Bling{[11]}")
				assertEqual(this.zip('parentNode').toString(), "Bling{[[object HTMLBodyElement]]}", 'e parent after show')
				assertEqual(this.css('display').join(" "), "", "show display: "+this.zip('style.display'))
				assertEqual(this.css('opacity').join(" "), "1", "show opacity: ")
			} finally {
				this.remove()
			}
		})
	})

	/*
	Bling.prototype.fadeOut.test(function fadeOut(){
		$("body").append($("<div id='fadeOutTestDiv'>fadeOut</div>"))
		$("#fadeOutTestDiv").fadeOut(function() {
			assertEqual(this.css('opacity').join(", "), "0")
			this.remove()
		})
	})
	Bling.prototype.fadeIn.test(function fadeIn(){
		$("body").append($("<div id='fadeInTestDiv'>fadeIn</div>"))
		$("#fadeInTestDiv").fadeIn(function() {
			assertFloatEqual(this.css('opacity').floats().first(), 1.0)
			this.remove()
		})
	})
	Bling.prototype.fadeLeft.test(function fadeLeft(){
		$("body").append($("<div id='fadeLeftTestDiv'>fadeLeft</div>"))
		$("#fadeLeftTestDiv").fadeLeft(function() {
			assertEqual(this.css('opacity').join(", "), "0")
			this.remove()
		})
	})
	Bling.prototype.fadeRight.test(function fadeRight(){
		$("body").append($("<div id='fadeRightTestDiv'>fadeRight</div>"))
		$("#fadeRightTestDiv").fadeRight(function() {
			assertEqual(this.css('opacity').join(", "), "0")
			this.remove()
		})
	})
	Bling.prototype.fadeUp.test(function fadeUp(){
		$("body").append($("<div id='fadeUpTestDiv'>fadeUp</div>"))
		$("#fadeUpTestDiv").fadeUp("slow", function() {
			assertEqual(this.css('opacity').join(", "), "0")
			this.remove()
		})
	})
	Bling.prototype.fadeDown.test(function fadeDown(){
		$("body").append($("<div id='fadeDownTestDiv'>fadeDown</div>"))
		$("#fadeDownTestDiv").fadeDown(function() {
			assertEqual(this.css('opacity').join(", "), "0")
			this.remove()
		})
	})
	*/

	// schedule the tests to run on document load
	new Bling(window).bind('load', runAllTests)

})()


