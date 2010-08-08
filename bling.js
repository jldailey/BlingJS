/* bling.js
 * --------
 * Named after the bling! operator ($), this is a jQuery-like framework,
 * using any and all WebKit specific hacks that we can.
 * All other browsers play at your own risk.
 * Blame: Jesse Dailey <jesse.dailey@gmail.com>
 */

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
function isString(a)   { return typeof(a) == "string" || isSubtype(a, String) }
function isNumber(a)   { return isFinite(a) }
function isFunc(a)     { return typeof(a) == "function" || isType(a, Function) }
function isNode(a)     { return a ? a.nodeType > 0 : false }
function isFragment(a) { return a ? a.nodeType == 11 : false }
function isArray(a)    { return Object.prototype.toString.call(a) == "[object Array]" || isSubtype(a, Array) }
function isObject(a)   { return typeof(a) == "object" }
function hasValue(a)   { return a != undefined && a != null }

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
// var log = window.console ? console.log.bound(console) : Function.Empty;

// Define a bunch of global static functions that will be consistently useful throughout the other methods
// used to avoid repeatedly creating closures to do these things
Function.Empty = function(){}
Function.NotNull = function notnull(x) { return x != null }
Function.NotUndefined = function notundefined(x) { return x != undefined }
Function.NotNullOrUndefined = function notnullorundefined(x) { return x != undefined && x != null; }
Function.IndexFound = function found(x) { return x > -1 }
Function.HtmlEscape = function htmlescape(x) { return x.replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\t/g,'&nbsp;&nbsp;') }
Function.ReduceAnd = function(x) { return x && this; }


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
 * @constructor
 */
function Bling (expr, context) {
	if( isBling(expr) ) // accept Bling objects, but do nothing
		return expr
	// make calling "Bling(...)" is the same as calling "new Bling(...)"
	if( this === window || this === Bling ) return new Bling(expr, context)
	// the default context is the entire document
	context = context || document
	if( expr == undefined ) { // if there was no expr, just create an empty set
		Bling.__init__(this, [])
	} else if( typeof expr == "string" ) { // strings, search css or parse html
		// accept two different kinds of strings: html, and css expression
		// html begins with "<", and we create a set of nodes by parsing it
		if( expr[0] == "<" ) {
			Bling.__init__(this, [Bling.HTML.parse(expr)])
		} else { // anything else is a css expression, for querySelectorAll
			// if we are searching inside another Bling
			//  then search each item in the bling, and accumulate in one list
			if( isBling(context) ) {
				Bling.__init__(this, [])
				var t = this
				context.each(function() {
					Bling.__copy__(t, this.querySelectorAll(expr))
				})
			} else if( context.querySelectorAll != undefined ) {
				// if the context is directly searchable, search it
				Bling.__init__(this, context.querySelectorAll(expr))
			} else {
				// otherwise, this is not a valid context
				throw new Error("invalid context "+context+")")
			}
		}
	} else if( typeof(expr) == "number" ) { // numbers pre-allocate
		// accept a single number, to pre-allocate space
		Array.call(this, expr)
	} else if( expr === window || isNode(expr) ) { // items got stored
		// a single node becomes the sole item in our array
		Bling.__init__(this, [expr])
	} else if( expr.length != undefined ) {  // arrays get copied
		// use any array-like object directly
		// careful to check for === window _before_ this check, as window.length is defined
		Bling.__init__(this, expr)
	} else { // everything else, just wrap in the bling
		Bling.__init__(this, [expr])
	}
}
// finish defining the Bling type
Bling.inheritsFrom(Array)
function isBling(a)  { return (a && a.__bling__ ) || isType(a, Bling) }

// two static helpers for the constructor:
// copy data from some indexable source onto the end of t
Bling.__copy__ = function(t, s, n) {
	for( var i = 0, nn = (n ? Math.min(s.length,n) : s.length); i < nn; i++)
		t.push(s[i])
}
// init the Bling structure based on some other array-like thing
Bling.__init__ = function(t, s) {
	Array.call(t, s.length)
	Bling.__copy__(t, s)
	t.__bling__ = true;
}

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
 * if c is present, it should be a list of property names to copy
 */
Bling.extend = function(a, b, c) {
	for( var i in b ) {
		if( c && a[i] != undefined ) {
			for( var j in c ) {
				a[i][j] = b[i][j]
			}
		} else {
			a[i] = b[i]
		}
	}
	return a
}

