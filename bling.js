/* bling.js
 * --------
 * Named after the bling! operator ($), this is a jQuery-like framework,
 * using any and all WebKit specific hacks that we can.
 * All other browsers play at your own risk.
 * Blame: Jesse Dailey <jesse.dailey@gmail.com>
 */

// first things first, javascript is missing some features

/* Inheritance
 * -----------
 * A.inheritsFrom(T) will make A inherit members from type T.
 * function MyType(){ Array.apply(this, arguments); }.inheritsFrom(Array)
 * var a = new MyType()
 * a.push("foo")
 */
Function.prototype.inheritsFrom = function(T) {
	this.prototype = new T()
	return this.prototype.constructor = this
}

/* Type Checking
 * -------------
 * Since we have a clear definition of inheritance, we can clearly detect
 * types and sub-types.
 * If you don't have a reference to the actual type,
 * you can pass the name as a string: isType(window, "DOMWindow") === true
 */
function isType(a,T) {
	return !a ? T === a
		: typeof(T) === "string" ? a.__proto__.constructor.name == T
			: a.__proto__.constructor === T
}
function isSubtype(a, T) {
	return a == undefined ? a == T
		: a.__proto__ == undefined ? false
		: a.__proto__.constructor == T ? true
		: isSubtype(a.__proto__, T)
}
function isString(a) { return isSubtype(a, String) }
function isNumber(a) { return isSubtype(a, Number) }
function isFunc(a)   { return isType(a, Function) }
function isNode(a)   { return isSubtype(a, Node) }

/* Function Binding
 * ----------------
 * This lets you bind the 'this' argument to a function at a separate time
 * from the actual call.
 *
 *   var stars = ["Ricky","Martin"]
 *   var num_stars = function () { return this.length; }.bound(stars)
 *   num_stars() == 2
 *
 * Where it can be most useful is extracting member functions from an instance
 * so you can call them directly, but they still act on the original instance.
 *
 *   var all_stars = stars.join.bound(stars)
 *   all_stars(", ") == "Ricky, Martin"
 *
 * You can also bind the arguments ahead of time if you know them:
 *
 *   all_stars = stars.join.bound(stars, [", "])
 *   all_stars() == "Ricky, Martin"
 *
 */
Function.prototype.bound = function(t, args) {
	var f = this
	var r = function() { return f.apply(t, args ? args: arguments) }
	r.toString = function() { return "bound-method of "+t+"."+f.name+"(...) { [code] }" }
	return r
}
// a useful example, to just call log(...) instead of console.log(...):
// var log = window.console ? console.log.bound(console) : Empty;

var Empty = Function.__proto__ // the empty function



/* Bling!, the constructor.
 * ------------------------
 * new Bling(expression, context):
 * expression -
 *   accepts strings, as css expression to select, ("body div + p", etc.)
 *     or as html to create (must start with "<")
 *   accepts existing Bling
 *   accepts arrays of anything
 *   accepts a single number, used as the argument in new Array(n), to pre-allocate space
 * context - optional, the item to consider the root of the search when using a css expression
 *
 * always returns a Bling object, full of stuff
 */
function Bling (expr, context) {
	// calling "Bling(...)" is the same as calling "new Bling(...)"
	if( this == window || this == Bling ) return new Bling(expr, context)
	context = context || document
	// copy data from some indexable source onto the end of our array
	this.copyFrom = function(s, n) {
		for( var i = 0; i < (n ? Math.min(s.length,n) : s.length); i++)
			this.push(s[i])
	}
	// call the Array constructor based on some other array-like thing
	this.initFrom = function(s) {
		Array.apply(this, [s.length])
		this.copyFrom(s)
	}
	if( typeof(expr) == "string" ) {
		// accept two different kinds of strings: html, and css expression
		// html begins with "<", and we create a set of nodes by parsing it
		if( expr[0] == "<" ) {
			var d = document.createElement("div")
			d.innerHTML = expr
			this.initFrom(d.childNodes)
			this.forEach(function(x) {
				if( x.parentNode ) {
					x.parentNode.removeChild(x)
					x.parentNode = null
				}
			})
		} else { // anything else is a css expression, for querySelectorAll
			// if we are searching inside another Bling
			//  then search each item in the bling, and accumulate in one list
			if( isBling(context) ) {
				this.initFrom([])
				var t = this
				context.each(function() {
					t.copyFrom(this.querySelectorAll(expr))
				})
			} else if( context.querySelectorAll != undefined ) {
				// if the context is directly searchable, search it
				this.initFrom(context.querySelectorAll(expr))
			} else {
				// otherwise, this is not a valid context
				throw new Error("invalid context "+context+")")
			}
		}
	} else if( typeof(expr) == "number" ) {
		// accept a single number, to pre-allocate space
		Array.apply(this, [expr])
	} else if( isBling(expr) ) {
		// accept Bling objects, but do nothing
		return expr
	} else if( expr == undefined ) { // if there was no expr, just create an empty set
		this.initFrom([])
	} else if( expr == window || isSubtype(expr, Node) ) { // load DOM nodes into a new array
		this.initFrom([ expr ])
	} else if( expr.length != undefined ) { // anything array-like we can use directly
		this.initFrom(expr)
	} else {
		this.initFrom([ expr ])
	}
}
// finish defining the Bling type
Bling.inheritsFrom(Array)
function isBling(a)  { return isType(a, Bling) }

