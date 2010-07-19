true == (function UnitTests() {

	// define a unit testing framework:
	// any function can be tested inline
	// function f() { ... }.test(function() { ... }) === f
	// f.test().test() === f
	var tests = []
	Function.prototype.test = function test(t) {
		var f = this
		tests.push({
			run: function run() {
				try { t.call(f); } catch ( e ) {
					this.error = e
					return false
				}
				return true
			},
			test: t,
			func: f,
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
		console.log("running",tests.length,"tests")
		var stub = {pass: 0, tested: 0, total: tests.length, failed: [], untested: [], covered: 0, public: 0}
		while(tests.length) {
			stub.tested += 1
			var f = tests.shift()
			if( f.run() )
				stub.pass += 1
			else
				stub.failed.push(f)
		}
		// report on code coverage
		var report = function report(obj) {
			for( var i in obj) {
				if( isFunc(obj[i]) ) {
					stub.public++
					if( obj[i].tested ) {
						stub.covered++
						if( obj[i].failed )
							stub.failed.push(i)
					} else
						stub.untested.push(i)
				}
			}
		}
		report(Bling)
		report(Bling.prototype)
		var score = Math.floor((stub.pass*100/stub.tested) * (stub.covered/stub.public))
		console.log("(covered/public * pass/tested) ("+stub.covered+"/"+stub.public+" * "+stub.pass+"/"+stub.tested+") == score:",score,"%")
		console.log("public and untested: ", stub.untested.join(", "))
		console.log("failed: ")
		for( var i = 0, nn = stub.failed.length; i < nn; i++) {
			var ii = stub.failed[i]
			console.log('function '+ii.test.name+'(...)', ii.error)
		}
		// once all the tests are done remove the hooks, just in case
		Function.prototype.test = undefined
	}

	// define our asserts for use in tests
	function assert(a, msg) {
		assertEqual(!(a), false, msg)
	}
	function assertEqual(a, b, msg) {
		if( a != b ) throw new Error("assertion error: "+(a)+" != "+(b)+" "+ msg)
	}

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
				var b = new Bling([1,2,3,4,5]);
				assertEqual(b.last(), 5);
				var c = b.last(2);
				assertEqual(c.length, 2);
				assertEqual(c[0], 4);
				assertEqual(c[1], 5);
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

	Bling.prototype.merge
		.test(function merge() {
			assertEqual(new Bling([ new Bling("<div>"), new Bling("<p>") ]).merge().zip('nodeName').join(" "), "DIV P")
		})

	Bling.rgb
		.test(function rgb() { assert(isBling(this("#aaa"))) })
		.test(function rgb2() { assertEqual(this("#aaa").rgb(), "rgb(170, 170, 170)") })

	Bling.prototype.rgb
		.test(function rgb3() { assertEqual(Bling.rgb("#343434").scale(2).rgb(), "rgb(104, 104, 104)") })
		.test(function rgb4() { assertEqual(new Bling([1, 2, 3]).rgb(), "rgb(1, 2, 3)") })
		.test(function rgb5() { assertEqual(new Bling([1, 2, 3, .5]).rgb(), "rgba(1, 2, 3, 0.5)") })
		.test(function rgb6() { assertEqual(new Bling(["foo"]).rgb(), undefined) })

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
			new Bling("<div style='background-color:transparent;' />")
				.appendTo("body")
				.future(0, function() { assertEqual(this.css('background-color').first(), 'rgba(0, 0, 0, 0)') })
				.future(1, function() { assertEqual(this.css('background-color', "#ffffff").css("background-color").first(), "rgb(255, 255, 255)") })
				.future(2, function() { this.remove() })
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
			$.http("bling.test.js", function(data){ assertEqual(this.status, 200); });
		})
		.test(function http2() {
			var expectedState = 2;
			$.http("bling.test.js", {state: function() {
				assertEqual(this.readyState, expectedState++)
			}})
		})

	Bling.get.test(function http_get() {
			$.get("bling.test.js", function(data) { assertEqual(this.status, 200) })
		})

	Bling.post.test(function http_post() {
			$.post("bling.test.js", {
				data: {some:"fool data"},
				success: function() { assertEqual(this.status, 200) }
			})
		})

	// schedule the tests to run and clean themselves up
	new Bling(window).bind('load', runAllTests)

})()


