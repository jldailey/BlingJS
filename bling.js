/* bling.js
 * --------
 * Named after the bling operator ($) to which it is bound by default.
 * this is a jQuery-like framework, using any WebKit shortcuts that we can.
 * All other browsers play at your own risk.
 * Blame: Jesse Dailey <jesse.dailey@gmail.com>
 */

/* Inheritance
 * -----------
 * A.inherit(T) will make A inherit members from type T.
 * Example (a subclass of Array):
 > function MyType(){
 >	 Array.apply(this, arguments);
 > }
 > MyType.inherit(Array)
 > var a = new MyType()
 > a.push("foo")
 */
Function.prototype.inherit = function inherit(T) {
	this.prototype = new T() // get a copy of T's prototype (a copy!)
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
	// isType(a,T) - true if object a is of type T (directly)
	return !a ? T === a
		: typeof(T) === "string" ? a.__proto__.constructor.name == T
			: a.__proto__.constructor === T
}
function isSubtype(a, T) {
	// isSubtype(a,T) - true if object a is of type T (directly or indirectly)
	return a == null ? a == T
		: a.__proto__ == null ? false
		: a.__proto__.constructor == T ? true
		: isSubtype(a.__proto__, T) // recursive
}
function isString(a) {
	// isString(a) - true if object a is a string
	return typeof(a) == "string" || isSubtype(a, String)
}
// isNumber(a) - true if object a is a number
isNumber = isFinite
function isFunc(a) {
	// isFunc(a) - true if object a is a function
	return typeof(a) == "function" || isType(a, Function)
}
function isNode(a) {
	// isNode(a) - true if object is a DOM node
	return a ? a.nodeType > 0 : false
}
function isFragment(a) {
	// isFragment(a) - true if object is a DocumentFragment node
	return a ? a.nodeType == 11 : false
}
function isArray(a) {
	// isArray(a) - true if object is an Array (or inherits Array)
	return a ? Function.ToString(a) == "[object Array]"
		|| isSubtype(a, Array) : false
}
function isObject(a) {
	// isObject(a) - true if a is an object
	return typeof(a) == "object"
}
function hasValue(a) {
	// hasValue(a) - true if a is not null nor undefined
	return !(a == null)
}


/* Function Binding
 * ----------------
 * This lets you bind the 'this' context of a function at a separate time
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
 * Once a function is bound, it cannot be re-bound, called, or applied,
 * in any other context than the one it was first bound to.
 *
 *   more_stars = ["Janet", "Micheal", "Latoya"];
 *   more_stars.num_stars = num_stars; // normally this would cause binding
 *   more_stars.num_stars() == 2
 *   num_stars.call(more_stars) == 2
 *   num_stars.apply(more_stars, []) == 2
 *
 * Why 2?  Because num_stars will always act on its original binding, not the
 * binding to more_stars.
 *
 */
Function.prototype.bound = function bound(t, args) {
	var f = this // the original function
	function r() { return f.apply(t, args ? args: arguments) }
	r.toString = function _toString() { return "bound-method of "+t+"."+f.name+"(...) { [code] }" }
	return r
}
// a useful example, to just call log(...) instead of console.log(...):
// var log = window.console ? console.log.bound(console) : Function.Empty

// Define some global static functions that will be
// used to avoid creating closures to do these things
Function.Empty = function empty(){}
Function.NotNull = function notnull(x) { return x != null }
Function.NotUndefined = function notundefined(x) { return x != undefined }
Function.IndexFound = function found(x) { return x > -1 }
Function.ReduceAnd = function reduceand(x) { return x && this }
Function.UpperLimit = function upperlimit(x) { return function(y) { return Math.min(x, y) }}
Function.LowerLimit = function lowerlimit(x) { return function(y) { return Math.max(x, y) }}
var Object_prototype_toString = Object.prototype.toString // cache the reference
Function.ToString = function tostring(x) { return Object_prototype_toString.apply(x) }
String.HtmlEscape = function htmlescape(x) {
	// String.HtmlEscape(string) - take an string of html, return a string of escaped html
	return x.replace(/</g,'&lt;')
	.replace(/>/g,'&gt;')
	.replace(/\t/g,'&nbsp;&nbsp;')
}
String.PadLeft = function pad(s, n, c) {
	// String.PadLeft(string, width, fill=" ")
	c = c || " "
	while( s.length < n ) {
		s = c + s
	}
	return s
}
String.Splice = function splice() {
	// String.Splice(start, length, ...) - replace a substring with ...
	var s = arguments[0], a = arguments[1], b = arguments[2],
		repl = Array.Slice(arguments, 3).join('')
	return s.substring(0,a) + repl + s.substring(b)
}
// Array.Slice works like python's slice (negative indexes, etc)
// and works on any indexable (not just array instances, notably 'arguments')
Array.Slice = function slice(o, i, j) {
	var a = [], k = 0, n = o.length,
		end = j == undefined ? n
			: j < 0 ? n + j
			: j,
		start = i == undefined ? 0
			: i < 0 ? n + i
			: i
	while( start < end )
		a[k++] = o[start++]
	return a
}
// return a number with "px" attached, suitable for css
Number.Px = function npx(x,d) { return (parseInt(x)+(d|0))+"px" }
// return a functor that adds "px" to it's 'this'
Function.Px = function fpx(d) { return function() { return Number.Px(this,d) } }

// Function.PrettyPrint gets its own little private namespace
;(function() {
	var operators = /!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g,
		keywords = /\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b/g,
		singleline_comment = /\/\/.*?\n/,
		multiline_comment = /\/\*(?:.|\n)*?\*\//,
		all_numbers = /\d+\.*\d*/g
	function find_unescaped_quote(s, i, q) {
		var r = s.indexOf(q, i)
		while( s.charAt(r-1) == "\\" && r < s.length && r > 0)
			r = s.indexOf(q, r+1)
		return r
	}
	function find_first_quote(s, i) {
		var a = s.indexOf('"', i),
			b = s.indexOf("'", i)
		if( a == -1 ) a = s.length
		if( b == -1 ) b = s.length
		return a == b ? [null, -1]
			: a < b ? ['"', a]
			: ["'", b]
	}
	function extract_quoted(s) {
		var i = 0, n = s.length, ret = [],
			j = -1, k = -1, q = null
		if( ! isString(s) )
			if( ! isFunc(s.toString) )
				throw TypeError("invalid string argument to extract_quoted")
			else {
				s = s.toString()
				n = s.length
			}
		while( i < n ) {
			q = find_first_quote(s, i)
			j = q[1]
			if( j == -1 ) {
				ret.push(s.substring(i))
				break
			}
			ret.push(s.substring(i,j))
			k = find_unescaped_quote(s, j+1, q[0])
			if( k == -1 )
				throw Error("unmatched "+q[0]+" at "+j)
			ret.push(s.substring(j, k+1))
			i = k+1
		}
		return ret
	}
	function first_comment(s) {
		var a = s.match(singleline_comment),
			b = s.match(multiline_comment)
			return a == b ? [-1, null]
				: a == null && b != null ? [b.index, b[0]]
				: a != null && b == null ? [a.index, a[0]]
				: b.index < a.index ? [b.index, b[0]]
				: [a.index, a[0]]
	}
	function extract_comments(s) {
		var ret = [], i = 0, j = 0,
			n = s.length, q = null, ss = null
		while( i < n ) {
			ss = s.substring(i)
			q = first_comment(ss)
			j = q[0]
			if( j > -1 ) {
				ret.push(ss.substring(0,j))
				ret.push(q[1])
				i += j + q[1].length
			} else {
				ret.push(ss)
				break
			}
		}
		return ret
	}
	var has_injected_css = false;
	Function.PrettyPrint = function prettyPrint(js) {
		var i = 0, n = 0
		if( isFunc(js) )
			js = js.toString()
		if( ! isString(js) )
			throw TypeError("prettyPrint requires a function or string to format")
		if( ! has_injected_css ) {
			$("head").append("<style> .pretty .opr { color: #880; } .pretty .str { color: #008; } .pretty .com { color: #080; } .pretty .kwd { color: #088; } .pretty .num { color: #808; }</style>")
			has_injected_css = true;
		}
		// extract comments
		return "<pre class='pretty'>"+$(extract_comments(js))
			.fold(function _foldcom(text, comment) {
				// extract quoted strings
				return $(extract_quoted(text))
					.fold(function _foldquot(code, quoted) {
						// label number constants
						return (code
							// label operator symbols
							.replace(operators, "<span class='opr'>$&</span>")
							// label numbers
							.replace(all_numbers, "<span class='num'>$&</span>")
							// label keywords
							.replace(keywords, "<span class='kwd'>$&</span>")
							.replace(/\t/g, "&nbsp;&nbsp;")
						) +
						// label string constants
						(quoted ? "<span class='str'>"+quoted+"</span>" : "")
					})
					.join('')
					+
					(comment ? "<span class='com'>"+comment+"</span>" : "")
			})
			.join('')
			+"</pre>"
	}
})()