/* The Bling! Operator
 * -------------------
 * Bound to $ by default, this is the handy constructor of Bling objects.
 * It also holds references to the global Bling functions:
 * $.extend === Bling.extend
 * $("body")[0] === new Bling("body")[0]
 * isBling($) == false
 * isBling($()) == true
 */
Bling.operator = Bling

/* Simple object extension:
 * .extend() will merge values from b into a
 * if c is present, it should be a list of the properties to limit to
 */
Bling.extend = function(a, b, c) {
	for( var i in b ) {
		if( c && a[i] != undefined )
			for( var j in c )
				a[i][j] = b[i][j]
		else
			a[i] = b[i]
	}
	return a
}

// define the basic modular mechanics: .addMethods and .addGlobals

// .addMethods() is how you add Bling instance methods
// ex. Bling.addMethods({nop:function(){ return this; })
//     Bling.addMethods({etc:function(){ return "..." })
//     new Bling("body").nop().find("div").etc() == "..."
Bling.addMethods = function (methods) {
	Bling.extend(Bling.prototype, methods)
}
// .addGlobals() is how a plugin provides new global functions
// these are attached to the Bling namespace, and to the operator
// ex. Bling.addGlobals({hello:function(){ return "hello"; })
//     Bling.hello() == "hello"
//     $.hello() == "hello"
Bling.addGlobals = function (globals) {
	if( globals ) {
		Bling.extend(Bling, globals)
	}
}

