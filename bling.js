/* bling.js
 * --------
 * Named after the bling! operator ($), this is a jQuery-like framework,
 * using any and all WebKit specific hacks that we can.
 * All other browsers play at your own risk.
 */

var $ = (function() {
	// define inheritance
	Function.prototype.inheritsFrom = function(b) {
		this.prototype = new b();
		this.prototype.constructor = this;
		return this;
	}

	// define testing hooks
	// any function can be tested inline
	// function f() { ... }.test(function() { ... }) === f
	// f.test().test() === f
	var tests = []
	Function.prototype.test = function(f) {
		var t = this;
		tests.push(function() { 
			try { f.call(t) } catch ( e ) {
				throw new Error(["test",f,"failed on target",t,"with error",unescape(e)].join(" "));
			}
		});
		return this;
	}

	// define our asserts for use in tests
	function assert(a, msg) {
		assertEqual(!(a), false, msg)
	}
	function assertEqual(a, b, msg) {
		if( a != b ) throw new Error("assertion error: "+escape(a)+" != "+escape(b)+" "+ msg)
	}
	function isType(a,b) {
		return a.__proto__.constructor == b
	}
	function isString(a) { return isType(a, String); }
	function isNumber(a) { return isType(a, Number); }
	function isNode(a)   { return a.nodeType < 13 && a.nodeType > 0; }
	function isBling(a)  { return isType(a, Bling); }

	var Bling = function (expr, context) {
		context = context || document;
		this.initFrom = function(s) {
			Array.apply(this, [s.length])
			this.copyFrom(s)
		}
		this.copyFrom = function(s, n) {
			for( var i = 0; i < (n ? Math.min(s.length,n) : s.length); i++)
				this.push(s[i])
		}
		if( typeof(expr) == "string" ) {
			if( expr[0] == "<" ) {
				var d = document.createElement("div");
				d.innerHTML = expr;
				this.initFrom(d.childNodes)
				this.forEach(function(x) { 
					if( x.parentNode ) {
						x.parentNode.removeChild(x);
						x.parentNode = null; 
					}
				});
			} else {
				if( context.each != undefined ) {
					Array.apply(this, [])
					var t = this;
					context.each(function() {
						t.copyFrom(this.querySelectorAll(expr))
					});
				} else {
					this.initFrom(context.querySelectorAll(expr))
				}
			}
		} else if( typeof(expr) == "number" ) {
			Array.apply(this, [expr]);
		} else if( expr ) {
			if( isBling(expr) )
				return expr;
			if( expr.length != undefined ) {
				Array.apply(this, [expr.length]);
				for( var i = 0; i < expr.length; i++) {
					this.push( expr[i] )
				}
			} else {
				Array.apply(this, [1]);
				this.push( expr );
			}
		} else {
			Array.apply(this, []);
		}
	}
	.test(function() { assertEqual(new Bling("<a /><a /><a />").length, 3) })
	.test(function() { assertEqual(new Bling("<div><div /><div /></div>").length, 1) })
	.test(function() { assertEqual(new Bling([1, 2, 3]).length, 3) })
	.test(function() { assertEqual(new Bling(100).length, 0) })
	.test(function() { assertEqual(new Bling({a:'b'}).length, 1) })
	.test(function() { assertEqual(new Bling("<div id='a'><div id='b' /><div id='c' /></div>").zip('id').toString(), '["a"]') })
	.test(function() { assertEqual(new Bling("div", new Bling("<div id='a'><div id='b' /><div id='c' /></div>")).zip('id').toString(), '["b", "c"]') })
	.inheritsFrom(Array);

	Bling.version = "0";
	// public is the operator we give out, as $ usually
	// it can also be thought of as the public scope,
	// as it is the only namespace that survives the script
	Bling.public = function(e,c) { return new Bling(e,c); }
	Bling.public.runAllTests = function() {
		var i = tests.length
		for(; tests.length; tests.shift()() ) {}
		return i
	}

	// .extend() extend will merge values from b into a
	// if c is present, it should be a list of the field names to limit the merging to
	Bling.extend = function(a, b, c) {
		for( var i in b ) {
			if( c && a[i] != undefined )
				for( var j in c )
					a[i][j] = b[i][j]
			else
				a[i] = b[i];
		}
	}

	// .plugin() is how you add functionality to Bling
	// methods - a dict, each key is a method name,
	// each value should be a method that takes a bling as 'this'
	// and returns a bling
	Bling.plugin = function (methods) { 
		if( methods ) {
			Bling.extend(Bling.prototype, methods)
		}
	}
	// .globals() is how a plugin provides new global functions
	// like $.rgb
	Bling.globals = function (globals) {
		if( globals ) {
			Bling.extend(Bling, globals)
			Bling.extend(Bling.public, globals)
		}
	}

	// expose some static methods to the public
	Bling.extend(Bling.public, Bling, ['version', 'extend', 'plugin']);

	Bling.globals({ /// Core Globals
		// .dumpText() produces a human readable plain-text view of an object
		dumpText: function(obj, indent) {
			var s = "";
			indent = indent || "";
			if( typeof(obj) == "object" ) {
				var s = "{\n";
				indent = indent + "\t";
				for( var k in obj ) {
					var v = undefined;
					try {
						v = obj[k];
					} catch ( err ) { console.log(k, err); }
					s += indent + k + ":" + " " + Bling.dumpText(v, indent) + ",\n";
				}
				indent = indent.slice(1);
				s += indent + "}";
			} else if( typeof(obj) == "string" ) {
				s += '"' + obj + '"';
			} else if( typeof(obj) == "function" ) {
				var t = "" + obj;
				s += t.slice(0, t.indexOf("\n")) + " ... }";
			} else {
				s += "" + obj;
			}
			return s;
		}
			.test(function() { assertEqual( this({a: 'b'}), '{\n\ta: "b",\n}'); })
			.test(function() { assertEqual( this("a"), '"a"') })
		,
		// .dump() produces a human readable html view of an object
		dump: function(obj) {
			return Bling.dumpText(obj).replace(/(?:\r|\n)+/g,"<br>").replace(/\t/g,"&nbsp;&nbsp;");
		},
	});
	Bling.plugin({ /// Core Methods
		// define a functional basis: each, map, and reduce
		// these act like the native forEach, map, and reduce, except they respect the context of the Bling
		// so the 'this' value in the callback f is always set to the item being processed
		each: function(f) {
			this.forEach(function(t) {
				f.call(t, t);
			});
			return this;
		}
			.test(function() {
				var visit = {3: 2, 2: 3, 1: 1};
				var b = new Bling([1,2,3,2,3,2]);
				this.call(b, function() {
					visit[this] -= 1;
				});
				assertEqual(visit[1], 0);
				assertEqual(visit[2], 0);
				assertEqual(visit[3], 0);
			})
		,
		map: function(f) {
			return new Bling(Array.prototype.map.call(this, function(t) {
				return f.call(t, t);
			}));
		}
			.test(function() {
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
		,
		reduce: function(f) {
			// along with respecting the context, we pass only the accumulation + 1 item
			// so you can use functions like Math.min directly $(numbers).reduce(Math.min)
			// this fails with the default reduce, since Math.min(a,x,i,items) is NaN
			if( this.length == 0 ) return null;
			return Array.prototype.reduce.call(this, function(a, x) {
				return f.apply(x, [a, x]);
			})
		}
			.test(function() {
				var b = new Bling(["a", "b", "c"]);
				assertEqual(b.reduce(function(a){ return this + a; }), "cba");
				assertEqual(new Bling().reduce(function(a){ return this + a; }), undefined);
			})
		,
		// zip(p) returns a list of the values of property p from each node
		zip: function(p) { // zip("a.b") -> zip("a").zip("b")
			var i = p.indexOf(".")
			return i > -1 ? this.zip(p.substr(0, i)).zip(p.substr(i+1))
			: this.map(function() { return this[p] }); 
		}
			.test(function() {
				var b = new Bling(["one", "two", "three"]);
				var c = this.call(b, 'length');
				assertEqual(c[0], 3);
				assertEqual(c[1], 3);
				assertEqual(c[2], 5);
			})
		,
		// zap(p, v) sets property p to value v on all nodes in the list
		zap: function(p, v) { // zap("a.b") -> zip("a").zap("b")
			var i = p.indexOf(".")
			return i > -1 ? this.zip(p.substr(0, i)).zap(p.substr(i+1))
				: this.each(function() { this[p] = v }) 
		}
			.test(function() {
				var b = new Bling([{a:0}, {a:1}, {a:2}]);
				b.zap('a',3);
				assertEqual(b[0].a, 3);
				assertEqual(b[1].a, 3);
				assertEqual(b[2].a, 3);
			})
		,
		// take(n) trims the list to only the first n elements
		take: function(n) {
			n = Math.min(n, this.length);
			var a = new Bling(n);
			for( var i = 0; i < n; i++)
				a.push( this[i] )
			return a;
		}
			.test(function() {
				var c = new Bling([1,2,3,4,5]).take(3);
				assertEqual(c.length, 3);
				assertEqual(c[3], undefined);
			})
		,
		// skip(n) skips the first n elements in the list
		skip: function(n) {
			var a = new Bling( Math.max(0,this.length - n) );
			for( var i = 0; i < this.length - n; i++)
				a.push(this[i+n])
			return a;
		}
			.test(function() {
				var b = new Bling([1,2,3,4,5]).skip(2);
				assertEqual(b.length, 3);
				assertEqual(b[0], 3);
				assertEqual(b[2], 5);
				assertEqual(b[3], undefined);
			})
		,
		// .last(n) returns the last n elements in the list
		// if n is not passed, returned just the item (no bling)
		last: function(n) { return n ? this.skip(Math.max(0,this.length - n)) : this.skip(this.length - 1)[0] }
			.test(function() {
				var b = new Bling([1,2,3,4,5]);
				assertEqual(b.last(), 5);
				var c = b.last(2);
				assertEqual(c.length, 2);
				assertEqual(c[0], 4);
				assertEqual(c[1], 5);
			})
		,
		// .first(n) returns the first n elements in the list
		// if n is not passed, returned just the item (no bling)
		first: function(n) { return n ? this.take(n) : this[0] }
			.test(function() {
				var b = new Bling([1,2,3,4,5]);
				assertEqual(b.first(), 1);
				assertEqual(b.first(2).join(", "), "1, 2");
			})
		,
		// .join() concatenates all items in the list using sep
		join: function(sep) {
			return this.reduce(function(j) {
				return j + sep + this;
			});
		}
			.test(function() {
				var b = new Bling([1,2,3,4,5]);
				assertEqual(b.join(", "), "1, 2, 3, 4, 5");
			})
		,
		// .slice(start, end) returns a contiguous subset of elements
		// the end-th item will not be included - the slice(0,2) will contain items 0, and 1.
		slice: function(start, end) { return this.take(end).skip(start); }
			.test(function() {
				var b = new Bling([1,2,3,4,5,6,7,8]);
				var c = b.slice(2,4).join("");
				var d = b.slice(4,6).join("");
				assertEqual(c, "34");
				assertEqual(d, "56");
			})
		,

		// .weave() takes the given array and interleaves it in this array
		weave: function(a) {
			var b = new Bling(this.length + a.length);
			b.length = this.length + a.length;
			// first spread out this list, from back to front
			for(var i = this.length - 1; i >= 0; i-- ) {
				b[(i*2)+1] = this[i];
			}
			// then interleave the source items, from front to back
			for(var i = 0; i < a.length; i++) {
				b[i*2] = a[i];
			}
			// this is not quite a perfect implementation, really it should check which is longer
			// and only interleave equal length arrays, then append any leftovers
			// so that unequal length arguments will not create 'undefined' items
			return b;
		}
			.test(function() { 
				assertEqual(new Bling([1,2,3]).weave(new Bling(["a","b","c"])).join(""), "a1b2c3") 
			})
		,

		// various common ways to map/reduce blings
		toString: function() { return "["+this.map(Bling.dumpText).join(", ")+"]" }
			.test(function() { assertEqual(new Bling([1,2,3,4,5]).toString(), "[1, 2, 3, 4, 5]") })
			.test(function() { assertEqual(new Bling(["a","b"]).toString(), '["a", "b"]') })
		,
		floats:    function()  { return this.map(parseFloat) }
			.test(function() { assertEqual(new Bling([1, "3.5", "200px"]).floats().join(", "), "1, 3.5, 200"); })
		,
		ints:      function()  { return this.map(parseInt) }
			.test(function() { assertEqual(new Bling([1, "3.5", "200px"]).ints().join(", "), "1, 3, 200"); })
		,
		squares:   function()  { return this.map(function() { return this * this })}
			.test(function() { assertEqual(new Bling([1, 2, 3]).squares().join(", "), "1, 4, 9"); })
		,
		sum:       function()  { return this.reduce(function(x) { return x + this })}
			.test(function() { assertEqual(new Bling([1, 2, 3, 4]).sum(), 10); })
		,
		max:       function()  { return this.reduce(Math.max) }
			.test(function() { assertEqual(new Bling([1, 2, 3, 4]).max(), 4); })
		,
		min:       function()  { return this.reduce(Math.min) }
			.test(function() { assertEqual(new Bling([1, 2, 3, 4]).min(), 1); })
		,
		average:   function()  { return this.sum() / this.length }
			.test(function() { assertEqual(new Bling([1, 2, 3, 4]).average(), 2.5); })
		,
		magnitude: function()  { return Math.sqrt(this.squares().sum()) }
			.test(function() { assertEqual(new Bling([1, 2, 3]).magnitude(), Math.sqrt(14)); })
		,
		scale:     function(n) { return this.map(function() { return n * this })}
			.test(function() { assertEqual(new Bling([1, 2, 3]).scale(2).join(", "), "2, 4, 6") })
		,

		// try to continue using f in the same scope after about n milliseconds
		future: function(n, f) {
			var t = this;
			if( f ) setTimeout(function() { f.call(t); }, n);
			return this;
		}
			.test(function() {
				var b = new Bling([1,2,3,4,5])
					// spawn a future chain, pointed at b's current state
					.future(0, function() { 
						// in the future, we will see the old b
						assertEqual(this.length, 5);
					})
					// back in the past, modify b
					.last(2);
				// and before the future, verify that our local b has changed
				assertEqual(b.length, 2);
			})
		,
	})

	/// HTML/DOM Manipulation  Plugin ///
	Bling.globals( { 
		// $.rgb() accepts a color in any css format
		// returns a 3-item bling with the floating point rgb values
		// or the empty-set if it doesn't parse as a css color
		rgb: function(expr) { 
			var d = document.createElement("div");
			d.style.color = expr;
			var rgb = d.style.getPropertyValue('color');
			if( rgb )
				return new Bling( rgb.slice(rgb.indexOf('(')+1, rgb.indexOf(')')) .split(", ")).floats()
			return new Bling();
		}
			.test(function() { assert(isBling(this("#aaa"))) })
			.test(function() { assertEqual(this("#aaa").rgb(), "rgb(170, 170, 170)") })
		,
	});
	Bling.plugin( {
		// .html() gets/sets the .innerHTML of all elements in list
		html: function(h) { return h ? this.zap('innerHTML', h) : this.zip('innerHTML') }
			.test(function() {
				var h = '<p class="foo">This is a paragraph.</p>';
				var b = new Bling("<div>"+h+"</div>");
				assertEqual(b.html().first(), h);
			}),
		// .append() puts some content (bling,html,etc) at the end of each's children
		append: function(x) { 
			return isBling(x) ? this.each(function(ti){ x.each(function(xi){ ti.appendChild(xi) }) })
			: isNode(x) ? this.each(function(){ this.appendChild(x) })
			: this.append(new Bling(x))
		}
			.test(function() { assertEqual(new Bling("<div></div>").append(new Bling("<p>")).child(0).zip('nodeName').join(" "), "P") })
			.test(function() { assertEqual(new Bling("<div></div>").append("<p>").child(0).zip('nodeName').join(" "), "P") })
		,
		// .insertInto() is the other side of .append(), the only difference is which set is returned
		insertInto: function(x) { 
			var t = this;
			isBling(x) ? x.append(this)
				: new Bling(x).append(this)
			return this;
		}
			.test(function() { 
				assertEqual(new Bling("<p>").insertInto(new Bling("<div id='a'></div>")).zip('parentNode.id').join(" "), "a") 
			})
		,
		// .text() gets/sets the .innerText of all elements
		text: function(t) { return t ? this.zap('innerText', t) : this.zip('innerText') }
			.test(function() {
				var h = "<p class='foo'>This is a paragraph.</p>";
				var b = new Bling("<div>"+h+"</div>");
				assertEqual(b.text().first(), "This is a paragraph.");
			})
		,
		// .val() gets/sets the values of the nodes in the list
		val: function(v) { return v ? this.zap('value', v) : this.zip('value') }
			.test(function() {
				var b = new Bling("<input value='1'><input value='2'><select><option>3</option><option>4</option></select>");
				assertEqual(b.val().join(", "), "1, 2, 3");
			})
		,
		// .height() gets the height of the tallest item in the set [RO]
		height: function() { return this.zip('scrollHeight').max(); }
			.test(function() {
			})
		,
		// .width() gets the width of the widest item in the set [RO]
		width: function() { return this.zip('scrollWidth').max(); }
			.test(function() {
			})
		,
		// .css(k,v) gets/sets css properties for every node in the list
		css: function(k,v) { return v ? this.each(function() { this.style.setProperty(k, v); })
			: this.map(function() { return this.style.getPropertyValue(k) })
		}
			.test(function() {
				var d = new Bling("<div />");
				assertEqual(d.css('background-color').first(), undefined);
				d.css('background-color', '#ffffff');
				assertEqual(d.css('background-color').first(), 'rgb(255, 255, 255)');
			})
		,
		// .rgb() returns a css color string... 
		rgb: function() {
			return this.length == 4 ? "rgba("+this.join(", ")+")"
				: this.length == 3 ? "rgb("+this.join(", ")+")"
				: undefined;
		}
			.test(function() { assertEqual(Bling.rgb("#343434").scale(2).rgb(), "rgb(104, 104, 104)") })
			.test(function() { assertEqual(new Bling([1, 2, 3]).rgb(), "rgb(1, 2, 3)") })
			.test(function() { assertEqual(new Bling([1, 2, 3, .5]).rgb(), "rgba(1, 2, 3, 0.5)") })
			.test(function() { assertEqual(new Bling(["foo"]).rgb(), undefined) })
		,
		// .child(n) returns the nth childNode for all items in the set
		child: function(n) { return this.map(function() { return this.childNodes[n] })}
			.test(function() {
				var d = new Bling("<div><p><span>here.</span></p></div>");
				assertEqual(d.child(0).zip('nodeName').join(", "), "P");
				assertEqual(d.child(0).child(0).zip('nodeName').join(", "), "SPAN");
			})
		,
		// .parent() returns the parentNodes of all items in the set
		parent: function() { return this.zip('parentNode') }
			.test(function() {
				var d = new Bling("<div><p><span>here.</span></p></div>");
				assertEqual(d.parent().first(), null);
				assertEqual(d.child(0).parent().first().nodeName, "DIV");
			})
		,
		// .parents() returns all the parentNodes up to the owner for each item
		parents: function() {
			return this.map(function() {
				var b = $([]);
				var p = this.parentNode;
				while( p ) {
					b.push(p);
					p = p.parentNode;
				}
				return b;
			})
		}
			.test(function() {
				assertEqual( 
					new Bling("span", new Bling("<div><p><span>here.</span></p></div>"))
						.parents().first()
						.zip('nodeName')
						.join(", "), 
					"P, DIV");
			})
		,
		// .remove() removes each node from the DOM
		remove: function() {
			return this.each(function(){
				if( this.parentNode ) {
					this.parentNode.removeChild(this);
					this.parentNode = null;
				}
			});
		}
			.test(function() { assertEqual(new Bling("<p>").insertInto("<div>").remove().zip('parentNode').first(), null) })
		,

	})

	/// Events ///
	Bling.plugin( {
		// bind an event handler, evt is a string, like 'click'
		bind: function(evt, f) {
			return this.each(function() {
				this.addEventListener(evt, f, false);
			})
		},
		// unbind an event handler, f is optional, evt is a string, like 'click'.
		unbind: function(evt, f) {
			return this.each(function() {
				this.removeEventListener(evt, f);
			})
		},
		// fire a fake event on each node
		trigger: function(evt) {
			var e = document.createEvent("Events");
			// TODO: this should branch on evt, and use initMouseEvent, etc when appropriate
			e.initEvent(evt);
			return this.each(function() {
				this.dispatchEvent(e);
			})
		},
	});

	/// Transformations and Animations ///
	Bling.plugin( {
		// how long are various speeds
		duration: function(speed) {
			var speeds = {
				"slow": 700,
				"medium": 500,
				"normal": 300,
				"fast": 100,
			}
			var s = speeds[speed]
			var ret = s ? s : parseFloat(speed);
			return ret;
		}
		.test(function() {
			assertEqual( this("slow"), 700 );
			assertEqual( this("fast"), 100 );
			assertEqual( this(1000), 1000 );
		}),

		// like jquery's animate(), only we try to use webkit-transition/transform wherever possible
		transform: function(end_css, speed, callback) {
			if( typeof(speed) == "function" ) {
				callback = speed
				speed = undefined
			}
			speed = speed || "normal";
			var duration = this.duration(speed);
			// collect the list of properties to be modified
			var props = [];
			// whether and what to send the -webkit-transform
			var transform = "";
			// real css values to be set (end_css minus the transform values)
			var css = {};
			for( var i in end_css ) {
				// pull all the transform values out of end_css
				if( /(?:scale|translate|rotate|scale3d|translateX|translateY|translateZ|translate3d|rotateX|rotateY|rotateZ|rotate3d)/.test(i) )
					transform += " " + i + "(" + end_css[i].join(", ") + ")";
				else // stick real css values in the css dict
					css[i] = end_css[i];
			}
			// make a list of the properties to be modified
			for( var i in css ) {
				props.push(i);
			}
			// and include -webkit-transform if we have data there
			if( transform )
				props.push("-webkit-transform")
			this.css('-webkit-transition-property', props.join(', '));
			// repeat the duration the same number of times as there are properties
			this.css('-webkit-transition-duration', props.map(function() { return duration + "ms" }).join(', '));
			// apply the real css
			for( var i in css ) {
				this.css(i, css[i])
			}
			// apply the transformation
			if( transform ) {
				this.css('-webkit-transform', transform);
			}
			return this.future(duration, callback);
		},

		hide: function(callback) {
			return this.each(function() {
				this._display = this.style.display != "none" ? this.style.display : undefined;
				this.style.display = 'none';
			}).future(0, callback);
		},

		show: function(callback) {
			return this.each(function() {
				this.style.display = this._display ? this._display : "";
				this._display = undefined;
			}).future(0, callback)
		},

		fadeIn: function(speed, callback) { 
			return this
				.css('opacity','0.0')
				.show(function(){this
					.transform({opacity:"1.0", translate3d:[0,0,0]}, speed, callback) 
				})
		},
		fadeOut:   function(speed, callback) { return this.transform({opacity:"0.0"}, speed, function() { this.hide(); if( callback ) callback.call(this) })},
		fadeLeft:  function(speed, callback) { return this.transform({opacity:"0.0", translate3d:["-"+this.width()+"px",0.0,0.0 ]}, speed, function() { this.hide(); if( callback ) callback.call(this) })},
		fadeRight: function(speed, callback) { return this.transform({opacity:"0.0", translate3d:[this.width()+"px",0.0,0.0     ]}, speed, function() { this.hide(); if( callback ) callback.call(this) })},
		fadeUp:    function(speed, callback) { return this.transform({opacity:"0.0", translate3d:[0.0,"-"+this.height()+"px",0.0]}, speed, function() { this.hide(); if( callback ) callback.call(this) })},
		fadeDown:  function(speed, callback) { return this.transform({opacity:"0.0", translate3d:[0.0,this.height()+"px",0.0    ]}, speed, function() { this.hide(); if( callback ) callback.call(this) })},
	})

	return Bling.public;
})()