/* Bling, the constructor.
 * -----------------------
 * Bling(expression, context):
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
function Bling (selector, context) {
	if( isBling(selector) ) // accept Bling objects, but do nothing
		return selector
	// the default context is the entire document
	context = context || document

	if( selector === undefined )
		return Bling.__init__(selector, context, [])

	if( typeof selector === "string" ) { // strings, search css or parse html
		// accept two different kinds of strings: html, and css expression
		// html begins with "<", and we create a set of nodes by parsing it
		// anyu other string is considered css

		selector = selector.trimLeft()

		if( selector[0] == "<" )
			return Bling.__init__(selector, context, [Bling.HTML.parse(selector)])

		// anything else is a css expression, for querySelectorAll
		// if we are searching inside another Bling
		// then search each item in the bling, and accumulate in one bling
		if( isBling(context) )
			return context.reduce(function _reduce(a, x) {
				a.union(x.querySelectorAll(selector))
			}, Bling.__init__(selector, context, []))

		if( context.querySelectorAll != undefined )
			// if the context is directly searchable, search it
			try {
				return Bling.__init__(selector, context, context.querySelectorAll(selector))
			} catch ( err ) {
				console.log("err",err,selector,context)
				return null
			}

		// otherwise, this is not a valid context
		throw new Error("invalid parameters: " + selector + ", " + context)
	}

	if( typeof(selector) === "number" ) // numbers pre-allocate
		// accept a single number, to pre-allocate space
		return Bling.__init__(selector, context, new Array(selector))

	if( selector === window || isNode(selector) ) // single items get stored
		// a single node becomes the sole item in our array
		return Bling.__init__(selector, context, [selector])

	if( selector.length != undefined )
		// use any array-like object directly
		// careful to check for === window _before_ this check, as window.length is defined
		return Bling.__init__(selector, context, selector)

	// everything else, just wrap in an array
	return Bling.__init__(selector, context, [selector])

}
// finish defining the Bling type
Bling.inherit(Array)
function isBling(a)  { return isType(a, Bling) }

Bling.__init__ = function __init__(selector, context, arr) {
	// attach like a parasite to just this instance of arr
	arr.__proto__ = Bling.prototype
	arr.selector = selector
	arr.context = context
	return arr
}


/* Simple object extension:
 * .extend() will merge values from b into a
 * if c is present, it should be a list of property names to copy
 */