// the privatescope variable is never set to a value
// but an inner function like this will not be evaluated
// if its results dont go anywhere
Bling.privatescope = (function () {

	/// Core Module ///
	// jquery-complete
	// TODO: .zap(k,v) should accept v as a list, one value for each node to be set

	// a TimeoutQueue is used by the core to preserve the proper order
	// of setTimeout handlers scheduled by .future()
	function TimeoutQueue() {
		// the basic problem with setTimeout happens when multiple handlers
		// are scheduled to fire 'near' each other, values of 'near' depend on
		// how busy the rest of your script is.  if the timer event handlers are
		// blocked by other processing they might not check for 'due' execution
		// over some arbitrary time period.  if multiple handlers were due to fire
		// during that period, then all of the due handlers will fire
		// in no particular order.  this queue will re-order them so they
		// always fire in the order they were scheduled
		this.queue = []
		this.schedule = function schedule(f, n) {
			var t = new Date().getTime(),
				nn = this.queue.length;
			f.order = n < t ? n + t : n;
			// shortcut some special cases: empty queue, or f.order greater than the last item
			if( nn == 0 || f.order > this.queue[nn-1].order )
				this.queue[nn] = f
			else // search the queue for the sorted position to insert f
				for( var i = 0; i < nn; i++) // find i such that
					if( this.queue[i].order > f.order ) // i is the first item > f
						this.queue.splice(i,0,f); // insert f before i
			setTimeout(function() { Bling.timeoutQueue.shift()() }, n)
		}
		this.shift = this.queue.shift.bound(this.queue)
	}

	Bling.addGlobals({
		// .dumpText() produces a human readable plain-text view of an object
		dumpText: function dumpText(obj, indent) {
			var s = ""
			indent = indent || ""
			if( typeof(obj) == "object" ) {
				var s = "{\n"
				indent = indent + "\t"
				for( var k in obj ) {
					var v = undefined
					try {
						v = obj[k]
					} catch ( err ) { console.log(k, err); }
					s += indent + k + ":" + " " + Bling.dumpText(v, indent) + ",\n"
				}
				indent = indent.slice(1)
				s += indent + "}"
			} else if( typeof(obj) == "string" ) {
				s += '"' + obj + '"'
			} else if( typeof(obj) == "function" ) {
				var t = "" + obj
				s += t.slice(0, t.indexOf("\n")) + " ... }"
			} else {
				s += "" + obj
			}
			return s;
		},
		// .dump() produces a human readable html view of an object
		dump: function dump(obj) {
			return Bling.dumpText(obj).replace(/(?:\r|\n)+/g,"<br>").replace(/\t/g,"&nbsp;&nbsp;");
		},
		// used by .future() to make sure that order of the schedule is preserved,
		// even if the browser doesn't
		timeoutQueue: new TimeoutQueue(),
	})
	Bling.addMethods({
		// define a functional basis: each, map, and reduce
		// these act like the native forEach, map, and reduce, except they respect the context of the Bling
		// so the 'this' value in the callback f is always set to the item being processed
		each: function each(f) {
			this.forEach(function(t) {
				f.call(t, t);
			});
			return this;
		},

		map: function map(f) {
			return new Bling(Array.prototype.map.call(this, function(t) {
				try { return f.call(t, t) }
				catch( e ) {
					if( isType(e, TypeError) ) return f(t) // certain special globals dont work if you reapply this
				}
			}));
		},

		reduce: function reduce(f) {
			// along with respecting the context, we pass only the accumulation + 1 item
			// so you can use functions like Math.min directly $(numbers).reduce(Math.min)
			// this fails with the default reduce, since Math.min(a,x,i,items) is NaN
			if( (!f) || this.length == 0 ) return null
			return Array.prototype.reduce.call(this, function(a, x) {
				return f.apply(x, [a, x]);
			})
		},

		filter: function filter(f) {
			var b = new Bling(this.length);
			for(var i = 0, n = this.length; i < n; i++ ) {
				var it = this[i];
				if( f.call( it ) ) b.push(it);
			}
			return b
		},

		distinct: function distinct() {
			var bucket = {}
			this.each(function() {
				bucket[this] = 1;
			})
			var ret = new Bling();
			for( var i in bucket )
				ret.push(i)
			return ret
		},

		// zip(p) returns a list of the values of property p from each node
		zip: function zip(p) {
			if( !p ) return this
			var i = p.indexOf(".")
			return i > -1 ? this.zip(p.substr(0, i)).zip(p.substr(i+1)) // zip("a.b") -> zip("a").zip("b")
				: this.map(function() { // zip('someMemberFunction').call() -> this.map( { return this() } )
					return typeof(this[p]) == "function" ?  this[p].bound(this)
						: this[p]
				});
		},

		// zap(p, v) sets property p to value v on all nodes in the list
		zap: function zap(p, v) { // zap("a.b") -> zip("a").zap("b")
			if( !p ) return this
			var i = p.indexOf(".")
			return i > -1 ? this.zip(p.substr(0, i)).zap(p.substr(i+1), v)
				: this.each(function() { this[p] = v })
		},

		// take(n) trims the list to only the first n elements
		// if n == this.length, returns a shallow copy of the whole list
		take: function take(n) {
			n = n || 1
			n = Math.min(n, this.length);
			var a = new Bling(n);
			for( var i = 0; i < n; i++)
				a.push( this[i] )
			return a;
		},

		// skip(n) skips the first n elements in the list
		skip: function skip(n) {
			n = n || 1
			var a = new Bling( Math.max(0,this.length - n) );
			for( var i = 0, nn = this.length - n; i < nn; i++)
				a.push(this[i+n])
			return a;
		},

		// .last(n) returns the last n elements in the list
		// if n is not passed, returned just the item (no bling)
		last: function last(n) { return n ? this.skip(Math.max(0,this.length - n)) : this.skip(this.length - 1)[0] },

		// .first(n) returns the first n elements in the list
		// if n is not passed, returned just the item (no bling)
		first: function first(n) { return n ? this.take(n) : this[0] },

		// .join() concatenates all items in the list using sep
		join: function join(sep) {
			return this.reduce(function(j) {
				return j + sep + this;
			});
		},

		// .slice(start, end) returns a contiguous subset of elements
		// the end-th item will not be included - the slice(0,2) will contain items 0, and 1.
		// negative indices work like in python: -1 is the last item, -2 is second-to-last
		slice: function slice(start, end) {
			var n = this.length
			end = end == undefined ? n
				: end < 0 ? n + end
				: end;
			start = start == undefined ? n
				: start < 0 ? n + start
				: start;
			return this.take(end).skip(start);
		},

		// .concat(b) inserts all items from b into this array
		concat: function concat(b) {
			for( var i = 0, n = b.length; i < n; i++)
				this.push(b[i])
			return this
		},

		// .weave() takes the given array and interleaves it in this array
		weave: function weave(a) {
			var n = a.length;
			var b = new Bling(this.length + n);
			b.length = this.length + n;
			// first spread out this list, from back to front
			for(var i = this.length - 1; i >= 0; i-- )
				b[(i*2)+1] = this[i];
			// then interleave the source items, from front to back
			for(var i = 0; i < n; i++)
				b[i*2] = a[i];
			// this is not quite a perfect implementation, really it should check which is longer
			// and only interleave equal length arrays, then append any leftovers
			// so that unequal length arguments will not create 'undefined' items
			return b;
		},

		// various common ways to map/reduce blings
		toString: function toString() { return "["+this.map(Bling.dumpText).join(", ")+"]" },
		floats: function floats()  { return this.map(parseFloat) },
		ints: function ints()  { return this.map(parseInt) },
		squares: function squares()  { return this.map(function() { return this * this })},
		sum: function sum()  { return this.reduce(function(x) { return x + this })},
		max: function max()  { return this.reduce(Math.max) },
		min: function min()  { return this.reduce(Math.min) },
		average: function average()  { return this.sum() / this.length },
		magnitude: function magnitude()  { return Math.sqrt(this.squares().sum()) },
		scale: function scale(n) { return this.map(function() { return n * this })},
		call: function call() {
			var args = arguments
			return this.map(function() { return this.apply(null, args) })
		},

		// try to continue using f in the same scope after about n milliseconds
		future: function future(n, f) {
			Bling.timeoutQueue.schedule(f.bound(this), n)
			return this
		},

		merge: function merge() {
			var b = new Bling()
			for( var i = 0, n = this.length; i < n; i++)
				b.concat(this[i])
			return b
		},
	})

	/// HTML/DOM Manipulation Module ///

	// these static DOM helpers are used inside some the the html methods
	var _before = function(a,b) { if( a && b ) a.parentNode.insertBefore(b, a) }
	var _after = function(a,b) { a.parentNode.insertBefore(b, a.nextSibling) }
	var toNode = function(x) {
		return isNode(x) ? x
			: isBling(x) ? x.toFragment()
			: isString(x) ? new Bling(x).toFragment()
			: isFunc(x.toString) ? new Bling(x.toString()).toFragment()
			: undefined
	}
	function deepClone(node) {
		var n = node.cloneNode()
		for(var i = 0; i < node.childNodes.length; i++) {
			n.appendChild(deepClone(node.childNodes[i]))
		}
		return n
	}

	Bling.addGlobals({
		// $.rgb() accepts a color in any css format
		// returns a 3-item bling with the floating point rgb values
		// or the empty-set if it doesn't parse as a css color
		rgb: function rgb(expr) {
			var d = document.createElement("div");
			d.style.color = expr;
			var rgb = d.style.getPropertyValue('color');
			if( rgb )
				return new Bling( rgb.slice(rgb.indexOf('(')+1, rgb.indexOf(')')) .split(", ")).floats()
			return new Bling();
		},
	})

	Bling.addMethods({
		// .html() gets/sets the .innerHTML of all elements in list
		html: function html(h) {
			return h == undefined ? this.zip('innerHTML')
				: isString(h) ? this.zap('innerHTML', h)
				: isBling(h) ? this.html(h.toFragment())
				: isNode(h) ? this.each(function() {
					this.replaceChild(this.childNodes[0], h)
					while( this.childNodes.length > 1 )
						this.removeChild(this.childNodes[1])
				})
				: undefined
		},

		// .append() puts some content (bling,html,etc) at the end of each's children
		append: function append(x) {
			x = toNode(x) // parse, cast, do whatever it takes to get a Node or Fragment
			this.zip('appendChild').take(1).call(x);
			this.zip('appendChild').skip(1).each(function() {
				this(deepClone(x))
			})
			return this
		},

		// .appendTo() is the other direction of .append()
		appendTo: function appendTo(x) {
			new Bling(x).append(this)
			return this
		},

		// .prepend() puts x before the first child of each node in the set
		prepend: function prepend(x) {
			x = toNode(x)
			this.take(1).each(function() { _before(this.childNodes[0], x) })
			this.skip(1).each(function() { _before(this.childNodes[0], deepClone(x)) })
			return this
		},

		prependTo: function prependTo(x) {
			new Bling(x).prepend(this)
			return this
		},

		before: function before(x) {
			x = toNode(x)
			this.take(1).each(function() { _before(this, x) })
			this.skip(1).each(function() { _before(this, deepClone(x)) })
			return this
		},

		after: function after(x) {
			x = toNode(x)
			this.take(1).each(function() { _after(this, x) })
			this.skip(1).each(function() { _after(this, deepClone(x)) })
		},

		wrap: function wrap(x) {
			x = new Bling(x)
			this.before(x) // put x before this
			x.take(1).append(this) // move this into the first element of x (the new parent)
		},

		unwrap: function unwrap() {
			return this.each(function() {
				if( this.parentNode && this.parentNode.parentNode )
					this.parentNode.parentNode.replaceChild(this.parentNode, this)
			})
		},

		attr: function attr(k,v) {
			var f = v ? "setAttribute" : "getAttribute"
			var ret = this.zip(f).call(k,v)
			return v ? this : ret;
		},

		// .addClass(x) removes and then adds class x to each node in the set
		addClass: function addClass(x) {
			return this.removeClass(x).each(function() {
				this.className = this.className.split(" ").push(x).join(" ")
			})
		},

		// .removeClass(x) removes class x from each node in the set
		removeClass: function removeClass(x) {
			var notx = function(y){ return y != x }
			return this.each(function() {
				var cls = this.className.split(" ").filter(notx).join(" ")
			})
		},

		// .toggleClass(x) toggles class x for each node in the set
		toggleClass: function toggleClass(x) {
			var notx = function(y){ return y != x }
			return this.each(function(node) {
				var cls = node.className.split(" ")
				if( cls.indexOf(x) > -1 )
					node.className = cls.filter(notx).join(" ")
				else
					node.className = cls.push(x).join(" ")
			})
		},

		// .hasClass() is slightly different from jQuery, it returns a list, a boolean for each
		hasClass: function hasClass(x) {
			this.zip('className.split').call(" ").zip('indexOf').call(x).map(function(){ return this > -1 })
		},

		// .text() gets/sets the .innerText of all elements
		text: function text(t) { return t ? this.zap('innerText', t) : this.zip('innerText') },

		// .val() gets/sets the values of the nodes in the list
		val: function val(v) { return v ? this.zap('value', v) : this.zip('value') },

		// .css(k,v) gets/sets css properties for every node in the list
		css: function css(k,v) {
			if( v ) {
				this.zip('style.setProperty').call(k,v) // if v is present set the value on each element
				return this
			}
			return this.map(window.getComputedStyle)
				.zip('getPropertyValue').call(k) // return the computed value
		},

		// .rgb() returns a css color string...
		rgb: function rgb() {
			return this.length == 4 ? "rgba("+this.join(", ")+")"
				: this.length == 3 ? "rgb("+this.join(", ")+")"
				: undefined;
		},

		// .child(n) returns the nth childNode for all items in the set
		child: function child(n) { return this.map(function() { return this.childNodes[n] })},

		// .parent() returns the parentNodes of all items in the set
		parent: function parent() { return this.zip('parentNode') },

		// .parents() returns all the parentNodes up to the owner for each item
		parents: function parents() {
			return this.map(function() {
				var b = $([]);
				var p = this.parentNode;
				while( p ) {
					b.push(p);
					p = p.parentNode;
				}
				return b;
			})
		},

		// .remove() removes each node from the DOM
		remove: function remove() {
			return this.each(function(){
				if( this.parentNode ) {
					this.parentNode.removeChild(this);
					this.parentNode = null;
				}
			});
		},

		// .find(expr) maps querySelectorAll(expr) over each element in the set
		find: function find(expr) {
			return this.map(function() { return new Bling(expr, this) })
				.reduce(function(a) { return a.concat(this) })
		},

		// .clone() deep copies a set of DOM nodes
		// note: does not copy event handlers
		clone: function clone() {
			return this.map(deepClone)
		},

		// EXPERIMENTAL
		// .fork() works like the system call fork()
		// it deep-copies the current working set,
		// then starts a different chain of operations on the new set
		fork: function fork(g) {
			this.future(0, g.bound(this.clone()))
			return this
		},


		// FOR INTERNAL USE, or advanced users.
		// .toFragment() converts a bling of convertible stuff: (nodes, strings, fragments, blings)
		// into a single DocumentFragment, mostly useful for moving junk around cleanly.
		// note: DocumentFragment are a sub-class of Node: isNode(fragment) === true
		// so you can node.appendChild() them directly, etc
		// but this MOVES THE NODES into the fragment, if they were in the DOM already
		// so be sure to put them back someplace or you will lose them:
		// ex.:
		// $("input").length === 2
		// $("input").toFragment().childNodes.length === 2
		// $("input").length === 0
		// Where did the inputs go?!
		// The third search is searching the DOM, to which the inputs are no longer attached.
		// They are attached to the fragment, whose reference we discarded.
		// Be sure to save a reference to the fragment, or use it immediately.
		// $("body").append($("input").toFragment())
		toFragment: function toFragment() {
			var f = document.createDocumentFragment()
			this.each(function(h) {
				f.appendChild( isNode(h) ? h
					: isBling(h) ? h.toFragment()
					: isString(h) ? new Bling(h).toFragment()
					: isFunc(h.toString) ? new Bling(h.toString()).toFragment()
					: undefined
				)
			})
			return f
		},

	})

	/// Events Module: provides for binding and triggering DOM events ///
	// TODO // event:
	// .once() - handle an event one time only
	// .cycle() - handle an event with a cycle of handlers

	// construct a
	function binder(e) {
		return function bindortrigger(f) {
			return isFunc(f) ? this.bind(e, f) : this.trigger(e, f ? f : [])
		}
	}

	Bling.addGlobals({
		ready: function ready(f) {
			new Bling(window).bind('load', f)
		}
	})
	Bling.addMethods({
		// bind an event handler, evt is a string, like 'click'
		bind: function bind(e, f) {
			return this.each(function() { this.addEventListener(e, f) })
		},

		// unbind an event handler, f is optional, evt is a string, like 'click'.
		unbind: function unbind(e, f) {
			return this.each(function() { this.removeEventListener(e,f) })
		},

		// fire a fake event on each node
		// evt is the type, 'click', etc.
		// args is an optional mapping of properties to set, {screenX: 10, screenY: 10}
		trigger: function trigger(evt, args) {
			var e = undefined;
			args = Bling.extend({
				bubbles: true,
				cancelable: true,
			}, args)
			switch(evt) {
				// mouse events
				case "click":
				case "mousemove":
				case "mousedown":
				case "mouseup":
				case "mouseover":
				case "mouseout":
					e = document.createEvent("MouseEvents")
					args = Bling.extend({
						detail: 1,
						screenX: 0,
						screenY: 0,
						clientX: 0,
						clientY: 0,
						ctrlKey: false,
						altKey: false,
						shiftKey: false,
						metaKey: false,
						button: 0,
						relatedTarget: null,
					}, args)
					e.initMouseEvent(evt, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
						args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
						args.button, args.relatedTarget);
					break;

				// UI events
				case "blur":
				case "focus":
				case "reset":
				case "submit":
				case "abort":
				case "change":
				case "load":
				case "unload":
					e = document.createEvent("UIEvents")
					e.initUIEvent(evt, args.bubbles, args.cancelable, window, 1)
					break;

				// iphone touch events
				case "touchstart":
				case "touchmove":
				case "touchend":
				case "touchcancel":
					e = document.createEvent("TouchEvents")
					args = Bling.extend({
						detail: 1,
						screenX: 0,
						screenY: 0,
						clientX: 0,
						clientY: 0,
						ctrlKey: false,
						altKey: false,
						shiftKey: false,
						metaKey: false,
						// touch values:
						touches: [],
						targetTouches: [],
						changedTouches: [],
						scale: 1.0,
						rotation: 0.0,
					}, args)
					e.initTouchEvent(evt, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
						args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
						args.touches, args.targetTouches, args.changedTouches, args.scale, args.rotation);
					break;

				// iphone gesture events
				case "gesturestart":
				case "gestureend":
				case "gesturecancel":
					e = document.createEvent("GestureEvents")
					args = Bling.extend({
						detail: 1,
						screenX: 0,
						screenY: 0,
						clientX: 0,
						clientY: 0,
						ctrlKey: false,
						altKey: false,
						shiftKey: false,
						metaKey: false,
						// gesture values:
						target: null,
						scale: 1.0,
						rotation: 0.0,
					}, args)
					e.initGestureEvent(evt, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
						args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
						args.target, args.scale, args.rotation);
					break;

				// iphone events that are not supported yet
				case "drag":
				case "drop":
				case "selection":

				// iphone events that we cant properly emulate
				// (because we cant create our own Clipboard objects)
				case "cut":
				case "copy":
				case "paste":

				// iphone events that are just plain events
				case "orientationchange":

				// a general event
				default:
					e = document.createEvent("Events");
					e.initEvent(evt, args.bubbles, args.cancelable);
			}

			if( !e ) return this;
			else return this.each(function() {
				this.dispatchEvent(e)
				e.result = e.returnValue = undefined // clean up
			})
		},

		// short-cuts for bind/trigger
		click: binder('click'),
		mousemove: binder('mousemove'),
		mousedown: binder('mousedown'),
		mouseup: binder('mouseup'),
		mouseover: binder('mouseover'),
		mouseout: binder('mouseout'),
		blur: binder('blur'),
		focus: binder('focus'),
		load: binder('load'),
		unload: binder('unload'),
		reset: binder('reset'),
		submit: binder('submit'),
		change: binder('change'),
		abort: binder('abort'),
		cut: binder('cut'),
		copy: binder('copy'),
		paste: binder('paste'),
		selection: binder('selection'),
		drag: binder('drag'),
		drop: binder('drop'),
		orientationchange: binder('orientationchange'),
		touchstart: binder('touchstart'),
		touchmove: binder('touchmove'),
		touchend: binder('touchend'),
		touchcancel: binder('touchcancel'),
		gesturestart: binder('gesturestart'),
		gestureend: binder('gestureend'),
		gesturecancel: binder('gesturecancel'),

	})


	/// Transformation Module: provides wrapper for using -webkit-transform ///
	Bling.addGlobals({
		// how long are various speeds
		duration: function duration(speed) {
			var speeds = {
				"slow": 700,
				"medium": 500,
				"normal": 300,
				"fast": 100,
			}
			var s = speeds[speed]
			var ret = s ? s : parseFloat(speed);
			return ret;
		},
	})
	Bling.addMethods({

		// like jquery's animate(), but using only webkit-transition/transform
		transform: function transform(end_css, speed, callback) {
			if( typeof(speed) == "function" ) {
				callback = speed
				speed = undefined
			}
			speed = speed || "normal";
			var duration = this.duration(speed);
			// collect the list of properties to be modified
			var props = [];
			// what to send to the -webkit-transform
			var transform = "";
			// real css values to be set (end_css minus the transform values)
			var css = {};
			for( var i in end_css )
				// pull all the transform values out of end_css
				if( /(?:scale|translate|rotate|scale3d|translateX|translateY|translateZ|translate3d|rotateX|rotateY|rotateZ|rotate3d)/.test(i) )
					transform += " " + i + "(" + end_css[i].join(", ") + ")";
				else // stick real css values in the css dict
					css[i] = end_css[i];
			// make a list of the properties to be modified
			for( var i in css )
				props.push(i);
			// and include -webkit-transform if we have data there
			if( transform )
				props.push("-webkit-transform")
			this.css('-webkit-transition-property', props.join(', '));
			// repeat the duration the same number of times as there are properties
			this.css('-webkit-transition-duration', props.map(function() { return duration + "ms" }).join(', '));
			// apply the real css
			for( var i in css )
				this.css(i, css[i])
			// apply the transformation
			if( transform )
				this.css('-webkit-transform', transform);
			// queue the callback to be executed
			return this.future(duration, callback);
		},

		hide: function hide(callback) {
			return this.each(function() {
				this._display = this.style.display != "none" ? this.style.display : undefined;
				this.style.display = 'none';
			}).future(0, callback);
		},

		show: function show(callback) {
			return this.each(function() {
				this.style.display = this._display ? this._display : "";
				this._display = undefined;
			}).future(0, callback)
		},

		fadeIn: function fadeIn(speed, callback) {
			return this
				.css('opacity','0.0')
				.show(function(){this
					.transform({opacity:"1.0", translate3d:[0,0,0]}, speed, callback)
				})
		},
		fadeOut: function fadeOut(speed, callback) { return this.transform({opacity:"0.0"}, speed, function() { this.hide(); if( callback ) callback.call(this) })},
		fadeLeft: function fadeLeft(speed, callback) { return this.transform({opacity:"0.0", translate3d:["-"+this.width()+"px",0.0,0.0 ]}, speed, function() { this.hide(); if( callback ) callback.call(this) })},
		fadeRight: function fadeRight(speed, callback) { return this.transform({opacity:"0.0", translate3d:[this.width()+"px",0.0,0.0     ]}, speed, function() { this.hide(); if( callback ) callback.call(this) })},
		fadeUp: function fadeUp(speed, callback) { return this.transform({opacity:"0.0", translate3d:[0.0,"-"+this.height()+"px",0.0]}, speed, function() { this.hide(); if( callback ) callback.call(this) })},
		fadeDown: function fadeDown(speed, callback) { return this.transform({opacity:"0.0", translate3d:[0.0,this.height()+"px",0.0    ]}, speed, function() { this.hide(); if( callback ) callback.call(this) })},
	})

	/// Database Module: provides access to the sqlite database ///
	Bling.addGlobals({
		// get a connection to the database
		db: function db(fileName, version, displayName, maxSize) {
			return new Bling([window.openDatabase(
				fileName || "bling.db",
				version || "1.0",
				displayName || "bling database",
				maxSize || 1024)
			])
		}
		,
	})
	Bling.addMethods({
		transaction: function transaction( f ) {
			this.zip('transaction').call(f)
			return this
		},

		// short-cut for .transaction(function(t){t.executeSql(sql, values, callback)})
		sql: function sql(sql, values, callback) {
			if( sql == undefined ) return undefined
			if( typeof(values) == "function") {
				callback = values
				values = undefined
			}
			values = values || []
			callback = callback || Empty
			assert( isType(this[0], "Database") )
			return this.transaction(function(t) {
				t.executeSql(sql, values, callback)
			})
		},

	})

	/// HTTP Request Module: provides wrappers for making http requests ///
	// TODO // http:
	// .get/.post
	var formencode = function(obj) {
		var s = []
		for( var i in obj )
			s.push( i + "=" + escape(obj[i]))
		return s.join("&")
	}

	Bling.addGlobals({
		http: function http(url, opts) {
			var xhr = new XMLHttpRequest()
			if( isFunc(opts) )
				opts = {success: opts}
			opts = Bling.extend({
				method: "GET",
				data: null,
				state: opts.state ? opts.state.bound(xhr) : Empty, // onreadystatechange
				success: opts.success ? opts.success.bound(xhr) : Empty, // onload
				error: opts.error ? opts.error.bound(xhr) : Empty, // onerror
				async: true,
			}, opts)
			if( opts.data && opts.method == "GET" )
				url += "?" + formencode(opts.data)
			else if( opts.data && opts.method == "POST" )
				opts.data = formencode(opts.data)
			xhr.open(opts.method, url, opts.async)
			xhr.onreadystatechange = function() {
				if( opts.state ) opts.state()
				if( xhr.readyState == 4 )
					if( xhr.status == 200 )
						opts.success(xhr.responseText)
					else if( opts.error )
						opts.error(xhr.status, xhr.statusText)
			}
			xhr.send(opts.data)
			return new Bling([xhr])
		},

		post: function post(url, opts) {
			if( isFunc(opts) )
				opts = {success: opts}
			opts = opts || {}
			opts.method = "POST"
			return Bling.http(url, opts)
		},

		get: function get(url, opts) {
			if( isFunc(opts) )
				opts = {success: opts}
			opts = opts || {}
			opts.method = "GET"
			return Bling.http(url, opts)
		},

	})


})()

// save our operator, bling!
$ = Bling.operator