Bling.addMethods = function (/*arguments*/) {
	// .addMethods() is a plugin provides Bling instance methods
	// ex. Bling.addMethods({nop:function(){ return this; })
	// ex. Bling.addMethods({etc:function(){ return "..." })
	// ex. Bling.addMethods(function identity(){ return this })
	//     new Bling("body").nop().identity().find("div").etc() == "..."
	for(var i = 0, n = arguments.length; i < n; i++) {
		var a = arguments[i];
		if( isFunc(a) ) {
			if( ! a.name ) throw new Error("cannot extend with an anonymous method");
			Bling.prototype[a.name] = a
		} else {
			Bling.extend(Bling.prototype, a)
		}
	}
}

Bling.addGlobals = function (/*arguments*/) {
	// .addGlobals() is how a plugin provides new global functions
	// these are attached to the Bling namespace, and to the operator
	// ex. Bling.addGlobals({hello:function(){ return "hello"; })
	// ex. Bling.addGlobals(function hello_sir(){ return "hello, sir" })
	//     Bling.hello() == "hello"
	//     $.hello() == "hello"
	//     $.hello_sir() == "hello, sir"
	for(var i = 0, n = arguments.length; i < n; i++) {
		var a = arguments[i];
		if( isFunc(a) ) {
			if( ! a.name ) throw new Error("cannot extend with an anonymous method");
			Bling[a.name] = a
		} else {
			Bling.extend(Bling, a)
		}
	}
}