Bling.extend = function extend(a, b, c) {
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

/* Extend the API
 *
 * addOps accepts an object full of functions, or a list of named functions
 * ex. Bling.addOps({"echo": function echo() { ... }})
 *     Bling.addOps(function echo() { ... })
 *
 * Both of the above will result in $().echo() being defined.
 *
 */
Bling.addOps = function addOps(/*arguments*/) {
	// .addOps() - adds bling operations
	// ex. Bling.addOps({nop:function(){ return this; })
	// ex. Bling.addOps(function nop(){ return this })
	// $("body").nop().nop()
	for(var i = 0, n = arguments.length; i < n; i++) {
		var a = arguments[i]
		if( isFunc(a) ) {
			if( a.name == null ) throw new Error("cannot extend with an anonymous method (must have a name)")
			Bling.prototype[a.name] = a
		} else if( isObject(a) ) {
			Bling.extend(Bling.prototype, a)
		} else {
			throw new Error("can only extend by an object or function, not:" + typeof(a))
		}
	}
}

Bling.module = function module(name, Module) {
	var m = Module(),
		f = arguments.callee
	f.order.push(name)
	f[name] = m
	Bling.addOps(m)
}
Bling.module.order = []

Bling.module('Core', function () {
	/// Core Module ///

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
		// next() consumes the next handler on the queue
		this.next = function next() {
			// consume all 'due' handlers
			if( this.queue.length > 0 )
				// shift AND call
				this.queue.shift()()
		}.bound(this)
		// schedule(f, n) sets f to run after n or more milliseconds
		this.schedule = function schedule(f, n) {
			if( !isFunc(f) ) return
			var nn = this.queue.length
			// get the absolute scheduled time
			f.order = n + new Date().getTime()
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
			setTimeout(this.next, n)
		}
	}
	var timeoutQueue = new TimeoutQueue()

	function unmask(x) {
		if( isObject(x) && isNumber(x) )
			return Number(x)
		return x
	}

	return {

		each: function each(f) {
			// .each(/f/) - applies /f/ to every /x/ in _this_
			var i = -1,
				n = this.len(),
				t = null
			while( ++i < n ) {
				t = this[i]
				f.call(t, t)
			}
			return this
			/* Example:
				> $("input[type=text]").each(function() {
				>		this.value = "HI!"
				>	})
			*/
		},

		map: function map(f) {
			// .map(/f/) - collects /x/./f/(/x/) for /x/ in _this_
			var n = this.len(),
				a = Bling(n),
				i = 0, t = null
			a.context = this
			a.selector = f
			for(; i < n; i++ ) {
				t = this[i]
				try { a[i] = f.call(t, t) }
				catch( e ) {
					if( isType(e, TypeError) ) a[i] = f(t)
					else throw e
				}
			}
			return a
			/* Example:
				> $([1, 2, 3]).map(function() {
				> 	return this * 2
				> })
				> == $([2, 4, 6])
			*/

		},

		reduce: function reduce(f, init) {
			// .reduce(/f/, [initial]) - a = /f/(a, /x/) for /x/ in _this_
			// along with respecting the context, we pass only the accumulation and one argument
			// so you can use functions like Math.min directly $([1,2,3]).reduce(Math.min)
			// this fails with the ECMA reduce, since Math.min(a,x,i,items) is NaN
			if( !f ) return this
			var a = init,
				t = this
			if( init == null ) {
				a = this[0]
				t = this.skip(1)
			}
			t.each(function _reducer() {
				a = f.call(this, a, this)
			})
			return a
			/* Example:

				> $([12, 14, 9, 37]).reduce(Math.min)
				> == 9

				But, you can accumulate anything easily, given an initial value.

				> $([ [1,2,3], [3,6,9] ]).reduce(function(a, x) {
				> 	a[0] += x[0]
				> 	a[1] += x[1]
				> 	a[2] += x[2]
				> }, [0, 0, 0])
				> == $([4, 8, 12])

				You can use any function that takes 2 arguments, including several useful built-ins.

				> $([12, 13, 47, 9, 22]).reduce(Math.min)
				> == 9

			*/
		},

		filter: function filter(f) {
			// .filter(/f/) - collect all /x/ from _this_ where /x/./f/(/x/) is true
			// or if f is a selector string, collects nodes that match the selector
			var i = 0, j = -1, n = this.length,
				b = Bling(n), it = null
			b.context = this
			b.selector = f
			for(; i < n; i++ ) {
				it = this[i]
				if( it ) {
					if ( isFunc(f) && f.call( it, it )
						|| isString(f) && it.webkitMatchesSelector && it.webkitMatchesSelector(f)) {
						b[++j] = it
					}
				}
			}
			return b
			/* Example:
				> $([1,2,3,4,5,6]).filter(function() {
				> 	return this % 2 == 0
				> })
				> == $([2,4,6])

				Or, you can filter by a selector.

				> $("pre").filter(".prettyprint")

			*/
		},

		matches: function matches(expr) {
			// .matches(expr) - collects true if /x/.matchesSelector(/expr/) for /x/ in _this_
			return this.map(function _matcher() {
				if( this.webkitMatchesSelector )
					return this.webkitMatchesSelector(expr)
				return false
			})
			/* Example:
				> $("pre").matches(".prettyprint")
				> $([true, false, false, true, etc...])
			*/
		},

		union: function union(other) {
			// .union(other) - collect all /x/ from _this_ and /y/ from _other_
			// no duplicates, use concat if you want to preserve dupes
			var ret = Bling(),
				i = 0, j = 0, x = null
			ret.context = this.context
			ret.selector = this.selector
			this.each(function _unioner() {
				ret[i++] = this
			})
			while(x = other[j++]) {
				if( ! ret.contains(x) ) {
					ret[i++] = x
				}
			}
			return ret
		},

		intersect: function intersect(other) {
			// .intersect(other) - collect all /x/ that are in _this_ and _other_
			var ret = Bling(),
				i = 0, j = 0, x = null,
				n = this.length, nn = other.length
			ret.context = this.context
			ret.selector = this.selector
			if( isBling(other) ) {
				for(; i < n; i++) {
					if( other.contains(this[i]) ) {
						ret[ret.length] = this[i]
					}
				}
			} else {
				for(i = 0; i < n; i++) {
					for(; j < nn; j++) {
						if( this[i] == other[j] ) {
							ret[ret.length] = this[i]
							continue
						}
					}
				}
			}

			return ret
		},

		distinct: function distinct() {
			// .distinct() - get a shallow copy of _this_ with duplicates removed.
			return this.union(this)
			/* Example:
				> $([1, 2, 3, 1, 4, 5]).distinct()
				> == $([1,2,3,4,5])
			*/
		},

		contains: function contains(item) {
			// .contains(item) - true if /item/ is in _this_, false otherwise
			return this.count(item) > 0
			/* Example:
				> $("body").contains(document.body)
				> == true
			*/
		},

		count: function count(item) {
			// .count(/x/) - returns the number of times /x/ is in _this_
			if( item == undefined ) return this.len()
			item = unmask(item)
			if( isObject(item) && isNumber(item) ) {
				// numbers masqueraded as an object should be unmasked
				item = Number(item)
			}
			var ret = 0
			this.each(function _count() {
				var t = this
				if( isObject(t) && isNumber(t) ) {
					t = Number(t)
				}
				if( t == item ) ret++
			})
			return ret
			/* Example:
				> $([1, 2, 3, 1, 2, 3, 1, 2, 3]).count(1)
				> == 3
			*/
		},

		zip: function zip() {
			// .zip([p, ...]) - collects /x/./p/ for all /x/ in _this_
			// recursively split names like "foo.bar"
			// zip("foo.bar") == zip("foo").zip("bar")
			// you can pass multiple properties, e.g.
			// zip("foo", "bar") == [ {foo: x["foo"], bar: x["bar"]}, ... ]
			function _get(p) {
				var v
				return function _getter() {
					v = this[p]
					return isFunc(v) ? v.bound(this) : v
				}
			}
			function _zip(p) {
				var i = p.indexOf(".")
				// split and recurse ?
				return i > -1 ? this.zip(p.substr(0, i)).zip(p.substr(i+1))
					// or map a getter across the values
					: this.map(_get(p))
			}
			switch( arguments.length ) {
				case 0:
					return this
				case 1:
					return _zip.call(this, arguments[0])
				default: // > 1
					// if more than one argument is passed, new objects
					// with only those properties, will be returned
					// like a "select" query in SQL
					var master = {},
						b = Bling(), n = arguments.length, nn = this.length,
						i = 0, j = 0, k = null
					// first collect a set of lists
					for(i = 0; i < n; i++) {
						master[i] = _zip.call(this, arguments[i])
					}
					// then convert to a list of sets
					for(i = 0; i < nn; i++) {
						var o = {}
						for(k in master)
							o[k] = master[k].shift() // the first property from each list
						b[j++] = o // as a new object in the results
					}
					return b
			}
			/* Example:
				> $(["foo", "bar", "bank"]).zip("length")
				> == $([3, 3, 4])

				You can use compound property names.

				> $("pre").first(3).zip("style.display")
				> == $(["block", "block", "block"])

				If you request many properties at once,
				you get back raw objects with only those properties.
				Similar to specifying columns on a SQL select query.

				> $("pre").first(1).zip("style.display", "style.color")
				> == $([ {'display': 'block', 'color': 'black'}, ])

				If the property value is a function,
				a bound-method is returned in its place.

				> $("pre").first(1).zip("getAttribute")
				> == $(["bound-method getAttribute of HTMLPreElement"])
				See: .call, .apply
			*/
		},

		zap: function zap(p, v) {
			// .zap(p, v) - set /x/./p/ = /v/ for all /x/ in _this_
			// just like zip, zap("a.b") == zip("a").zap("b")
			// but unlike zip, you cannot assign to many /p/ at once
			if( !p ) return this
			var i = p.indexOf(".")
			return i > -1 ?  // is /p/ a compound name like "foo.bar"?
				this.zip(p.substr(0, i)) // if so, break off the front
					.zap(p.substr(i+1), v) // and recurse
				// accept /v/ as an array of values
				: isArray(v) ? this.each(function _zaparray(x) {
					// i starts at -1 (since we didnt recurse)
					x[p] = v[++i] // so we increment first, ++i, to start at 0
				})
				// accept a single value v, even if v is undefined
				: this.each(function _zap() { this[p] = v })
			/* Example:
				Set a property on all nodes at once.
				> $("pre").zap("style.display", "none")
				Hides all <pre>'s.
			*/
		},

		take: function take(n) {
			// .take([n]) - collect the first /n/ elements of _this_
			// if n >= this.length, returns a shallow copy of the whole bling
			n = Math.min(n|0, this.len())
			var a = Bling(n), i = -1
			a.context = this.context
			a.selector = this.selector
			while( ++i < n )
				a[i] = this[i]
			return a
			/* Example:
				> $("p").take(3).length == 3

				> $([1, 2, 3, 4, 5, 6]).take(2)
				> == $([1, 2])
			*/
		},

		skip: function skip(n) {
			// .skip([n]) - collect all but the first /n/ elements of _this_
			// if n == 0, returns a shallow copy of the whole bling
			n = Math.min(this.len(), Math.max(0, (n|0)))
			var a = Bling( n )
				i = 0, nn = this.len() - n
			a.context = this.context
			a.selector = this.selector
			for(; i < nn; i++)
				a[i] = this[i+n]
			return a
			/* Example:
				> $([1, 2, 3, 4, 5, 6]).skip(2)
				> == $([3, 4, 5, 6])
			*/
		},

		last: function last(n) {
			// .last([n] - collect the last [/n/] elements from _this_
			// if n is not passed, returns just the last item (no bling)
			return n ? this.skip(this.len() - n)
				: this[this.length - 1]
			/* Example:
				> $([1, 2, 3, 4, 5]).last()
				> == 5

				> $([1, 2, 3, 4, 5]).last(2)
				> == $([4, 5])

			*/
		},

		first: function first(n) {
			// .first([n]) - collect the first [/n/] elements from _this_
			// if n is not passed, returns just the item (no bling)
			return n ? this.take(n)
				: this[0]
			/* Example:
				> $([1, 2, 3, 4, 5]).first()
				> == 1

				> $([1, 2, 3, 4, 5]).first(2)
				> == $([1, 2])
			*/
		},

		join: function join(sep) {
			// .join(sep) - concatenates all /x/ in _this_ using /sep/
			if( this.length == 0 ) return ""
			return this.reduce(function _joiner(j) {
				return j + sep + this
			})
			/* Example:
				> $([1, 2, 3, 4, 5]).join(", ")
				> == "1, 2, 3, 4, 5"
			*/
		},

		slice: function slice(start, end) {
			// .slice(i, [j]) - get a subset of _this_ including [/i/../j/-1]
			// the j-th item will not be included - slice(0,2) will contain items 0, and 1.
			// negative indices work like in python: -1 is the last item, -2 is second-to-last
			// undefined start or end become 0, or this.length, respectively
			var b = Bling(Array.Slice(this, start, end))
			b.context = this.context
			b.selector = this.selector
			return b
			/* Example:
				> var a = $([1, 2, 3, 4, 5])
				> a.slice(0,1) == $([1])
				> a.slice(0,-1) == $([1, 2, 3, 4])
				> a.slice(0) == $([1, 2, 3, 4, 5])
				> a.slice(-2) == $([4, 5])

			*/
		},

		concat: function concat(b) {
			// .concat(/b/) - insert all items from /b/ into _this_
			// note: different from union, allows duplicates
			// note: also, does not create a new array, extends _this_
			var i = this.len() - 1,
				j = -1,
				n = b.length
			while( j < n )
				this[++i] = b[++j]
			return this
			/* Example:
				> $([1, 2, 3]).concat([3, 4, 5])
				> == $([1, 2, 3, 3, 4, 5])
			*/
		},

		weave: function weave(b) {
			// .weave(/b/) - interleave the items of _this_ and the items of _b_
			// to produce: $([ ..., b[i], this[i], ... ])
			// note: the items from b come first
			// note: if b and this are different lengths, the shorter
			// will yield undefineds into the result, which always has
			// 2 * max(length) items
			var n = b.length,
				nn = this.length,
				c = Bling(2 * Math.max(nn, n))
				i = nn - 1
			c.context = this.context
			c.selector = this.selector
			// first spread out this bling, from back to front
			for(; i >= 0; i-- )
				c[(i*2)+1] = this[i]
			// then interleave the source items, from front to back
			while( ++i < n )
				c[i*2] = b[i]
			return c
			/* Example:
				> var a = $([0, 0, 0, 0])
				> var b = $([1, 1, 1, 1])
				> a.weave(b)
				> == $([1, 0, 1, 0, 1, 0, 1, 0])
			*/
		},

		fold: function fold(f) {
			// .fold(/f/) - call /f/ to reduce _this_ to half as many elements.
			// /f/ accepts two items from the set, and returns one.
			// .fold() will always return a set with half as many items
			// tip: use as a companion to weave.  weave two blings together,
			// then fold them to a bling the original size
			var n = this.len(), j = 0
			// at least 2 items are required in the set
			var b = Bling(Math.ceil(n/2)),
				 i = 0
			b.context = this.context
			b.selector = this.selector
			for( i = 0; i < n - 1; i += 2)
				b[j++] = f.call(this, this[i], this[i+1])
			// if there is an odd man out, make one last call
			if( n % 2 == 1 )
				b[j++] = f.call(this, this[n-1], undefined)

			return b
			/* Example:
				> var a = $([1, 1, 1, 1])
				> var b = $([2, 2, 2, 2])
				> a.weave(b) // == $([2, 1, 2, 1, 2, 1, 2, 1])
				>	.fold(function(x,y) {
				>		return x + y
				>	})
				> == $([3, 3, 3, 3])
			*/
		},

		flatten: function flatten() {
			// .flatten() - collect all /y/ in each /x/ in _this_
			var b = Bling(),
				n = this.len(), c = null, d = 0,
				i = 0, j = 0, k = 0;
			b.context = this.context
			b.selector = this.selector
			for(; i < n; i++)
				for(c = this[i], j = 0, d = c.length; j < d;)
					b[k++] = c[j++]
			return b
		},

		call: function call() {
			// .call([args]) - call all functions in _this_ [with args]
			return this.apply(null, arguments)
			/* Example:
				> $("pre").zip("getAttribute").call("class")
				> == $([... x.getAttribute("class") for each ...])
			*/
		},

		apply: function apply(context, args) {
			// .apply(context, [args]) - collect /f/.apply(/context/,/args/) for /f/ in _this_
			return this.map(function _apply() {
				if( isFunc(this) )
					return this.apply(context, args)
				return this
			})
			/* Example:
				>	var a = {
				>		x: 1,
				>		get1: function() {
				>			return this.x
				>		}
				>	}
				>	var b = {
				>		x: 2,
				>		get2: function() {
				>			return this.x
				>		}
				>	}
				> b.get2() == 2
				> a.get1() == 1
				> $([a.get1, b.get2]).apply(a)
				> == $([1, 1])

				This happens because both functions are called
				with 'a' as 'this', since it is the context argument to apply().

				(IOW, it happens because b.get2.apply(a) == 1)
			*/

		},

		toString: function toString() {
			// .toString() - maps and joins toString across all elements
			return Bling.symbol
				+"(["
				+this.map(function _str(){
					return this == undefined || this == window ? "undefined"
						: this == null ? "null"
						: this.toString().replace(/\[object (\w+)\]/,"$1")
				}).join(", ")
				+"])"
			/* Example:
				> $("body").toString()
				> == "$([HTMLBodyElement])"
			*/
		},

		future: function future(n, f) {
			// .future(n, f) -  continue with /f/ on _this_ after /n/ milliseconds
			if( f ) { timeoutQueue.schedule(f.bound(this), n) }
			return this
			/* Example:
				> $("pre").future(50, function sometimeLater() {
				> 	console.log(this.length)
				> })
				> console.log($("pre").length)

				The same number will log twice, one 50 milliseconds
				or more after the other.

				.future() is nearly identical to setTimeout(), except for two key differences: perserving context, and most importantly, perserving order.
				See the comments on TimeoutQueue for a detailed explanation, but setTimeout does not guarantee that handlers will be executed in the order they were scheduled to execute.

				By adding this small guarantee, .future() becomes much more useful than a raw setTimeout.
			*/

		},

		log: function log(label) {
			// .log([label]) - console.log([label] + /x/) for /x/ in _this_
			if( label ) console.log(label, this, this.length + " items")
			else console.log(this, this.length + " items")
			return this
			/* Example:
				$("a + pre").text().log("example")
				// this will log: "example: some text content"
				// for every matching node
			*/
		},

		len: function len() {
			// .len() - returns the largest not-undefined index + 1
			// the .length of an array is more like capacity than length
			// this counts backward from .length, looking for a valid item
			// returns the found index + 1
			var i = this.length
			while( i > -1 && this[--i] == undefined) {/*spin*/}
			return i+1
			/* Example:
				If you create an empty array with spare capacity
				> var b = new Array(10)
				> b.length === 10
				But .length isnt where .push, .forEach, etc will operate.
				> b[0] === undefined
				> b.push("foo")
				> b[0] === "foo"
				.len() tells you where .push will insert and how many times .forEach will loop
				> $(b).len() === 1 && b.length == 10
			*/
		}

	}

})

Bling.module('Html', function () {
	/// HTML Module ///

	// these static DOM helpers are used inside some of the html methods
	// insert b before a
	function _before(a,b) { if( a && b ) a.parentNode.insertBefore(b, a) }
	// insert b after a
	function _after(a,b) { a.parentNode.insertBefore(b, a.nextSibling) }
	// convert nearly anything to something node-like for use in the DOM
	function toNode(x) {
		var ret = isNode(x) ? x
			: isBling(x) ? x.toFragment()
			: isString(x) ? Bling(x).toFragment()
			: isFunc(x.toString) ? Bling(x.toString()).toFragment()
			: undefined
		Bling.nextguid = Bling.nextguid || 1
		if( ret.guid == null ) ret.guid = Bling.nextguid++
		return ret
	}
	// a helper that will recursively clone a sub-tree of the DOM
	function deepClone(node) {
		var n = node.cloneNode()
		for(var i = 0; i < node.childNodes.length; i++) {
			var c = n.appendChild(deepClone(node.childNodes[i]))
			c.parentNode = n // just make sure
		}
		return n
	}
	// make a #text node, for escapeHTML
	var escaper = null
	// $.HTML.* provide an HTML converter similar to the global JSON object
	// methods: .parse(string), .stringify(node), and .escape(html)
	Bling.HTML = {
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
		},
		escape: function escape(h) {
			escaper = escaper || Bling("<div>&nbsp;</div>").child(0)
			// insert html using the text's .data property
			var ret = escaper.zap('data', h)
				// then get escaped html from the parent's .innerHTML
				.zip("parentNode.innerHTML").first()
			// clean up so escaped content isn't leaked into the DOM
			escaper.zap('data', '')
			return ret
		}
	}

	Bling.Color = {
		fromCss: function fromCss(css) {
			// .fromCss(css) - convert any css color strings to numbers
			css = css || this
			if( isString(css) ) {
				var d = document.createElement("div")
				d.style.display = 'none'
				d.style.color = css
				$(document.body).append(d)
				var rgb = window.getComputedStyle(d).getPropertyValue('color')
				$(d).remove()
				if( rgb ) {
					// grab between the parens
					rgb = rgb.slice(rgb.indexOf('(')+1, rgb.indexOf(')'))
						// make an array
						.split(", ")
					if( rgb.length == 3 ) rgb[3] = 1.0
					// return floats
					return Bling( rgb ).floats()
				}
			}
			/* Example:

				.fromCss("#ffffff")

				> == $([255, 255, 255, 1.0])

				$(nodes).css("color").map(Bling.Color.fromCss)

				> == $([$([255,255,255,1.0]), ...])
			*/
		},
		toCss: function toCss(b) {
			// .toCss(/b/) - convert a color array to a css string
			// $([255, 255, 255, 1.0]) -> "rgba(255, 255, 255, 1.0)"
			// $([$([255,255,255,1.0]),]) -> $(["rgba(255, 255, 255, 1.0)"])
			function f(t) {
				var r = t.map(Function.UpperLimit(255))
					.map(Function.LowerLimit(0))
				r[3] = Math.min(1, r[3])
				return "rgba(" + r.join(", ") + ")"
			}
			// accept either a Bling of Blings
			// or a single Bling of numbers
			b = b || this
			if( isBling(b[0]) ) {
				return b.map(f)
			} else {
				return f(b)
			}
		},
		invert: function invert(c) {
			var b = Bling(4)
			b[0] = 255 - c[0]
			b[1] = 255 - c[1]
			b[2] = 255 - c[2]
			b[3] = c[3]
			return b
		}
	}

	return {
		html: function html(h) {
			// .html([h]) - get [or set] /x/.innerHTML for each node
			return h == undefined ? this.zip('innerHTML')
				: isString(h) ? this.zap('innerHTML', h)
				: isBling(h) ? this.html(h.toFragment())
				: isNode(h) ? this.each(function _htmlnode() {
					// replace all our children with the new child
					this.replaceChild(this.childNodes[0], h)
					while( this.childNodes.length > 1 )
						this.removeChild(this.childNodes[1])
				})
				: undefined
		},

		append: function append(x) {
			// .append(/n/) - insert /n/ [or a clone] as the last child of each node
			if( x == null ) return this
			x = toNode(x) // parse, cast, do whatever it takes to get a Node or Fragment
			var a = this.zip('appendChild')
			a.take(1).call(x)
			a.skip(1).each(function _append() {
				this(deepClone(x))
			})
			return this
		},

		appendTo: function appendTo(x) {
			// .appendTo(/n/) - each node [or a fragment] will become the last child of n
			if( x == null ) return this
			Bling(x).append(this)
			return this
		},

		prepend: function prepend(x) {
			// .prepend(/n/) - insert n [or a clone] as the first child of each node
			if( x == null ) return this
			x = toNode(x)
			this.take(1).each(function _prepend1() { _before(this.childNodes[0], x) })
			this.skip(1).each(function _prepend2() { _before(this.childNodes[0], deepClone(x)) })
			return this
		},

		prependTo: function prependTo(x) {
			// .prependTo(/n/) - each node [or a fragment] will become the first child of n
			if( x == null ) return this
			Bling(x).prepend(this)
			return this
		},

		before: function before(x) {
			// .before(/n/) - insert content n before each node
			if( x == null ) return this
			x = toNode(x)
			this.take(1).each(function _before1() { _before(this, x) })
			this.skip(1).each(function _before2() { _before(this, deepClone(x)) })
			return this
		},

		after: function after(x) {
			// .after(/n/) - insert content n after each node
			if( x == null ) return this
			x = toNode(x)
			this.take(1).each(function _after1() { _after(this, x) })
			this.skip(1).each(function _after2() { _after(this, deepClone(x)) })
			return this
		},

		wrap: function wrap(parent) {
			// .wrap(/p/) - p becomes the new .parentNode of each node
			// all items of this will become children of parent
			// parent will take each child's position in the DOM
			parent = toNode(parent)
			if( isFragment(parent) )
				throw new Error("cannot wrap something with a fragment")
			return this.map(function _wrap(child) {
				if( isFragment(child) ) {
					parent.appendChild(child)
				} else if( isNode(child) ) {
					var p = child.parentNode
					if( ! p ) {
						parent.appendChild(child)
					} else {
						// swap out the DOM nodes using a placeholder element
						var marker = document.createElement("dummy")
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
			// .unwrap() - replace each node's parent with the node
			return this.each(function _unwrap() {
				if( this.parentNode && this.parentNode.parentNode )
					this.parentNode.parentNode
						.replaceChild(this, this.parentNode)
			})
		},

		replace: function replace(n) {
			// .replace(/n/) - replace each node with n [or a clone]
			n = toNode(n)
			var b = Bling(), j = -1
			// first node gets the real n
			this.take(1).each(function _replace1() {
				if( this.parentNode ) {
					this.parentNode.replaceChild(n, this)
					b[++j] = n
				}
			})
			// the rest get clones of n
			this.skip(1).each(function _replace2() {
				if( this.parentNode ) {
					var c = deepClone(n)
					this.parentNode.replaceChild(c, this)
					b[++j] = c
				}
			})
			// return the set of inserted nodes
			return b
		},

		attr: function attr(a,v) {
			// .attr(a, [v]) - get [or set] an /a/ttribute [/v/]alue
			var f = v ? "setAttribute" : "getAttribute"
			var ret = this.zip(f).call(a,v)
			return v ? this : ret
		},

		addClass: function addClass(x) {
			// .addClass(/x/) - add x to each node's .className
			// remove the node and then add it to avoid dups
			return this.removeClass(x).each(function _addclass() {
				var c = this.className.split(" ").filter(function(y){return y && y != ""})
				c.push(x) // since we dont know the len, its still faster to push, rather than insert at len()
				this.className = c.join(" ")
			})
		},

		removeClass: function removeClass(x) {
			// .removeClass(/x/) - remove class x from each node's .className
			var notx = function(y){ return y != x }
			return this.each(function _remclass() {
				this.className = this.className.split(" ").filter(notx).join(" ")
			})
		},

		toggleClass: function toggleClass(x) {
			// .toggleClass(/x/) - add, or remove if present, class x from each node
			function notx(y) { return y != x }
			return this.each(function _togclass(node) {
				var cls = node.className.split(" ")
				if( cls.indexOf(x) > -1 )
					node.className = cls.filter(notx).join(" ")
				else
					node.className = cls.push(x).join(" ")
			})
		},

		hasClass: function hasClass(x) {
			// .hasClass(/x/) - true/false for each node: whether .className contains x
			// note: different from jQuery, we always return sets when possible
			return this.zip('className.split').call(" ")
				.zip('indexOf').call(x)
				.map(Function.IndexFound)
		},

		text: function text(t) {
			// .text([t]) - get [or set] each node's .innerText
			return t ? this.zap('innerText', t)
				: this.zip('innerText')
		},

		val: function val(v) {
			// .val([v]) - get [or set] each node's .value
			return v ? this.zap('value', v)
				: this.zip('value')
		},

		css: function css(k,v) {
			// .css(k, [v]) - get/set css properties for each node
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
			return ov.weave(cv).fold(function _cssfold(x,y) { return x ? x : y })
		},

		rect: function rect() {
			// .rect() - collect a ClientRect for each node in this
			return this.zip('getBoundingClientRect').call()
		},
		width: function width(w) {
			// .width([w]) - get [or set] each node's width value
			return this.rect().zip('width')
		},
		height: function height(h) {
			// .height([h]) - get [or set] each node's height value
			return h == null ? this.rect().zip('height')
				: this.css('height', h)
		},
		top: function top(y) {
			// .top([y]) - get [or set] each node's top value
			return y == null ? this.rect().zip('top')
				: this.css('top', y)
		},
		left: function left(x) {
			// .left([x]) - get [or set] each node's left value
			return x == null ? this.rect().zip("left")
				: this.css("left", x)
		},
		position: function position(x, y) {
			// .position([x, [y]]) - get [or set] each node's top and left values
			return x == null ? this.rect() // with no args, return the entire current position
				: y == null ? this.css("left", Number.Px(x)) // with just x, just set left
				: this.css({"top": Number.Px(y), "left": Number.Px(x)}) // with both, set top and left
		},

		center: function center(mode) {
			// .center([mode]) - move the elements to the center of the screen
			// mode is "viewport" (default), "horizontal" or "vertical"
			mode = mode || "viewport"
			var vh = document.body.clientHeight/2,
				vw = document.body.clientWidth/2
			return this.each(function _center() {
				var t = Bling(this),
					h = t.height().floats().first(),
					w = t.width().floats().first(),
					x = (mode == "viewport" || mode == "horizontal"
						? document.body.scrollLeft + vw - (w/2)
						:  NaN)
					y = (mode == "viewport" || mode == "vertical"
						? document.body.scrollTop + vh - (h/2)
						: NaN)
				t.css({ position: "absolute",
					left: (isNumber(x) ? x+"px" : undefined),
					top:  (isNumber(y) ? y+"px" : undefined)
				})
			})
		},

		trueColor: function trueColor(prop, reducer) {
			// .trueColor() - compute the visible background-color for each node.
			// getComputedStyle won't tell us what the actual visible
			// color of an element is, if there is transparency involved
			// so we manually calculate the elements visible color
			// NOTE: does not handle elements that are absolutely positioned
			// outside of their parent
			// by default, compute the background color, but call with 'color'
			// to compute the foreground color
			prop = prop || "background-color"
			function reducer(a) {
				// combine two rgba color arrays
				a[0] += (this[0] - a[0]) * this[3]
				a[1] += (this[1] - a[1]) * this[3]
				a[2] += (this[2] - a[2]) * this[3]
				a[3] = Math.min(1, a[3] + this[3])
				return a
			}
			// collect the full ancestry
			return this
				.parents()
				.map(function _truecolor() {
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
						.map(Bling.Color.fromCss)
						// reverse the order so we add colors from back to fore
						.reverse()
						// then collapse each list of [r,g,b,a]
						.reduce(reducer, Bling([0,0,0,0]))
						// and output a css string
						.map(Bling.Color.toCss)
				})
		},

		child: function child(n) {
			// .child(/n/) - returns the nth childNode for all items in this
			return this.map(function _child() { return this.childNodes[n] })
		},

		children: function children() {
			// .children() - returns all children of each node
			return this.map(function _children() {
				return Bling(this.childNodes, this)
			})
		},

		parent: function parent() {
			// .parent() - collects the parentNode of each item in this
			return this.zip('parentNode')
		},

		parents: function parents() {
			// .parents() - collects the full ancestry up to the owner
			return this.map(function _parents() {
				var b = Bling(), j = -1,
					p = this
				while( p = p.parentNode )
					b[++j] = p
				return b
			})
		},

		prev: function prev() {
			// .prev() - collects the full chain of .previousSibling nodes
			return this.map(function _prev() {
				var b = Bling(), j = -1,
					p = this
				while( p = p.previousSibling )
					b[++j] = p
				return b
			})
		},

		next: function next() {
			// .next() - collects the full chain of .nextSibling nodes
			return this.map(function _next() {
				var b = Bling(), j = -1,
					p = this
				while( p = p.previousSibling )
					b[++j] = p
				return b
			})
		},

		remove: function remove() {
			// .remove() - removes each node from the DOM
			return this.each(function _remove(){
				if( this.parentNode ) {
					this.parentNode.removeChild(this)
				}
			})
		},

		find: function find(expr) {
			// .find(expr) - collects nodes matching expr, using each node in this as context
			return this.filter("*") // limit to only nodes
				.map(function _find() { return Bling(expr, this) })
				.flatten()
		},

		clone: function clone() {
			// .clone() - deep copies a set of DOM nodes
			// note: does not copy event handlers
			return this.map(deepClone)
		},

		toFragment: function toFragment() {
			// .toFragment() - converts a bling of convertible stuff to a Node or DocumentFragment.
			// FOR ADVANCED USERS.
			// (nodes, strings, fragments, blings) into a single Node if well-formed,
			// or a DocumentFragment if not.
			// note: DocumentFragments are a sub-class of Node.
			//   isNode(fragment) == true
			//   fragment.nodeType == 11
			// This means you can node.appendChild() them directly, like DOM nodes.
			// But, unlike regular DOM nodes, if you insert a fragment, it disappears
			// and it's children are all inserted, and the fragment will be empty.
			// In the other direction, if you insert nodes into a fragment,
			// they are DETACHED from the DOM, and attached to the fragment.
			// So be sure to re-attach them, or save a reference, or you will lose them.
			// explanation:
			//   $("input").length === 2
			//   $("input").toFragment().childNodes.length === 2
			//   $("input").length === 0 // !?
			// Where did the inputs go?!
			// The first search finds 2 nodes.
			// The second searchs finds 2 nodes and DETACHES them.
			// Both inputs nodes now have .parentNode == the fragment.
			// The third search is searching the document object,
			// to which the inputs are no longer attached, and it finds 0.
			// They are attached to the fragment, whose reference we discarded.
			if( this.length == 1 )
				return toNode(this[0])
			var f = document.createDocumentFragment()
			this.map(toNode).map(f.appendChild.bound(f))
			return f
		}
	}

})

Bling.module('Math', function () {
	/// Math Module ///
	return {
		floats: function floats() {
			// .floats() - parseFloat(/x/) for /x/ in _this_
			return this.map(function _floats() {
				if( isBling(this) ) return this.floats()
				return parseFloat(this)
			})
		},

		ints: function ints() {
			// .ints() - parseInt(/x/) for /x/ in _this_
			return this.map(function _ints() {
				if( isBling(this) ) return this.ints()
				return parseInt(this)
			})
		},

		px: function px(delta) {
			// .px([delta]) - collect "NNpx" strings
			delta = delta || 0
			return this.ints().map(Function.Px(delta))
		},

		min: function min() {
			// .min() - select the smallest /x/ in _this_
			return this.reduce(function _min(a) {
				if( isBling(this) ) return this.min()
				return Math.min(this,a)
			})
		},

		max: function max() {
			// .max() - select the largest /x/ in _this_
			return this.reduce(function _max(a) {
				if( isBling(this) ) return this.max()
				return Math.max(this,a)
			})
		},

		average: function average() {
			// .average() - compute the average of all /x/ in _this_
			return this.sum() / this.length
		},

		sum: function sum() {
			// .sum() - add all /x/ in _this_
			return this.reduce(function _sum(a) {
				if( isBling(this) ) return a + this.sum()
				return a + this
			})
		},

		squares: function squares()  {
			// .squares() - collect /x/*/x/ for each /x/ in _this_
			return this.map(function _squares() {
				if( isBling(this) ) return this.squares();
				return this * this
			})
		},

		magnitude: function magnitude() {
			// .magnitude() - compute the vector length of _this_
			var n = this.map(function _magn() {
				if( isBling(this) ) return this.magnitude();
				return parseFloat(this);
			})
			return Math.sqrt(n.squares().sum())
		},

		scale: function scale(r) {
			// .scale(/r/) - /x/ *= /r/ for /x/ in _this_
			return this.map(function _scale() {
				if( isBling(this) ) return this.scale(r);
				return r * this
			})
		},

		normalize: function normalize() {
			// .normalize() - scale _this_ so that .magnitude() == 1
			return this.scale(1/this.magnitude())
		}
	}

})

Bling.module('Event', function () {
	/// Events Module: provides for binding and triggering DOM events ///

	function binder(e) {
		// .event([f]) - trigger [or bind] event
		return function bindortrigger(f) {
			return isFunc(f) ? this.bind(e, f) : this.trigger(e, f ? f : {})
		}
	}

	Bling.ready = function ready(f) {
		return Bling(document).ready(f)
	}

	// detect and fire the document.ready event
	setTimeout(function _detectready() {
		if( Bling.prototype.trigger != null
			&& document.readyState == "complete") {
			Bling(document).trigger('ready')
		} else {
			setTimeout(arguments.callee, 10)
		}
	}, 0)

	var comma_sep = /, */

	return {

		bind: function bind(e, f) {
			// .bind(e, f) - adds handler f for event type e
			// e is a string like 'click', 'mouseover', etc.
			// e can be comma-separated to bind multiple events at once
			var i = 0,
				e = (e||"").split(comma_sep),
				n = e.length
			return this.each(function _bind() {
				for(; i < n; i++) {
					this.addEventListener(e[i], f)
				}
			})
		},

		unbind: function unbind(e, f) {
			// .unbind(e, [f]) - removes handler f from event e
			// if f is not present, removes all handlers from e
			var i = 0,
				e = (e||"").split(comma_sep),
				n = e.length
			return this.each(function _unbind() {
				for(; i < n; i++) {
					this.removeEventListener(e[i],f)
				}
			})
		},

		once: function once(e, f) {
			// .once(e, f) - adds a handler f that will be called only once
			var i = 0,
				e = (e||"").split(comma_sep),
				n = e.length
			for(; i < n; i++) {
				this.bind(e[i], function _once(evt) {
					f.call(this, evt)
					this.unbind(evt.type, arguments.callee)
				})
			}
		},
		cycle: function cycle(e) {
			// .cycle(e, ...) - bind handlers for e that trigger in a cycle
			// one call per trigger. when the last handler is executed
			// the next trigger will call the first handler again
			var j = 0,
				funcs = Array.Slice(arguments, 1, arguments.length),
				e = (e||"").split(comma_sep),
				ne = e.length,
				nf = funcs.length
			function cycler() {
				var i = 0
				return function _c(evt) {
					funcs[i].call(this, evt)
					i = ++i % nf
				}
			}
			while( j < ne )
				this.bind(e[j++], cycler())
			return this
		},

		trigger: function trigger(evt, args) {
			// .trigger(e, a) - initiates a fake event
			// evt is the type, 'click'
			// args is an optional mapping of properties to set,
			//   {screenX: 10, screenY: 10}
			// note: not all browsers support manually creating all event types
			var e = undefined, i = 0,
				evt = (evt||"").split(comma_sep),
				n = evt.length,
				evt_i = null
			args = Bling.extend({
				bubbles: true,
				cancelable: true
			}, args)

			for(; i < n; i++) {
				evt_i = evt[i]
				switch(evt_i) {
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
						e.initMouseEvent(evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
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
						e.initUIEvent(evt_i, args.bubbles, args.cancelable, window, 1)
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
						e.initTouchEvent(evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
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
						e.initGestureEvent(evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY,
							args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey,
							args.target, args.scale, args.rotation);
						break;

					// iphone events that are not supported yet
					// (dont know how to create yet, needs research)
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
						e.initEvent(evt_i, args.bubbles, args.cancelable);
				}
				if( !e ) continue
				else this.each(function _trigger() {
					this.dispatchEvent(e)
					e.result = e.returnValue = undefined // clean up
				})
			}

			return this;

		},

		live: function live(e, f) {
			// .live(e, f) - handle events for nodes that will exist in the future
			var selector = this.selector,
				context = this.context
			// wrap f
			function _handler(evt) {
				// when the 'live' event is fired
				// re-execute the selector in the original context
				Bling(selector, context)
					// then see if the event would bubble into a match
					.intersect(Bling(evt.target).parents().first())
					// then fire the real handler on the matched nodes
					.each(function _fire() {
						evt.target = this;
						f.call(this, evt)
					})
			}
			// bind the handler to the context
			Bling(context).bind(e, _handler)
			// record f so we can 'die' it if needed
			var livers = (context.__livers__ = context.__livers__ || {})
			livers[selector] = livers[selector] || {}
			livers[selector][e] = livers[selector][e] || []
			livers[selector][e].push(f)
		},

		die: function die(e, f) {
			// die(e, [f]) - stop f [or all] from living for event e
			var selector = this.selector,
				context = this.context,
				c = Bling(context)
				livers = context.__livers__
			// if no event handlers have been 'live'd on this context
			if( livers == null ) return this;

			var livers = context.__livers__[selector][e],
				i = 0,
				nn = livers.length;
			// find f in the living handlers
			for(; i < nn; i++) {
				if( f == undefined || f == livers[i] ) {
					// unbind f
					c.unbind(e, f)
					// remove f
					livers.splice(i, 1)
					nn--; // adjust the iteration
					i--;
				}
			}
		},
		liveCycle: function liveCycle(e) {
			// .liveCycle(e, ...) - bind each /f/ in /.../ to /e/
			// one call per trigger. when the last handler is executed
			// the next trigger will call the first handler again
			var i = 0,
				funcs = Array.Slice(arguments, 1, arguments.length)
			return this.live(e, function _live(evt) {
				funcs[i].call(this, evt)
				i = ++i % funcs.length
			})
		},

		// short-cuts for calling bind or trigger
		click: function click(f) {
			// .click(e, [f]) - trigger [or bind] event e
			// if the cursor is just default then make it look clickable
			if( this.css("cursor").intersect(["auto",""]).len() > 0 )
				this.css("cursor", "pointer")
			return isFunc(f) ? this.bind('click', f)
				: this.trigger('click', f ? f : {})
		},
		mousemove: binder('mousemove'),
		mousedown: binder('mousedown'),
		mouseup: binder('mouseup'),
		mouseover: binder('mouseover'),
		mouseout: binder('mouseout'),
		blur: binder('blur'),
		focus: binder('focus'),
		load: binder('load'),
		// ready is generated by this library
		ready: binder('ready'),
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
	}

})

Bling.module('Transform', function () {
	Bling.duration = function duration(speed) {
		// given a speed description, return milliseconds
		var speeds = {
			"slow": 700.0,
			"medium": 500.0,
			"normal": 300.0,
			"fast": 100.0,
			"instant": 0.0,
			"now": 0.0
		}
		var s = speeds[speed]
		var ret = s ? s : parseFloat(speed);
		return ret;
	}
	/// Transformation Module: provides wrapper for using -webkit-transform ///
	return {
		// like jquery's animate(), but using only webkit-transition/transform
		transform: function transform(end_css, speed, callback) {
			// .transform(css, [speed], [callback]) - animate css properties on each node
			// animate css properties over a duration
			// accelerated: scale, translate, rotate, scale3d,
			// ... translateX, translateY, translateZ, translate3d,
			// ... rotateX, rotateY, rotateZ, rotate3d
			if( typeof(speed) == "function" ) {
				callback = speed
				speed = undefined
			}
			speed = speed || "normal"
			var duration = Bling.duration(speed);
			// collect the list of properties to be modified
			var props = [], j = 0
			// what to send to the -webkit-transform
			var trans = ""
			// real css values to be set (end_css without the transform values)
			var css = {}
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
				props[j++] = i
			// and include -webkit-transform if we have transform values to set
			if( trans )
				props[j++] = "-webkit-transfrom"
			// set which properties to apply a duration to
			this.css('-webkit-transition-property', props.join(', '))
			// repeat the same duration for each property
			this.css('-webkit-transition-duration',
				props.map(function _pmap() { return duration + "ms" }).join(', '))
			// apply the real css
			for( var i in css )
				this.css(i, css[i])
			// apply the transformation
			if( trans )
				this.css('-webkit-transform', trans)
			// queue the callback to be executed at the end of the animation
			// NOT EXACT!
			return this.future(duration, callback)
		},

		hide: function hide(callback) {
			// .hide() - each node gets display:none
			return this.each(function _hide() {
				if( this.style ) {
					this._display = this.style.display == "none" ? undefined : this.style.display;
					this.style.display = 'none';
				}
			}).future(50, callback)
		},

		show: function show(callback) {
			// .show() - show each node
			return this.each(function _show() {
				if( this.style ) {
					this.style.display = this._display ? this._display : "block";
					this._display = undefined;
				}
			}).future(50, callback)
		},

		toggle: function toggle(callback) {
			// .toggle() - show each hidden node, hide each visible one
			this.weave(this.css("display"))
				.fold(function _toggle(display, node) {
					if( display == "none" ) {
						node.style.display = node._old_display ? node._old_display : "block"
						node._old_display = undefined
					} else {
						node._old_display = display
						node.style.display = "none"
					}
					return node
				})
				.future(50, callback)
		},

		fadeIn: function fadeIn(speed, callback) {
			// .fadeIn() - fade each node to opacity:1.0
			return this
				.css('opacity','0.0')
				.show(function _fadein(){
					this.transform({opacity:"1.0", translate3d:[0,0,0]}, speed, callback)
				})
		},
		fadeOut:   function fadeOut(speed, callback, _x, _y) {
			// .fadeOut() - fade each node to opacity:0.0
			_x = _x || 0.0
			_y = _y || 0.0
			return this.each(function _fadeout(t) {
				Bling(t).transform({
					opacity:"0.0",
					translate3d:[_x,_y,0.0]
				}, speed, function _afterfade() { this.hide() })
			}).future(Bling.duration(speed), callback)
		},
		fadeLeft:  function fadeLeft(speed, callback)  {
			// .fadeLeft() - fadeOut and move offscreen to the left
			return this.fadeOut(speed, callback, "-"+this.width().first(), 0.0)
		},
		fadeRight: function fadeRight(speed, callback) {
			// .fadeRight() - fadeOut and move offscreen to the right
			return this.fadeOut(speed, callback, this.width().first(), 0.0)
		},
		fadeUp:    function fadeUp(speed, callback)    {
			// .fadeUp() - fadeOut and move offscreen off the top
			return this.fadeOut(speed, callback, 0.0, "-"+this.height().first())
		},
		fadeDown:  function fadeDown(speed, callback)  {
			// .fadeDown() - fadeOut and move offscreen off the bottom
			return this.fadeOut(speed, callback, 0.0, this.height().first())
		}
	}

})

Bling.module('Http', function() {
	/// HTTP Request Module: provides wrappers for making http requests ///

	// static helper to create &foo=bar strings from object properties
	function formencode(obj) {
		var s = [], j = 0, o = JSON.parse(JSON.stringify(obj)) // quickly remove all non-stringable items
		for( var i in o )
			s[j++] = i + "=" + escape(o[i])
		return s.join("&")
	}

	// install only globals
	Bling.extend(Bling, {
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
					else
						opts.error(xhr.status, xhr.statusText)
			}
			xhr.send(opts.data)
			return Bling([xhr])
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

	return {} // no operator methods

})

Bling.module('Database', function () {
	/// Database Module: provides access to the sqlite database ///

	// static error handler
	function SqlError(t, e) { throw new Error("sql error ["+e.code+"] "+e.message) }

	Bling.db = function db(fileName, version, displayName, maxSize) {
		// .db(fn, ver, name, size) - get a new connection to the local database
		return Bling([window.openDatabase(
			fileName || "bling.db",
			version || "1.0",
			displayName || "bling database",
			maxSize || 1024)
		])
	}

	return {
		transaction: function transaction( f ) {
			// .transaction() - provides access to the db's raw transaction() method
			// but, use .sql() instead, its friendlier
			this.zip('transaction').call(f)
			return this
		},

		sql: function sql(sql, values, callback, errors) {
			// .sql(sql, values, callback, errors) - shortcut for using transaction
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
			return this.transaction(function _trans(t) {
				t.executeSql(sql, values, callback, errors)
			})
		}
	}

})

Bling.module('Template', function() {

	function match_forward(text, find, against, start, stop) {
		var count = 1;
		if( stop == null || stop == -1 ) {
			stop = text.length;
		}
		for( var i = start; i < stop; i++ ) {
			if( text.charAt(i) == against )
				count += 1
			else if( text.charAt(i) == find )
				count -= 1
			if( count == 0 )
				return i
		}
		return -1
	}

	var type_re = /([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])(.*)/

	function compile(text) {
		var ret = [],
			chunks = text.split(/%[\(\/]/),
			end = -1, i = 1, n = chunks.length
		ret.push(chunks[0])
		for( ; i < n; i++) {
			end = match_forward(chunks[i], ')', '(', 0, -1)
			if( end == -1 )
				return "Template syntax error: unmatched '%(' in chunk starting at: "+chunks[i].substring(0,15)
			key = chunks[i].substring(0,end)
			rest = chunks[i].substring(end)
			match = type_re.exec(rest)
			if( match == null )
				return "Template syntax error: invalid type specifier starting at '"+rest+"'"
			rest = match[4]
			ret.push(key)
			// the |0 operation coerces to a number, anything that doesnt map becomes 0, so "3" -> 3, "" -> 0, null -> 0, etc.
			ret.push(match[1]|0)
			ret.push(match[2]|0)
			ret.push(match[3])
			ret.push(rest)
		}
		return ret
	}

	function render(text, values) {
		// get the cached compiled version
		var cache = arguments.callee.cache[text]
			|| (arguments.callee.cache[text] = compile(text)),
			// the first block is always just text
			output = [cache[0]],
			// j is an insert marker into output
			j = 1 // (because .push() is slow on an iphone, but inserting at length is fast everywhere)
			// (and because building up this list is the bulk of what render does)

		// then the rest of the cache items are: [key, precision, fixed, type, remainder] 5-lets
		for( var i = 1, n = cache.length; i < n-4; i += 5) {
			var key = cache[i],
				// the format in three pieces
				// (\d).\d\w
				pad = cache[i+1],
				// \d.(\d)\w
				fixed = cache[i+2],
				// \d.\d(\w)
				type = cache[i+3],
				// the text after the end of the format
				rest = cache[i+4],
				// the value to render for this key
				value = values[key]

			// require the value
			if( value == null )
				value = "missing required value: "+key

			// TODO: the format is used for all kinds of options like padding, etc
			// right now this only really supports %s, %d, and %N.Nf
			// everything else is equivalent to %s
			switch( type ) {
				case 'd':
					output[j++] = "" + parseInt(value)
					break
				case 'f':
					output[j++] = parseFloat(value).toFixed(fixed)
					break
				// output unsupported formats as strings
				// TODO: add support for more types
				case 's':
				default:
					output[j++] = "" + value
			}
			if( pad > 0 )
				output[j] = String.PadLeft(output[j], pad)
			output[j++] = rest
		}
		return output.join('')
	}
	render.cache = {}


	return {
		template: function template(defaults) {
			// .template([defaults]) - compile a template from each node, call .render(v) to use
			// if defaults is passed, these will be the default values for v in .render(v)
			defaults = Bling.extend({
			}, defaults)
			this.render = function _render(args) {
				return render(this.html().first(), Bling.extend(defaults,args))
			}
			return this.hide()
		}
	}

})

/* The Bling! Operator
 * -------------------
 * Bound to $ by default, this is the handy constructor of Bling objects.
 * It also holds references to the global Bling functions:
 * $.extend === Bling.extend
 * $("body")[0] === Bling("body")[0]
 * isBling($) == false
 * isBling($()) == true
 * isFunc($) == true
 */
$ = Bling
Bling.symbol = "$" // for display purposes