;(function () {

	/// Core Module ///
	// jquery-complete
	// TODO: add tests for .zap(k,v) where v is a list

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
		// private method next() consumes the next handler on the queue
		this.next = function() {
			// consume all 'due' handlers
			if( this.queue.length > 0 )
				// shift and call
				this.queue.shift()()
		}.bound(this) // you cant fuck with next, it wont be re-bound!
		// public method schedule(f, n) sets f to run after n or more milliseconds
		this.schedule = function schedule(f, n) {
			// console.log("begin schedule? ", isFunc(f) ? "yes" : "no")
			if( !isFunc(f) ) return;
			var nn = this.queue.length;
			f.order = n + new Date().getTime();
			// shortcut some special cases: empty queue, or f.order greater than the last item
			if( nn == 0 || f.order > this.queue[nn-1].order ) {
				this.queue[nn] = f
			} else { // search the queue for the sorted position to insert f
				for( var i = 0; i < nn; i++) { // find i such that
					if( this.queue[i].order > f.order ) { // i is the first item > f
						this.queue.splice(i,0,f) // insert f before i
					}
				}
			}
			// console.log("scheduling", this.queue.map(function(x){return x.order % 10000}).join(", "))
			setTimeout(this.next, n)
		}
	}

	Bling.addGlobals({
		// TODO: make private, only public for debugging temporarily
		timeoutQueue: new TimeoutQueue(),
		dumpText: function dumpText(obj, indent, visited) {
			// produces a human-readable json-like dump of any object
			var s = ""
			visited = visited || {}
			indent = indent || ""
			if( typeof(obj) == "object" ) {
				if( visited[obj] ) return "{..circular ref..}"
				visited[obj] = true
				s = "{\n"
				indent = indent + "\t"
				for( var k in obj ) {
					var v = undefined
					try {
						v = obj[k]
					} catch ( err ) { console.log(k, err); }
					var inner = isNode(v) ? v.toString() : Bling.dumpText( Bling.dumpText(v, indent, visited) );
					s += indent + k + ":" + " " + inner + ",\n"
				}
				indent = indent.slice(1)
				s += indent + "}"
			} else if( typeof(obj) == "string" ) {
				if( obj.length > 250 )
					obj = obj.substring(0,250) + "..."
				if( obj[0] != '"' )
					s += '"' + obj + '"'
				else
					s += obj
			} else if( typeof(obj) == "function" ) {
				if( visited[obj] ) return "{..circular ref..}"
				visited[obj] = true
				var t = "" + obj
				s += t.slice(0, t.indexOf("{")+1) + " ... }"
			} else {
				s += "" + obj
			}
			return s;
		},
		dumpHtml: function dumpHtml(obj) {
			// produces readable html view of any object
			return Bling.dumpText(obj).replace(/(?:\r|\n)+/g,"<br>").replace(/\t/g,"&nbsp;&nbsp;");
		}
	})
	Bling.addMethods({
		each: function each(f) {
			this.forEach(function(t) {
				f.call(t, t);
			});
			return this;
		},

		map: function map(f) {
			var a = new Bling(this.length)
			this.each(function(t) {
				try { a.push(f.call(t, t)) }
				catch( e ) {
					if( isType(e, TypeError) ) a.push(f(t))
					else throw e
				}
			})
			return a
		},

		reduce: function reduce(f, init) {
			// along with respecting the context, we pass only the accumulation and one argument
			// so you can use functions like Math.min directly $([1,2,3]).reduce(Math.min)
			// this fails with the default reduce, since Math.min(a,x,i,items) is NaN
			if( !f ) return this
			var a = init, 
				t = this;
			if( ! hasValue(init) ) {
				a = this[0]
				t = this.skip(1)
			}
			t.each(function() {
				a = f.call(this, a, this)
			})
			return a
		},

		filter: function filter(f) {
			var b = new Bling(this.length);
			for(var i = 0, n = this.length; i < n; i++ ) {
				var it = this[i];
				if( f.call( it, it ) ) b.push(it);
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

		zip: function zip() {
			// return a list of the values of property p from each node
			// recursively split names like "foo.bar"
			// zip("foo.bar") == zip("foo").zip("bar")
			function _zip(p) {
				var i = p.indexOf(".")
				return i > -1 ? this.zip(p.substr(0, i)).zip(p.substr(i+1))
					: this.map(function() {
						var v = this[p]
						// when zipping functions, zip a bound version
						return isFunc(v) ? v.bound(this)
							// else, just zip the value
							: v
					})
			}
			switch( arguments.length ) {
				case 0:
					return this;
				case 1:
					return _zip.call(this, arguments[0])
				default: // > 1
					// if more than one argument is passed, new objects
					// with only those properties, will be returned
					// like a "select" query in SQL
					var master = {}
					var b = new Bling()
					// first collect a set of lists
					for(var i = 0, n = arguments.length; i < n; i++) {
						if( master[i] == undefined ) master[i] = []
						master[i] = _zip.call(this, arguments[i])
					}
					// then convert to a list of sets
					for(var i = 0, n = this.length; i < n; i++) {
						var o = {}
						for(var k in master)
							o[k] = master[k].shift()
						b.push(o)
					}
					return b
			}
		},

		zap: function zap(p, v) { // zap("a.b") -> zip("a").zap("b")
			// set property p to value v on all nodes in the list
			if( !p ) return this
			var i = p.indexOf(".")
			return i > -1 ? this.zip(p.substr(0, i)).zap(p.substr(i+1), v)
				// accept an array of values (one value foreach x in this)
				: isArray(v) ? this.each(function(x) {
					// i starts at -1 (since we didnt recurse)
					x[p] = v[++i] // so we increment first, ++i, to start at 0
				})
				// accept a single value v, even if v is undefined
				: this.each(function() { this[p] = v })
		},

		take: function take(n) {
			// collect the first n elements of this into a new bling
			// if n == this.length, returns a shallow copy of the whole bling
			n = n || 1
			n = Math.min(n, this.length);
			var a = new Bling(n);
			for( var i = 0; i < n; i++)
				a.push( this[i] )
			return a;
		},

		skip: function skip(n) {
			// skip the first n elements in the bling
			// if n == 0, returns a shallow copy of the whole bling
			n = n || 1
			var a = new Bling( Math.max(0,this.length - n) );
			for( var i = 0, nn = this.length - n; i < nn; i++)
				a.push(this[i+n])
			return a;
		},

		last: function last(n) { 
			// collect the last n elements from this into a new bling
			// if n is not passed, returns just the last item (no bling)
			return n ? this.skip(Math.max(0,this.length - n))
				: this[this.length - 1] 
		},

		first: function first(n) { 
			// returns the first n elements in the bling
			// if n is not passed, returns just the item (no bling)
			return n ? this.take(n) 
				: this[0] 
		},

		join: function join(sep) {
			// concatenates all items in the bling using sep
			if( this.length == 0 ) return ""
			return this.reduce(function(j) {
				return j + sep + this;
			});
		},

		slice: function slice(start, end) {
			// return an arbitrary subset of contiguous elements
			// the end-th item will not be included - the slice(0,2) will contain items 0, and 1.
			// negative indices work like in python: -1 is the last item, -2 is second-to-last
			// undefined start or end become 0, or this.length, respectively
			var n = this.length
			end = end == undefined ? n
				: end < 0 ? n + end
				: end;
			start = start == undefined ? n
				: start < 0 ? n + start
				: start;
			return this.take(end).skip(start);
		},

		concat: function concat(b) {
			// insert all items from b into this array
			for( var i = 0, n = b.length; i < n; i++)
				this.push(b[i])
			return this
		},

		weave: function weave(a) {
			// interleave the given array with this array
			// resulting item order will be: a[i], this[i],
			// (the items from a come first)
			// note: if a is a different length from this
			// the shorter will yield undefineds into the result
			// the result.length is always 2 * max(length)
			var n = a.length, 
				nn = this.length,
				b = new Bling(nn + n)
			// first spread out this bling, from back to front
			for(var i = nn - 1; i >= 0; i-- )
				b[(i*2)+1] = this[i]
			// then interleave the source items, from front to back
			for(var i = 0; i < n; i++)
				b[i*2] = a[i]
			b.length = nn + n
			return b
		},

		fold: function fold(f) {
			// .fold() will always return a set with half as many items
			// used as a companion to weave: weave two blings together,
			// then fold them to a bling the original size
			var nn = this.length
			// at least a pair of items is required in the list
			if( nn < 2 ) return this;
			var n = new Bling(nn/2)
			for( var i = 0; i < nn - 1; i += 2) {
				n.push(f.call(this, this[i], this[i+1]))
			}
			return n
		},
		call: function call(/*arguments*/) {
			// call all functions in the set without a context
			return this.apply(null, arguments)
		},
		apply: function apply(context, args) {
			// apply every function in this to the given context and arguments
			return this
				.map(function() { 
					if( isFunc(this) )
						return this.apply(context, args) 
					return this
				})
		},

		toString: function toString() {
			return "Bling{["+this.map(function(){
				return this.toString()
			}).join(", ")+"]}"
		},

		// try to continue using f in the same scope after about n milliseconds
		future: function future(n, f) {
			if( f ) { Bling.timeoutQueue.schedule(f.bound(this), n) }
			return this
		},

		// EXPERIMENTAL
		// .fork() works like the system call fork()
		// it deep-copies the current working set,
		// then starts a different chain of operations on the new set
		fork: function fork(g) {
			this.future(0, g.bound(this.clone()))
			return this
		},

		log: function log(label) {
			// output the current bling to the console.log and continue
			if( label ) console.log(label, this, this.length + " items");
			else console.log(this, this.length + " items");
			return this;
		}
	})

	/// Math Module ///
	Bling.addMethods({
		floats: function floats() { 
			// convert all x in this to floats
			// or sets of floats
			return this.map(function() {
				if( isBling(this) ) return this.floats()
				return parseFloat(this);
			})
		},
		ints: function ints() {
			// convert all x in this to ints
			// or sets of ints
			return this.map(function() {
				if( isBling(this) ) return this.ints()
				return parseInt(this);
			})
		},
		min: function min() {
			// select the smallest x in this
			return this.reduce(function(a) {
				if( isBling(this) ) return this.min()
				return Math.min(this,a)
			})
		},
		max: function max() { 
			// select the largest x in this
			return this.reduce(function(a) {
				if( isBling(this) ) return this.max()
				return Math.max(this,a)
			})
		},
		average: function average() { 
			// compute the average of all x in this
			return this.sum() / this.length 
		},
		sum: function sum() { 
			// add all x in this
			return this.reduce(function(a) { 
				if( isBling(this) ) return a + this.sum()
				return a + this 
			})
		},
		squares: function squares()  { 
			// square all x in this
			return this.map(function() { 
				if( isBling(this) ) return this.squares();
				return this * this 
			})
		},
		magnitude: function magnitude() { 
			// compute the magnitude (the vector length) of this
			return this.map(function() {
				if( isBling(this) ) return this.magnitude();
				return Math.sqrt(this.squares().sum()) 
			})
		},
		scale: function scale(r) {
			// scale all x in this by the factor r
			return this.map(function() {
				if( isBling(this) ) return this.scale(r);
				return r * this 
			})
		},
		normalize: function normalize() {
			return this.scale(1/this.magnitude())
		}
	})

	/// HTML/DOM Manipulation Module ///

	// these static DOM helpers are used inside some of the html methods
	var _before = function(a,b) { if( a && b ) a.parentNode.insertBefore(b, a) }
	var _after = function(a,b) { a.parentNode.insertBefore(b, a.nextSibling) }
	var toNode = function(x) {
		// console.log("toNode", x.parentNode, isFunc(x.parent) ? x.parent() : "")
		var ret = isNode(x) ? x
			: isBling(x) ? x.toFragment()
			: isString(x) ? new Bling(x).toFragment()
			: isFunc(x.toString) ? new Bling(x.toString()).toFragment()
			: undefined
		// TODO: guids are for debugging
		Bling.nextguid = Bling.nextguid || 1
		if( ret.guid == undefined ) ret.guid = Bling.nextguid++;
		// console.log('toNode',ret.id,ret.guid,ret.parentNode)
		return ret
	}
	function deepClone(node) {
		// console.log('deepClone',node.toString())
		var n = node.cloneNode()
		for(var i = 0; i < node.childNodes.length; i++) {
			var c = n.appendChild(deepClone(node.childNodes[i]))
			c.parentNode = n // just make sure
		}
		return n
	}

	Bling.addGlobals({
		// .HTML.* provide an HTML converter similar to the global JSON object
		// method: .parse(string) and .stringify(node)
		HTML: {
			parse: function stringify(h) {
				// parse the html in the string h, return a Node.
				// will return a DocumentFragment if not well-formed.
				var d = document.createElement("div")
				d.innerHTML = h
				var df = document.createDocumentFragment()
				for( var i = 0, n = d.childNodes.length; i < n; i++)
					df.appendChild(d.removeChild(d.childNodes[0]))
				if( n == 1 )
					return df.removeChild(df.childNodes[0])
				else
					return df
			},
			stringify: function stringify(n) {
				// convert the Node n to it's html-string representation
				n = deepClone(n)
				var d = document.createElement("div")
				d.appendChild(n)
				var ret = d.innerHTML
				d.removeChild(n) // clean up to prevent leaks
				n.parentNode = null
				return ret
			}
		}

	})

	Bling.addMethods({
		html: function html(h) {
			// get/set the .innerHTML of all elements in list
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

		append: function append(x) {
			// puts some content (bling,html,etc) at the end of each's children
			x = toNode(x) // parse, cast, do whatever it takes to get a Node or Fragment
			this.zip('appendChild').take(1).call(x);
			this.zip('appendChild').skip(1).each(function() {
				this(deepClone(x))
			})
			return this
		},

		appendTo: function appendTo(x) {
			// the items of this will become children of x
			new Bling(x).append(this)
			return this
		},

		prepend: function prepend(x) {
			// insert x before the first child of each node in this
			x = toNode(x)
			this.take(1).each(function() { _before(this.childNodes[0], x) })
			this.skip(1).each(function() { _before(this.childNodes[0], deepClone(x)) })
			return this
		},

		prependTo: function prependTo(x) {
			// the items of this will become the first children of x
			new Bling(x).prepend(this)
			return this
		},

		before: function before(x) {
			// insert x before this
			x = toNode(x)
			this.take(1).each(function() { _before(this, x) })
			this.skip(1).each(function() { _before(this, deepClone(x)) })
			return this
		},

		after: function after(x) {
			// insert x after this
			x = toNode(x)
			this.take(1).each(function() { _after(this, x) })
			this.skip(1).each(function() { _after(this, deepClone(x)) })
			return this
		},

		wrap: function wrap(parent) {
			// all items of this will become children of parent
			// parent will take each child's position in the DOM
			parent = toNode(parent)
			if( isFragment(parent) )
				throw new Error("cannot wrap something with a fragment")
			return this.map(function(child) {
				if( isFragment(child) ) {
					parent.appendChild(child)
				} else if( isNode(child) ) {
					var p = child.parentNode
					if( ! p ) {
						parent.appendChild(child)
					} else {
						// swap out the DOM nodes using a placeholder element
						var marker = document.createElement("dummy");
						// put a marker in the DOM, put removed node in new parent
						parent.appendChild( p.replaceChild(marker, child) )
						// replace marker with new parent
						p.replaceChild(parent, marker)
					}
				}
				return child
			})
		},

		unwrap: function unwrap() {
			// replace the parent with the child
			return this.each(function() {
				if( this.parentNode && this.parentNode.parentNode )
					this.parentNode.parentNode.replaceChild(this, this.parentNode)
			})
		},

		attr: function attr(a,v) {
			// get or set an attribute value
			var f = v ? "setAttribute" : "getAttribute"
			var ret = this.zip(f).call(a,v)
			return v ? this : ret;
		},

		addClass: function addClass(x) {
			// add class 'x' to the nodes of this
			// remove the node and then add it to avoid dups
			return this.removeClass(x).each(function() {
				var c = this.className.split(" ").filter(function(y){return y && y != ""})
				c.push(x)
				this.className = c.join(" ")
			})
		},

		removeClass: function removeClass(x) {
			// remove class x from each node's .className property
			var notx = function(y){ return y != x }
			return this.each(function() {
				var cls = this.className.split(" ").filter(notx).join(" ")
			})
		},

		toggleClass: function toggleClass(x) {
			// toggles class x for each node in this
			var notx = function(y){ return y != x }
			return this.each(function(node) {
				var cls = node.className.split(" ")
				if( cls.indexOf(x) > -1 )
					node.className = cls.filter(notx).join(" ")
				else
					node.className = cls.push(x).join(" ")
			})
		},

		hasClass: function hasClass(x) {
			// collect a boolean for each item in this
			// note: different from jQuery, we always return sets when possible
			this.zip('className.split').call(" ")
				.zip('indexOf').call(x)
				.map(Function.IndexFound)
		},

		text: function text(t) {
			// gets/sets the .innerText of all elements
			return t ? this.zap('innerText', t)
				: this.zip('innerText')
		},

		val: function val(v) {
			// get/set the values of the nodes in the list
			return v ? this.zap('value', v)
				: this.zip('value')
		},

		css: function css(k,v) {
			// get/set css properties for nodes in the list
			// called with string k and undefd v -> return value of k
			// called with string k and string v -> set property k = v
			// called with object k and undefd v -> set css(x, k[x]) for x in k
			if( hasValue(v) || isObject(k) ) {
				var setter = this.zip('style.setProperty')
				if( isString(k) )
					setter.call(k, v) // if v is present set the value on each element
				else for(var x in k)
					setter.call(x, k[x])
				return this
			}
			// collect the computed values
			var cv = this.map(window.getComputedStyle).zip('getPropertyValue').call(k)
			// collect the values specified directly on the node
			var ov = this.zip('style').zip(k)
			// weave and fold them so that object values override computed values
			return ov.weave(cv).fold(function(x,y) { return x ? x : y })
		},
		width: function width(w) { 
			// sugar
			return this.css('width', w)
		},
		height: function height(h) {
			// sugar
			return this.css('height', h)
		},

		center: function center(mode) {
			// move the elements to the center of the screen
			mode = mode || "viewport"
			var vh = document.body.clientHeight/2,
				vw = document.body.clientWidth/2
			return this.each(function() {
				var t = $(this),
					h = parseFloat(t.height().first()),
					w = parseFloat(t.width().first()),
					x = (mode == "viewport" || mode == "horizontal" 
						? document.body.scrollLeft + vw - (w/2)
						:  NaN)
					y = (mode == "viewport" || mode == "vertical"
						? document.body.scrollTop + vh - (h/2)
						: NaN)
				t.css({ position: "absolute",
					left: (isNumber(x) ? x+"px" : undefined),
					top: (isNumber(y) ? y+"px" : undefined)
				})
			})
		},


		trueColor: function trueColor(prop, reducer) {
			// getComputedStyle won't tell us what the actual visible
			// color of an element is, if there is transparency involved
			// so we manually calculate the elements visible color
			// NOTE: does not handle elements that are absolutely positioned
			// outside of their parent
			// by default, compute the background color, but call with 'color'
			// to compute the foreground color
			prop = prop || "background-color";
			function reducer(a) {
				// combine two rgba color arrays
				a[0] += (this[0] - a[0]) * this[3];
				a[1] += (this[1] - a[1]) * this[3];
				a[2] += (this[2] - a[2]) * this[3];
				a[3] = Math.min(1, a[3] + this[3]);
				return a;
			}
			// collect the full ancestry
			return this
				.parents()
				.map(function() {
					return this
						// get the computed style of each ancestor
						.map(window.getComputedStyle)
						.filter(hasValue)
						// get the indicated property
						.zip('getPropertyValue')
						.call(prop)
						// remove junk results (nulls, etc)
						.filter(isString)
						// parse to [r,g,b,a]
						.toColors()
						// reverse the order so we add colors from back to fore
						.reverse()
						// then collapse each list of [r,g,b,a]
						.reduce(reducer, new Bling([0,0,0,0]))
						// and output a css string
						.toRGBAString()
				})
		},

		toColors: function toColors() {
			// convert any css color strings to numbers
			if( this.length == 0 ) return this;
			return this.map(function() {
				if( isString(this) ) {
					var d = document.createElement("div");
					d.style.color = this;
					var rgb = d.style.getPropertyValue('color');
					if( rgb ) {
						// grab between the parens
						rgb = rgb.slice(rgb.indexOf('(')+1, rgb.indexOf(')'))
							// make an array
							.split(", ")
						if( rgb.length == 3 ) rgb[3] = 1.0;
						// return floats
						return new Bling( rgb ).floats()
					}
				}
			})
		},

		toRGBAString: function toRGBAString() {
			// convert numbers to an rgb string
			if( this.length == 0 ) return this;
			return this.length == 4 ? "rgba("+this.join(", ")+")"
				: this.length == 3 ? "rgb("+this.join(", ")+")"
				: undefined;
		},

		// .child(n) returns the nth childNode for all items in this
		child: function child(n) { return this.map(function() { return this.childNodes[n] })},
		// .children() returns all children of each node
		children: function children() { return this.map(function() { return new Bling(this.childNodes) })},

		// .parent() returns the parentNodes of all items in this
		parent: function parent() { return this.zip('parentNode') },

		// .parents() returns all the parentNodes up to the owner for each item in this
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
				}
			});
		},

		// .find(expr) maps querySelectorAll(expr) over each element in this
		find: function find(expr) {
			return this.map(function() { return new Bling(expr, this) })
				.reduce(function(a) { return a.concat(this) })
		},

		// .clone() deep copies a set of DOM nodes
		// note: does not copy event handlers
		clone: function clone() {
			return this.map(deepClone)
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
			// console.log("toFragment",this.zip('parentNode.toString').call().join(" "));
			if( this.length == 1 )
				return toNode(this[0])
			var f = document.createDocumentFragment()
			this.map(toNode).map(f.appendChild.bound(f))
			return f
		}
	})

	/// Events Module: provides for binding and triggering DOM events ///

	// construct a bind helper for the .click() bind aliases
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
		// .once() binds an event handler that will run only once
		once: function once(e, f) {
			var g = function(evt) {
				f.call(this, evt)
				this.unbind(e, g)
			}
			return this.bind(e, g);
		},
		// .cycle() cycles through a set of handlers, each trigger fires the next callback
		cycle: function cycle(e/*, functions*/) {
			var i = 0, funcs = arguments.slice(1,arguments.length)
			return this.bind(e, function(evt) {
				funcs[i].call(this, evt)
				i = i++ % funcs.length
			})
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
				cancelable: true
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
						relatedTarget: null
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
						rotation: 0.0
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
						rotation: 0.0
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
		ready: binder('load'),
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
		gesturecancel: binder('gesturecancel')

	})


	/// Transformation Module: provides wrapper for using -webkit-transform ///
	Bling.addGlobals({
		// how long are various speeds
		duration: function duration(speed) {
			var speeds = {
				"slow": 700,
				"medium": 500,
				"normal": 300,
				"fast": 100
			}
			var s = speeds[speed]
			var ret = s ? s : parseFloat(speed);
			return ret;
		}
	})
	Bling.addMethods({
		// like jquery's animate(), but using only webkit-transition/transform
		transform: function transform(end_css, speed, callback) {
			if( typeof(speed) == "function" ) {
				callback = speed
				speed = undefined
			}
			speed = speed || "normal";
			var duration = Bling.duration(speed);
			// collect the list of properties to be modified
			var props = [];
			// what to send to the -webkit-transform
			var trans = "";
			// real css values to be set (end_css without the transform values)
			var css = {};
			for( var i in end_css )
				// pull all the transform values out of end_css
				if( /(?:scale|translate|rotate|scale3d|translateX|translateY|translateZ|translate3d|rotateX|rotateY|rotateZ|rotate3d)/.test(i) ) {
					var ii = end_css[i]
					if( ii.join )
						ii = ii.join(", ")
					else if( ii.toString )
						ii = ii.toString()
					trans += " " + i + "(" + ii + ")";
				}
				else // stick real css values in the css dict
					css[i] = end_css[i]
			// make a list of the properties to be modified
			for( var i in css )
				props.push(i);
			// and include -webkit-transform if we have data there
			if( trans )
				props.push("-webkit-transform");
			this.css('-webkit-transition-property', props.join(', '));
			// repeat the duration the same number of times as there are properties
			this.css('-webkit-transition-duration', props.map(function() { return duration + "ms" }).join(', '));
			// apply the real css
			for( var i in css )
				this.css(i, css[i])
			// apply the transformation
			if( trans )
				this.css('-webkit-transform', trans);
			// console.log("css",css,"trans",trans,"props",props)
			// queue the callback to be executed
			return this.future(duration, callback);
		},

		hide: function hide(callback) {
			// console.log('in hide',this.zip('parentNode.toString').call().join(" "));
			var ret = this.each(function() {
				// console.log("hide each guid "+this.guid+" "+this.parentNode.toString());
				this._display = this.style.display == "none" ? undefined : this.style.display;
				this.style.display = 'none';
			})
			if( callback ) callback.call(this)
			// console.log('end of hide '+this.zip('guid')+" "+this.zip('parentNode.toString').call().join(" "));
			return ret
		},

		show: function show(callback) {
			return this.each(function() {
				this.style.display = this._display ? this._display : "block";
				this._display = undefined;
			}).future(50, callback)
		},

		toggle: function toggle(callback) {
			return this.each(function() {
				var d = $(this).css("display").first()
				if( d == "none" ) {
					if( this._display != undefined ) {
						this.style.display = this._display
						this._display = undefined
					} else {
						this.style.display = "block"
					}
				} else {
					this._display = d;
					this.style.display = "none";
				}
				if( callback  ) callback.call(this)
			})
		},

		fadeIn: function fadeIn(speed, callback) {
			return this
				.css('opacity','0.0')
				.show(function (){
					this.transform({opacity:"1.0", translate3d:[0,0,0]}, speed, callback)
				})
		},
		fadeOut:   function fadeOut(speed, callback, _x, _y) {
			_x = _x || 0.0
			_y = _y || 0.0
			return this.each(function(t) {
				$(t).transform({
					opacity:"0.0",
					translate3d:[_x,_y,0.0]
				}, speed, function () { this.hide() })
			}).future(Bling.duration(speed), callback)
		},
		fadeLeft:  function fadeLeft(speed, callback)  {
			return this.fadeOut(speed, callback, "-"+this.width().first(), 0.0)
		},
		fadeRight: function fadeRight(speed, callback) {
			return this.fadeOut(speed, callback, this.width().first(), 0.0)
		},
		fadeUp:    function fadeUp(speed, callback)    {
			return this.fadeOut(speed, callback, 0.0, "-"+this.height().first())
		},
		fadeDown:  function fadeDown(speed, callback)  {
			return this.fadeOut(speed, callback, 0.0, this.height().first())
		}
	})

	/// Database Module: provides access to the sqlite database ///

	// static error handler
	function SqlError(t, e) { throw new Error("sql error ["+e.code+"] "+e.message) }

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
	})
	Bling.addMethods({
		// .transaction() provides access to the db's raw transaction() method
		// but, use .sql() instead, its friendlier
		transaction: function transaction( f ) {
			this.zip('transaction').call(f)
			return this
		},

		// short-cut for .transaction(function(t){t.executeSql(sql, values, callback, errors)})
		// only the sql is required
		sql: function sql(sql, values, callback, errors) {
			if( sql == undefined ) return undefined
			if( typeof(values) == "function") {
				errors = callback
				callback = values
				values = undefined
			}
			values = values || []
			callback = callback || Function.Empty
			errors = errors || SqlError
			assert( isType(this[0], "Database"), "can only call .sql() on a bling of Database" )
			return this.transaction(function(t) {
				t.executeSql(sql, values, callback, errors)
			})
		}

	})

	/// HTTP Request Module: provides wrappers for making http requests ///

	// static helper to create &foo=bar strings from object properties
	var formencode = function(obj) {
		var s = [], o = JSON.parse(JSON.stringify(obj)) // quickly remove all non-stringable items
		for( var i in o )
			s.push( i + "=" + escape(o[i]))
		return s.join("&")
	}

	Bling.addGlobals({
		http: function http(url, opts) {
			var xhr = new XMLHttpRequest()
			if( isFunc(opts) )
				opts = {success: opts.bound(xhr)}
			opts = Bling.extend({
				method: "GET",
				data: null,
				state: Function.Empty, // onreadystatechange
				success: Function.Empty, // onload
				error: Function.Empty, // onerror
				async: true,
				withCredentials: false
			}, opts)
			opts.state = opts.state.bound(xhr)
			opts.success = opts.success.bound(xhr)
			opts.error = opts.error.bound(xhr)
			if( opts.data && opts.method == "GET" )
				url += "?" + formencode(opts.data)
			else if( opts.data && opts.method == "POST" )
				opts.data = formencode(opts.data)
			xhr.open(opts.method, url, opts.async)
			xhr.withCredentials = opts.withCredentials
			xhr.onreadystatechange = function onreadystatechange() {
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
		}

	})

	/// Dialog Module: pop any content up as an optionally modal dialog

	function addButton(d, name, f) {
		var b = d.find(".buttons")
		if( b.length == 0 )
			b = d.append("<div class='buttons'></div>").find(".buttons")

		name = name || "undefined"
		name = name.replace(/_/g, " ")

		return $("<button>"+name+"</button>")
			.bind('click', f.bound(d))
			.appendTo(b)
	}
	function checkDialog(t) {
		if( !t.isDialog ) { throw new Error("dialog expected") }
	}

	Bling.addMethods(
		function dialog(/*cmd, buttons... */) {
			var i = 0, n = arguments.length, cmd = 'create';
			if( isString(arguments[0]) ) { 
				cmd = arguments[0];
				i++;
			}

			if( 'create' == cmd ) {
				if( this.isDialog ) return this;
				var d = $("<div class='dialog' style='display:none'/>")
				d.isDialog = true
				this.wrap(d)
				// save this in case it moves later
				d.contentNode = d[0].childNodes[0]
				if( i == n )
					addButton(d, "OK", function(){ this.hide() })
				for(; i < n; i++) {
					var a = arguments[i];
					if( a == null || isString(a) ) { } // ignore
					else if( isFunc(a) ) addButton(d, a.name, a) // add funcs by name
					else // add object property funcs
						for(var name in a)
							if( isFunc(a[name]) )
								addButton(d, name, a[name]);
				}
				if( d[0].parentNode == null )
					d.appendTo("body")
				// save its current position if it has one
				var top = d.css("top").first(),
					left = d.css("left").first()
				// and float it above the same spot
				return d.css("position","absolute")
					.css("top",top).css("left",left)

			} else if( 'destroy' == cmd ) {
				checkDialog(this);
				this.isDialog = false
				return $(this.contentNode).unwrap()
			}
		}
	)

})()

// save our operator, bling!
$ = Bling.operator



