/* bling.js
 * --------
 * Named after the bling operator ($) to which it is bound by default.
 * This is a jQuery-like framework, using any WebKit shortcuts that we can.
 * All other browsers play at your own risk.
 * Blame: Jesse Dailey <jesse.dailey@gmail.com>
 */


/** Bling, the constructor.
 * -----------------------
 * Bling(expression, context):
 * @param {(string|number|Array|NodeList|Node|Window)=} selector
 *   accepts strings, as css expression to select, ("body div + p", etc.)
 *     or as html to create (must start with "<")
 *   accepts existing Bling
 *   accepts arrays of anything
 *   accepts a single number, used as the argument in new Array(n), to pre-allocate space
 * @param {Object=} context the item to consider the root of the search when using a css expression
 *
 */
function Bling (selector, context) {
	if( isBling(selector) )
		return selector
	context = context || document
	var set = null // the set of things to wrap

	if( selector == null)
		set = []
	else if( typeof(selector) === "number" )
		set = new Array(selector)
	else if( selector === window || isNode(selector) )
		set = [selector]
	else if( typeof selector === "string" ) { // strings, search css or parse html
		// accept two different kinds of strings: html, and css expression
		// html begins with "<", and we create a set of nodes by parsing it
		// any other string is considered css

		selector = selector.trimLeft()

		if( selector[0] === "<" )
			set = [Bling.HTML.parse(selector)]
		else if( isBling(context) )
			// search every item in the context
			set = context.reduce(function(a, x) {
				var s = x.querySelectorAll(selector),
					i = 0, n = s.length
				for(; i < n; i++)
					a.push(s[i])
				return a
			}, [])
		else if( context.querySelectorAll )
			try {
				set = context.querySelectorAll(selector)
			} catch ( err ) {
				throw Error("invalid selector: " + selector, err)
			}
		else throw Error("invalid context: " + context)
	}
	else
		set = selector

	// parasitic type replacement
	set.__proto__ = Bling.prototype
	set.selector = selector
	set.context = context

	return set
}
// finish defining the Bling type
Bling.prototype = new Array // a copy(!) of the Array prototype, Blings extend the ordered sets
Bling.prototype.constructor = Bling
function isBling(a)  { return isType(a, Bling) }
Bling.symbol = "$" // for display purposes
window[Bling.symbol] = Bling // for use in code as $

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
		: typeof(T) === "string" ? a.__proto__.constructor.name === T
		: a.__proto__.constructor === T
}
function isSubtype(a, T) {
	// isSubtype(a,T) - true if object a is of type T (directly or indirectly)
	return a == null ? a === T
		: a.__proto__ == null ? false
		: typeof(T) === "string" ? a.__proto__.constructor.name == T
		: a.__proto__.constructor === T ? true
		: isSubtype(a.__proto__, T) // recursive
}
function isString(a) {
	// isString(a) - true if object a is a string
	return typeof(a) === "string" || isSubtype(a, String)
}
// isNumber(a) - true if object a is a number
var isNumber = isFinite
function isFunc(a) {
	// isFunc(a) - true if object a is a function
	return typeof(a) === "function" || isType(a, Function)
}
function isNode(a) {
	// isNode(a) - true if object is a DOM node
	return a ? a.nodeType > 0 : false
}
function isFragment(a) {
	// isFragment(a) - true if object is a DocumentFragment node
	return a ? a.nodeType === 11 : false
}
function isArray(a) {
	// isArray(a) - true if object is an Array (or inherits Array)
	return a ? Function.ToString(a) === "[object Array]"
		|| isSubtype(a, Array) : false
}
function isObject(a) {
	// isObject(a) - true if a is an object
	return typeof(a) === "object"
}
function hasValue(a) {
	// hasValue(a) - true if a is not null nor undefined
	return !(a == null)
}

/** Object.Extend
 * @param {Object} a the object to copy into
 * @param {Object} b the object to copy from
 * @param {Array=} k if present, a list of field names to limit to
 */
Object.Extend = function extend(a, b, k) {
	// .extend(a, b, [k]) - merge values from b into a
	// if k is present, it should be a list of property names to copy
	var i, j, undefined
	if( isArray(k) )
		for( i in k )
			a[k[i]] = b[k[i]] != undefined ? b[k[i]] : a[k[i]]
	else 
		for( i in (k = Object.Keys(b)) )
			a[k[i]] = b[k[i]]
	return a
}

Object.Keys = function(o, inherited) {
	var keys = [], j = 0, i = null
	for( i in o )
		if( inherited || o.hasOwnProperty(i) )
			keys[j++] = i
	return keys
}

/** boundmethod - function decorator to preset the context and/or arguments
 * @param {Function} f the function to bind
 * @param {Object} t the context to bind f to
 * @param {Array=} args (optional) bind the arguments now as well
 */
function boundmethod (f, t, args) {
	// boundmethod(/f/, /t/) - whenever /f/ is called, _this_ === /t/
	function r() { return f.apply(t, args ? args: arguments) }
	r.toString = function() { return "bound-method of "+t+"."+f.name+"(...) { [code] }" }
	return r
	/* Example:
		> var stars = ["Ricky","Martin"]
		> var num_stars = function () { return this.length }
		>   .bound(stars)
		> num_stars() == 2

		Where it can be most useful is extracting member functions from an instance
		so you can call them without access to the member itself.

		Here, we extract the Array.prototype.join function,
		bind it to an array, then call it without any context, and you can see
		that it uses the context that was given to .bound()

		> var join_stars = stars.join.bound(stars)
		> join_stars(", ") == "Ricky, Martin"

		You can also bind the arguments ahead of time if you know them:

		> join_stars = stars.join.bound(stars, [", "])
		> join_stars() == "Ricky, Martin"

		Once a function is bound, it cannot be re-bound, called, or applied,
		in any other context than the one it was first bound to.

		> more_stars = ["Janet", "Micheal", "Latoya"]
		> join_stars.apply(more_stars, ", ")
		> == "Ricky, Martin"

		NOTE that join_stars is still operating on 'stars', not 'more_stars'.

		Even if we explicitly bind to an object, like so:

		> more_stars.num_stars = num_stars
		> more_stars.num_stars() == 2
		> num_stars.call(more_stars) == 2
		> num_stars.apply(more_stars, []) == 2

		Why 2?  Because num_stars will always act on its original binding ('stars'), not the
		newer binding to more_stars.

		Another very useful example:

		> var log = window.console ? console.log.boung(console) : Function.Empty
		> log("hello", "world")
	*/
}

/** tracemethod - function decorator console.logs a message to record each call
 * @param {Function} f the function to trace
 * @param {string=} label (optional)
 */
function tracemethod(f, label) {
	function r() {
		console.log(label ? label : f.name, Array.Slice(arguments, 0))
		return f.apply(this, arguments)
	}
	r.toString = function() { return f.toString() }
	console.log("tracemethod:", label ? label : f.name,"created")
	return r
	/* Example:
		> function someFunction() { }
		> someFunction = tracemethod(someFunction)
	*/
}

// static functions we will use more than once later
Object.Extend(Function, {
	Empty: function (){},
	NotNull: function (x) { return x != null },
	IndexFound: function (x) { return x > -1 },
	ReduceAnd: function (x) { return x && this },
	UpperLimit: function (x) { return function(y) { return Math.min(x, y) }},
	LowerLimit: function (x) { return function(y) { return Math.max(x, y) }},
	ToString: function (x) { return Object.prototype.toString.apply(x) },
	Px: function (d) { return function() { return Number.Px(this,d) } }
})
var console = console || {}
console.log = console.log || Function.Empty

/** Array.Slice works like python's slice (negative indexes, etc)
 * and works on any indexable (not just array instances, notably 'arguments')
 * @param {Object} o the iterable to get a slice of
 * @param {number} i the start index
 * @param {number=} j the end index
 */
Array.Slice = function (o, i, j) {
	var a = [], k = 0, n = o.length,
		end = j == null ? n
			: j < 0 ? n + j
			: j,
		start = i == null ? 0
			: i < 0 ? n + i
			: i
	while( start < end )
		a[k++] = o[start++]
	return a
}

// return a number with "px" attached, suitable for css
/** Number.Px
 * @param {(number|string)} x a number-ish
 * @param {number=} d delta for adjusting the number before output
 */
Number.Px = function (x,d) { return (parseInt(x,10)+(d|0))+"px" }

// add string functions
Object.Extend(String, {
	PadLeft: function pad(s, n, c) {
		// String.PadLeft(string, width, fill=" ")
		c = c || " "
		while( s.length < n )
			s = c + s
		return s
	},
	PadRight: function padr(s, n, c) {
		// String.PadRight(string, width, fill=" ")
		c = c || " "
		while( s.length < n )
			s = s + c
		return s
	},
	Splice: function splice() {
		// String.Splice(start, length, ...) - replace a substring with ...
		var s = arguments[0], a = arguments[1], b = arguments[2],
			repl = Array.Slice(arguments, 3).join('')
		return s.substring(0,a) + repl + s.substring(b)
	}
})


/** Plugin adds a new plugin to the library.
 * @param {Function} constructor the closure to execute to get a copy of the plugin
 */
Bling.plugin = function (constructor) {
	var plugin = constructor.call(Bling, Bling),
		keys = Object.Keys(plugin, true),
		i, key
	var plugins = (arguments.callee.s = arguments.callee.s || [])
	for( i in keys ) {
		key = keys[i]
		if( key.charAt(0) === '$' )
			Bling[key.substr(1)] = plugin[key]
		else
			Bling.prototype[key] = plugin[key]
	}
	plugins.push(constructor.name)
	plugins[constructor.name] = plugin
}

// move into a safer namespace
// so we can use shorthand in making our initial plugins
;(function ($) {


	$.plugin(function Core() {
		// Core - the functional basis for all other modules

		/** @constructor */
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
			this.next = boundmethod(function() {
				// consume all 'due' handlers
				if( this.queue.length > 0 )
					// shift AND call
					this.queue.shift()()
			}, this)
			// schedule(f, n) sets f to run after n or more milliseconds
			this.schedule = function schedule(f, n) {
				if( !isFunc(f) ) return
				var nn = this.queue.length
				// get the absolute scheduled time
				f.order = n + new Date().getTime()
				// shortcut some special cases: empty queue, or f.order greater than the last item
				if( nn === 0 || f.order > this.queue[nn-1].order ) {
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

		// used in .zip()
		function _getter(p) {
			var v
			return function() {
				v = this[p]
				return isFunc(v) ? boundmethod(v, this) : v
			}
		}
		// used in .zip()
		function _zipper(p) {
			var i = p.indexOf(".")
			// split and recurse ?
			return i > -1 ? this.zip(p.substr(0, i)).zip(p.substr(i+1))
				// or map a getter across the values
				: this.map(_getter(p))
		}

		return {

			each: function each(f) {
				// .each(/f/) - apply function /f/ to every item /x/ in _this_.
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
				// .map(/f/) - collect /f/.call(/x/, /x/) for every item /x/ in _this_.
				var n = this.len(),
					a = $(n),
					i = 0, t = null,
					can_call = true
				a.context = this
				a.selector = f
				for(; i < n; i++ ) {
					t = this[i]
					if( can_call ) {
						try { a[i] = f.call(t, t) }
						catch( e ) {
							if( isType(e, TypeError) ) {
								can_call = false
								i-- // redo this iteration
							}
							else a[i] = e
						}
					} else try {
						a[i] = f(t)
					} catch( e ) {
						a[i] = e
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
				// .reduce(/f/, [/init/]) - accumulate a = /f/(a, /x/) for /x/ in _this_.
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
				t.each(function() {
					a = f.call(this, a, this)
				})
				return a
				/* Example:

					Here, reduce is used to mimic sum.

					> $([12, 14, 9, 37])
					>		.reduce(function(a, x) {
					>			return a + x
					>		})
					> == 72

					But, you can accumulate anything easily, given an initial value.  Here, an initially empty object is used to mimic distinct.

					> Object.Keys( $(["a", "a", "b"])
					>		.reduce(function(a, x) {
					>			a[x] = 1
					>		}, { }) )
					> == ["a", "b"]

					You can use any function that takes 2 arguments, including several useful built-ins.

					> $([12, 13, 9, 22]).reduce(Math.min)
					> == 9

					This is something you can't do with the native Array reduce.

				*/
			},

			union: function union(other) {
				// .union(/other/) - collect all /x/ from _this_ and /y/ from _other_.
				// no duplicates, use concat if you want to preserve dupes
				var ret = $(),
					i = 0, j = 0, x = null
				ret.context = this.context
				ret.selector = this.selector
				this.each(function() {
					ret[i++] = this
				})
				while(x = other[j++]) {
					if( ! ret.contains(x) ) {
						ret[i++] = x
					}
				}
				return ret
				/* Example:
					> $([1, 2, 3]).union([3, 4, 5])
					> == $([1, 2, 3, 4, 5])
				*/
			},

			intersect: function intersect(other) {
				// .intersect(/other/) - collect all /x/ that are in _this_ and _other_.
				var ret = $(),
					i = 0, j = 0, x = null,
					n = this.length, nn = other.length
				ret.context = this.context
				ret.selector = this.selector
				for(; i < n; i++)
					for(j = 0; j < nn; j++)
						if( this[i] === other[j] ) {
							ret[ret.length] = this[i]
							break
						}

				return ret
				/* Example:
					> $([1, 2, 3]).intersect([3, 4, 5])
					> == $([3])
				*/
			},

			distinct: function distinct() {
				// .distinct() - return a copy of _this_ without duplicates.
				return this.union(this)
				/* Example:
					> $([1, 2, 1, 3]).distinct()
					> == $([1,2,3])
				*/
			},

			contains: function contains(item) {
				// .contains(/x/) - true if /x/ is in _this_, false otherwise.
				return this.count(item) > 0
				/* Example:
					> $("body").contains(document.body)
					> == true
				*/
			},

			count: function count(item, strict) {
				// .count(/x/) - returns the number of times /x/ occurs in _this_.
				var undefined // an extra careful check here
				// since we want to be able to search for null values,
				// but if you just call .count(), it returns the total
				if( item === undefined ) 
					return this.len()
				var ret = 0
				this.each(function(t) {
					if( (strict && t === item)
						|| (!strict && t == item)) 
						ret++
				})
				return ret
				/* Example:
					> $("body").count(document.body)
					> == 1
				*/
			},

			zip: function zip() {
				// .zip([/p/, ...]) - collects /x/./p/ for all /x/ in _this_.
				// recursively split names like "foo.bar"
				// zip("foo.bar") == zip("foo").zip("bar")
				// you can pass multiple properties, e.g.
				// zip("foo", "bar") == [ {foo: x.foo, bar: x.bar}, ... ]
				switch( arguments.length ) {
					case 0:
						return this
					case 1:
						return _zipper.call(this, arguments[0])
					default: // > 1
						// if more than one argument is passed, new objects
						// with only those properties, will be returned
						// like a "select" query in SQL
						var master = {},
							b = $(), n = arguments.length, nn = this.length,
							i = 0, j = 0, k = null
						// first collect a set of lists
						for(i = 0; i < n; i++) {
							master[i] = _zipper.call(this, arguments[i])
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
					> $(["foo","bar","bank"]).zip("length")
					> == $([3, 3, 4])

					You can use compound property names.

					> $("pre").first(3).zip("style.display")
					> == $(["block", "block", "block"])

					If you request many properties at once,
					you get back raw objects with only those properties.
					Similar to specifying columns on a SQL select query.

					> $("pre").first(1)
					>		.zip("style.display", "style.color")
					> == $([{'display':'block','color':'black'}])

					If the property value is a function,
					a bound-method is returned in its place.

					> $("pre").first(1)
					>		.zip("getAttribute")
					> == $(["bound-method getAttribute of HTMLPreElement"])

					See: .call() for how to use a set of methods quickly.

				*/
			},

			zap: function zap(p, v) {
				// .zap(p, v) - set /x/./p/ = /v/ for all /x/ in _this_.
				// just like zip, zap("a.b") == zip("a").zap("b")
				// but unlike zip, you cannot assign to many /p/ at once
				if( !p ) return this
				var i = p.indexOf(".")
				return i > -1 ?  // is /p/ a compound name like "foo.bar"?
					this.zip(p.substr(0, i)) // if so, break off the front
						.zap(p.substr(i+1), v) // and recurse
					// accept /v/ as an array of values
					: isArray(v) ? this.each(function(x) {
						// i starts at -1 (since we didnt recurse)
						x[p] = v[++i] // so we increment first, ++i, to start at 0
					})
					// accept a single value v, even if v is undefined
					: this.each(function() { this[p] = v })
				/* Example:
					Set a property on all nodes at once.
					> $("pre").zap("style.display", "none")
					Hides all pre's.

					You can pass compound properties.
					> $("pre").zap("style.display", "block")

					You can pass multiple values for one property.

					> $("pre").take(3).zap("style.display",
					>		["block", "inline", "block"])

				*/
			},

			take: function take(n) {
				// .take([/n/]) - collect the first /n/ elements of _this_.
				// if n >= this.length, returns a shallow copy of the whole bling
				n = Math.min(n|0, this.len())
				var a = $(n), i = -1
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
				// .skip([/n/]) - collect all but the first /n/ elements of _this_.
				// if n == 0, returns a shallow copy of the whole bling
				n = Math.min(this.len(), Math.max(0, (n|0)))
				var a = $( n ),
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

			first: function first(n) {
				// .first([/n/]) - collect the first [/n/] element[s] from _this_.
				// if n is not passed, returns just the item (no bling)
				return n ? this.take(n)
					: this[0]
				/* Example:
					> $([1, 2, 3, 4]).first()
					> == 1

					> $([1, 2, 3, 4]).first(2)
					> == $([1, 2])

					> $([1, 2, 3, 4]).first(1)
					> == $([1])

				*/
			},

			last: function last(n) {
				// .last([/n/]) - collect the last [/n/] elements from _this_.
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

			join: function join(sep) {
				// .join(/sep/) - concatenates all /x/ in _this_ using /sep/
				if( this.length === 0 ) return ""
				return this.reduce(function(j) {
					return j + sep + this
				})
				/* Example:
					> $([1, 2, 3, 4, 5]).join(", ")
					> == "1, 2, 3, 4, 5"
				*/
			},

			slice: function slice(start, end) {
				// .slice(/i/, [/j/]) - get a subset of _this_ including [/i/../j/-1]
				// the j-th item will not be included - slice(0,2) will contain items 0, and 1.
				// negative indices work like in python: -1 is the last item, -2 is second-to-last
				// undefined start or end become 0, or this.length, respectively
				var b = $(Array.Slice(this, start, end))
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
				// note: unlike union, concat allows duplicates
				// note: also, does not create a new array, uses _this_
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

			push: function push(b) {
				// .push(/b/) - override Array.push to return _this_
				Array.prototype.push.call(this, b)
				return this
			},

			filter: function filter(f) {
				// .filter(/f/) - collect all /x/ from _this_ where /x/./f/(/x/) is true
				// or if f is a selector string, collects nodes that match the selector
				// or if f is a RegExp, collect nodes where f.test(x) is true
				var i = 0, j = -1, n = this.length,
					b = $(n), it = null
				b.context = this
				b.selector = f
				for(; i < n; i++ ) {
					it = this[i]
					if( it )
						if ( isFunc(f) && f.call( it, it )
							|| isString(f) && it.webkitMatchesSelector && it.webkitMatchesSelector(f)
							|| isType(f, "RegExp") && f.test(it)
							)
							b[++j] = it
				}
				return b
				/* Example:
					> $([1,2,3,4,5]).filter(function() {
					> 	return this % 2 == 0
					> })
					> == $([2,4,6])

					Or, you can filter by a selector.

					> $("pre").filter(".prettyprint")

					Or, you can filter by a RegExp.

					> $(["text", "test", "foo"].filter(/x/)
					> == $(["text"])

				*/
			},

			matches: function matches(expr) {
				// .matches(/expr/) - maps /x/.matchesSelector(/expr/) across _this_
				if( isType(expr, "RegExp") )
					return this.map(function() {
						return expr.test(this)
					})
				if( isString(expr) && this.webkitMatchesSelector )
					return this.map(function() {
						return this.webkitMatchesSelector(expr)
					})
				else
					return this.map(function() {
						return false
					})
				/* Example:
					> $("pre").matches(".prettyprint")
					> $([true, false, false, true, etc...])

					Or, the expr can be a RegExp.

					> $(["text", "test", "foo"]).matches(/x/)
					> == $([true, false, false])
				*/
			},

			weave: function weave(b) {
				// .weave(/b/) - interleave the items of _this_ and of _b_
				// to produce: $([ ..., b[i], this[i], ... ])
				// note: the items from b come first
				// note: if b and this are different lengths, the shorter
				// will yield undefineds into the result, which always has
				// 2 * max(length) items
				var n = b.length,
					nn = this.length,
					c = $(2 * Math.max(nn, n)),
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
				var b = $(Math.ceil(n/2)),
					 i = 0
				b.context = this.context
				b.selector = this.selector
				for( i = 0; i < n - 1; i += 2)
					b[j++] = f.call(this, this[i], this[i+1])
				// if there is an odd man out, make one last call
				if( (n%2) === 1 )
					b[j++] = f.call(this, this[n-1], undefined)

				return b
				/* Example:

					> $([1,2,3,4]).fold(function(x,y) { return x + y })
					> == $([3, 7])

				*/
			},

			flatten: function flatten() {
				// .flatten() - collect the union of all sets in _this_
				var b = $(),
					n = this.len(), c = null, d = 0,
					i = 0, j = 0, k = 0
				b.context = this.context
				b.selector = this.selector
				for(; i < n; i++)
					for(c = this[i], j = 0, d = c.length; j < d;)
						b[k++] = c[j++]
				return b
				/* Example:

					> $([[1,2], [3,4]]).flatten()
					> == $([1,2,3,4])
				*/
			},

			call: function call() {
				// .call([/args/]) - call all functions in _this_ [with /args/]
				return this.apply(null, arguments)
				/* Example:
					> $("pre").zip("getAttribute").call("class")
					> == $([... x.getAttribute("class") for each ...])
				*/
			},

			apply: function apply(context, args) {
				// .apply(/context/, [/args/]) - collect /f/.apply(/context/,/args/) for /f/ in _this_
				return this.map(function() {
					if( isFunc(this) )
						return this.apply(context, args)
					return this
				})
				/* Example:
					>	var a = {
					>		x: 1,
					>		getOne: function() {
					>			return this.x
					>		}
					>	}
					>	var b = {
					>		x: 2,
					>		getTwo: function() {
					>			return this.x
					>		}
					>	}
					> b.getTwo() == 2
					> a.getOne() == 1
					> $([a.getOne, b.getTwo]).apply(a)
					> == $([1, 1])

					This happens because both functions are called with 'a' as 'this', since it is the context argument to .apply()

					(In other words, it happens because b.getTwo.apply(a) == 1, because a.x == 1)
				*/

			},

			toString: function toString() {
				// .toString() - maps and joins toString across all elements
				return $.symbol
					+"(["
					+this.map(function(){
						return this === undefined || this === window ? "undefined"
							: this === null ? "null"
							: this.toString().replace(/\[object (\w+)\]/,"$1")
					}).join(", ")
					+"])"
				/* Example:
					> $("body").toString()
					> == "$([HTMLBodyElement])"
				*/
			},

			future: function future(n, f) {
				// .future(/n/, /f/) -  continue with /f/ on _this_ after /n/ milliseconds
				if( f ) { timeoutQueue.schedule(boundmethod(f, this), n) }
				return this
				/* Example:
					> $("pre").future(50, function sometimeLater() {
					> 	console.log(this.length)
					> })
					> console.log($("pre").length)

					The same number will log twice, one 50 milliseconds or more after the other.

					See the comments in the source for the full explanation as to why future() is more powerful than setTimeout on it's own.

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
				while( i > -1 && this[--i] === undefined) {/*spin*/}
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
					> $(b).len() === 1
					> b.length  === 10
				*/
			}

		}
	})

	$.plugin(function Html() {

		// these static DOM helpers are used inside some of the html methods
		// insert b before a
		function _before(a,b) { if( a && b ) a.parentNode.insertBefore(b, a) }
		// insert b after a
		function _after(a,b) { a.parentNode.insertBefore(b, a.nextSibling) }
		// convert nearly anything to something node-like for use in the DOM
		function toNode(x) {
			var ret = isNode(x) ? x
				: isBling(x) ? x.toFragment()
				: isString(x) ? $(x).toFragment()
				: isFunc(x.toString) ? $(x.toString()).toFragment()
				: undefined
			// TODO: consider removing... not super useful and in the middle of a very central operation
			$.nextguid = $.nextguid || 1
			if( ret && ret.guid == null )
				ret.guid = $.nextguid++
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

		return {
			$HTML: {
				// $.HTML.* - HTML methods similar to the global JSON object
				parse: function parse(h) {
					// $.HTML.parse(/h/) - parse the html in string h, return a Node.
					// will return a DocumentFragment if not well-formed.
					var d = document.createElement("body"),
						df = document.createDocumentFragment()
					d.innerHTML = h
					var n = d.childNodes.length
					if( n === 1 )
						return d.removeChild(d.childNodes[0])
					for(var i = 0; i < n; i++)
						df.appendChild(d.removeChild(d.childNodes[0]))
					return df
				},
				stringify: function stringify(n) {
					// $.HTML.stringify(/n/) - return the _Node_ /n/ in it's html-string form
					n = deepClone(n)
					var d = document.createElement("div")
					d.appendChild(n)
					var ret = d.innerHTML
					d.removeChild(n) // clean up to prevent leaks
					n.parentNode = null
					return ret
				},
				escape: function escape(h) {
					// $.HTML.escape(/h/) - accept html string /h/, return a string with html-escapes like &amp;
					escaper = escaper || $("<div>&nbsp;</div>").child(0)
					// insert html using the text node's .data property
					var ret = escaper.zap('data', h)
						// then get escaped html from the parent's .innerHTML
						.zip("parentNode.innerHTML").first()
					// clean up so escaped content isn't leaked into the DOM
					escaper.zap('data', '')
					return ret
				}
			},

			$Color: {
				// $.Color - provides functions for parsing and creating css colors
				fromCss: function fromCss(css) {
					// $.Color.fromCss(css) - convert any css color strings to numbers
					css = css || this
					if( isString(css) ) {
						var d = document.createElement("div")
						d.style.display = 'none'
						d.style.color = css
						$(document.body).append(d)
						var rgb = window.getComputedStyle(d,null).getPropertyValue('color')
						$(d).remove()
						if( rgb ) {
							// grab between the parens
							rgb = rgb.slice(rgb.indexOf('(')+1, rgb.indexOf(')'))
								.split(", ") // make an array
							if( rgb.length === 3 )
								rgb[3] = "1.0"
							// return floats
							return $( rgb ).floats()
						}
					}
					/* Example:

						> $.Color.fromCss("#ffffff")
						> == $([255, 255, 255, 1.0])

						> $(nodes).css("color").map($.Color.fromCss)
						> == $([$([255,255,255,1.0]), ...])
					*/
				},
				toCss: function toCss(b) {
					// $.Color.toCss(/b/) - convert a color array to a css string
					function f(t) {
						var r = t.map(Function.UpperLimit(255))
							.map(Function.LowerLimit(0))
						r[3] = Math.min(1, r[3])
						return "rgba(" + r.join(", ") + ")"
					}
					// accept either a $ of $s
					// or a single $ of numbers
					b = b || this
					if( isBling(b[0]) ) {
						return b.map(f)
					} else {
						return f(b)
					}
					/* Example:

						> $([255, 255, 255, 1.0])
						> == "rgba(255, 255, 255, 1.0)"

						> $([$([255,255,255,1.0]),])
						> == $(["rgba(255, 255, 255, 1.0)"])
					*/
				},
				invert: function invert(c) {
					// $.Color.invert(/c/) - compute the highest contrast color
					var b = $(4)
					if( isString(c) )
						c = $.Color.fromCss(c)
					b[0] = 255 - c[0]
					b[1] = 255 - c[1]
					b[2] = 255 - c[2]
					b[3] = c[3]
					return b
					/* Example:
						> $.Color.invert("#ffffff")
						> == $([0, 0, 0, 1.0])

						> $.Color.invert("#323232")
						> == $([205, 205, 205, 1.0])
					*/
				}
			},

			html: function html(h) {
				// .html([h]) - get [or set] /x/.innerHTML for each node
				return h === undefined ? this.zip('innerHTML')
					: isString(h) ? this.zap('innerHTML', h)
					: isBling(h) ? this.html(h.toFragment())
					: isNode(h) ? this.each(function() {
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
				a.skip(1).each(function() {
					this(deepClone(x))
				})
				return this
			},

			appendTo: function appendTo(x) {
				// .appendTo(/n/) - each node [or a fragment] will become the last child of n
				if( x == null ) return this
				$(x).append(this)
				return this
			},

			prepend: function prepend(x) {
				// .prepend(/n/) - insert n [or a clone] as the first child of each node
				if( x == null ) return this
				x = toNode(x)
				this.take(1).each(function() { _before(this.childNodes[0], x) })
				this.skip(1).each(function() { _before(this.childNodes[0], deepClone(x)) })
				return this
			},

			prependTo: function prependTo(x) {
				// .prependTo(/n/) - each node [or a fragment] will become the first child of n
				if( x == null ) return this
				$(x).prepend(this)
				return this
			},

			before: function before(x) {
				// .before(/n/) - insert content n before each node
				if( x == null ) return this
				x = toNode(x)
				this.take(1).each(function() { _before(this, x) })
				this.skip(1).each(function() { _before(this, deepClone(x)) })
				return this
			},

			after: function after(x) {
				// .after(/n/) - insert content n after each node
				if( x == null ) return this
				x = toNode(x)
				this.take(1).each(function() { _after(this, x) })
				this.skip(1).each(function() { _after(this, deepClone(x)) })
				return this
			},

			wrap: function wrap(parent) {
				// .wrap(/p/) - p becomes the new .parentNode of each node
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
				return this.each(function() {
					if( this.parentNode && this.parentNode.parentNode )
						this.parentNode.parentNode
							.replaceChild(this, this.parentNode)
				})
			},

			replace: function replace(n) {
				// .replace(/n/) - replace each node with n [or a clone]
				n = toNode(n)
				var b = $(), j = -1
				// first node gets the real n
				this.take(1).each(function() {
					if( this.parentNode ) {
						this.parentNode.replaceChild(n, this)
						b[++j] = n
					}
				})
				// the rest get clones of n
				this.skip(1).each(function() {
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
				var f = v === undefined ? "getAttribute"
					: v === null ? "removeAttribute"
					: "setAttribute"
				var ret = this.zip(f).call(a,v)
				return v ? this : ret
			},

			addClass: function addClass(x) {
				// .addClass(/x/) - add x to each node's .className
				// remove the node and then add it to avoid dups
				return this.removeClass(x).each(function() {
					var c = this.className.split(" ").filter(function(y){return y && y != ""})
					c.push(x) // since we dont know the len, its still faster to push, rather than insert at len()
					this.className = c.join(" ")
				})
			},

			removeClass: function removeClass(x) {
				// .removeClass(/x/) - remove class x from each node's .className
				var notx = function(y){ return y != x }
				return this.each(function() {
					this.className = this.className.split(" ").filter(notx).join(" ")
				})
			},

			toggleClass: function toggleClass(x) {
				// .toggleClass(/x/) - add, or remove if present, class x from each node
				function notx(y) { return y != x }
				return this.each(function(node) {
					var cls = node.className.split(" ")
					if( cls.indexOf(x) > -1 )
						node.className = cls.filter(notx).join(" ")
					else {
						cls.push(x)
						node.className = cls.join(" ")
					}
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
					var webkit_re = /^-webkit-/
					var setter = this.zip('style.setProperty')
					
					// HACK: so... this would be a prime where we could slow down all browsers
					// in order to support more than just webkit... testing is needed to
					// know the true cost, .css() is a very central function
					/* DISABLED:
					setter = setter.map(function(){
						var set = tracemethod(this, 'setProperty')
						return function(k,v) {
							if( webkit_re.test(k) ) {
								set(k.replace(webkit_re, '-moz-'), v)
								set(k.replace(webkit_re, '-o-'), v)
								set(k.replace(webkit_re, ''), v)
							}
							set(k,v)
						}
					})
					*/

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
				/* Example:
				> $("body").css("background-color", "black").css("color", "white")

				> $("body").css({color: "white", "background-color": "black"})

				Special Sauce: Any property that begins with -webkit-, gets cloned like so:

				> $("button").css("-webkit-border-radius", "5px")
				> == $("button").css({
				>		"-webkit-border-radius": "5px",
				>		"-moz-border-radius": "5px",
				>		"-o-border-radius": "5px",
				>		"border-radius": "5px"
				> })
				*/
			},

			defaultCss: function defaultCss(k, v) {
				// .defaultCss(k, [v]) - adds an inline style tag to the head for the current selector.
				// If k is an object of k:v pairs, then no second argument is needed.
				// Unlike css() which applies css directly to the style attribute,
				// defaultCss() adds actual css text to the page, based on this.selector,
				// so it can still be over-ridden by external css files (such as themes)
				// also, this.selector need not match any nodes at the time of the call
				var sel = this.selector,
					style = "<style> ",
					head = $("head")
				if( isString(k) )
					if( isString(v) )
						style += sel+" { "+k+": "+v+" } "
					else throw Error("defaultCss requires a value with a string key")
				else if( isObject(k) ) {
					style += sel+" { "
					for( var i in k )
						style += i+": "+k[i]
					style += " } "
				}
				style += "</style>"
				head.append(style)
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
				return this.each(function() {
					var t = $(this),
						h = t.height().floats().first(),
						w = t.width().floats().first(),
						x = (mode === "viewport" || mode === "horizontal"
							? document.body.scrollLeft + vw - (w/2)
							:  NaN),
						y = (mode === "viewport" || mode === "vertical"
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
				reducer = reducer || function _reducer(a) {
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
							.map($.Color.fromCss)
							// reverse the order so we add colors from back to fore
							.reverse()
							// then collapse each list of [r,g,b,a]
							.reduce(reducer, $([0,0,0,0]))
							// and output a css string
							.map($.Color.toCss)
					})
			},

			child: function child(n) {
				// .child(/n/) - returns the nth childNode for all items in this
				return this.map(function() { 
					return this.childNodes[n >= 0 ? n : n + this.childNodes.length]
				})
			},

			children: function children() {
				// .children() - returns all children of each node
				return this.map(function() {
					return $(this.childNodes, this)
				})
			},

			parent: function parent() {
				// .parent() - collects the parentNode of each item in this
				return this.zip('parentNode')
			},

			parents: function parents() {
				// .parents() - collects the full ancestry up to the owner
				return this.map(function() {
					var b = $(), j = -1,
						p = this
					while( p = p.parentNode )
						b[++j] = p
					return b
				})
			},

			prev: function prev() {
				// .prev() - collects the full chain of .previousSibling nodes
				return this.map(function() {
					var b = $(), j = -1,
						p = this
					while( p = p.previousSibling )
						b[++j] = p
					return b
				})
			},

			next: function next() {
				// .next() - collects the full chain of .nextSibling nodes
				return this.map(function() {
					var b = $(), j = -1,
						p = this
					while( p = p.previousSibling )
						b[++j] = p
					return b
				})
			},

			remove: function remove() {
				// .remove() - removes each node from the DOM
				return this.each(function(){
					if( this.parentNode ) {
						this.parentNode.removeChild(this)
					}
				})
			},

			find: function find(expr) {
				// .find(expr) - collects nodes matching expr, using each node in this as context
				return this.filter("*") // limit to only nodes
					.map(function() { return $(expr, this) })
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
				if( this.length === 1 )
					return toNode(this[0])
				var f = document.createDocumentFragment()
				this.map(toNode).map(boundmethod(f.appendChild, f))
				return f
			}
		}
	})

	$.plugin(function Math() {
		return {
			floats: function floats() {
				// .floats() - parseFloat(/x/) for /x/ in _this_
				return this.map(function() {
					if( isBling(this) ) return this.floats()
					return parseFloat(this)
				})
			},

			ints: function ints() {
				// .ints() - parseInt(/x/) for /x/ in _this_
				return this.map(function() {
					if( isBling(this) ) return this.ints()
					return parseInt(this,10)
				})
			},

			px: function px(delta) {
				// .px([delta]) - collect "NNpx" strings
				delta = delta || 0
				return this.ints().map(Function.Px(delta))
			},

			min: function min() {
				// .min() - select the smallest /x/ in _this_
				return this.reduce(function(a) {
					if( isBling(this) ) return this.min()
					return Math.min(this,a)
				})
			},

			max: function max() {
				// .max() - select the largest /x/ in _this_
				return this.reduce(function(a) {
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
				return this.reduce(function(a) {
					if( isBling(this) ) return a + this.sum()
					return a + this
				})
			},

			squares: function squares()  {
				// .squares() - collect /x/*/x/ for each /x/ in _this_
				return this.map(function() {
					if( isBling(this) ) return this.squares()
					return this * this
				})
			},

			magnitude: function magnitude() {
				// .magnitude() - compute the vector length of _this_
				var n = this.map(function() {
					if( isBling(this) ) return this.magnitude()
					return parseFloat(this)
				})
				return Math.sqrt(n.squares().sum())
			},

			scale: function scale(r) {
				// .scale(/r/) - /x/ *= /r/ for /x/ in _this_
				return this.map(function() {
					if( isBling(this) ) return this.scale(r)
					return r * this
				})
			},

			normalize: function normalize() {
				// .normalize() - scale _this_ so that .magnitude() == 1
				return this.scale(1/this.magnitude())
			}
		}
	})

	$.plugin(function Event() {

		function binder(e) {
			// eval is evil! but there is no other way to set a function's name, and the generated docs need a name
			// also, we have to be even slightly more evil, to prevent the jsc compiler from mangling local names like f
			eval("var f = function "+e+"(f) { // ."+e+"([f]) - trigger [or bind] the '"+e+"' event \nreturn isFunc(f) ? this.bind('"+e+"',f) : this.trigger('"+e+"', f ? f : {}) }")
			return eval("f")
		}

		function register_live(selector, context, e, f, h) {
			var $c = $(context)
			$c.bind(e, h) // bind the real handler
				.each(function() { 
					var a = (this.__alive__ = this.__alive__ || {} ),
						b = (a[selector] = a[selector] || {}),
						c = (b[e] = b[e] || {})
					// make a record using the fake handler
					c[f] = h
				})
		}

		function unregister_live(selector, context, e, f) {
			var $c = $(context)
			$c.each(function() { 
				var a = (this.__alive__ = this.__alive__ || {} ),
					b = (a[selector] = a[selector] || {}),
					c = (b[e] = b[e] || {}),
					h = c[f]
				$c.unbind(e, h)
				delete c[f]
			})
		}

		// detect and fire the document.ready event
		setTimeout(function() {
			if( $.prototype.trigger != null
				&& document.readyState === "complete") {
				$(document).trigger('ready')
			} else {
				setTimeout(arguments.callee, 20)
			}
		}, 0)

		var comma_sep = /, */

		return {
			bind: function bind(e, f) {
				// .bind(e, f) - adds handler f for event type e
				// e is a string like 'click', 'mouseover', etc.
				// e can be comma-separated to bind multiple events at once
				var i = 0,
					c = (e||"").split(comma_sep),
					n = c.length
				return this.each(function() {
					for(; i < n; i++) {
						this.addEventListener(c[i], f)
					}
				})
			},

			unbind: function unbind(e, f) {
				// .unbind(e, [f]) - removes handler f from event e
				// if f is not present, removes all handlers from e
				var i = 0,
					c = (e||"").split(comma_sep),
					n = c.length
				return this.each(function() {
					for(; i < n; i++) {
						this.removeEventListener(c[i],f)
					}
				})
			},

			once: function once(e, f) {
				// .once(e, f) - adds a handler f that will be called only once
				var i = 0,
					c = (e||"").split(comma_sep),
					n = c.length
				for(; i < n; i++) {
					this.bind(c[i], function(evt) {
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
					c = (e||"").split(comma_sep),
					ne = c.length,
					nf = funcs.length
				function cycler() {
					var i = 0
					return function(evt) {
						funcs[i].call(this, evt)
						i = ++i % nf
					}
				}
				while( j < ne )
					this.bind(c[j++], cycler())
				return this
			},

			trigger: function trigger(evt, args) {
				// .trigger(e, a) - initiates a fake event
				// evt is the type, 'click'
				// args is an optional mapping of properties to set,
				//   {screenX: 10, screenY: 10}
				// note: not all browsers support manually creating all event types
				var e, i = 0,
					evts = (evt||"").split(comma_sep),
					n = evts.length,
					evt_i = null
				args = Object.Extend({
					bubbles: true,
					cancelable: true
				}, args)

				for(; i < n; i++) {
					evt_i = evts[i]
					switch(evt_i) {
						// mouse events
						case "click":
						case "mousemove":
						case "mousedown":
						case "mouseup":
						case "mouseover":
						case "mouseout":
							e = document.createEvent("MouseEvents")
							args = Object.Extend({
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
								args.button, args.relatedTarget)
							break

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
							break

						// iphone touch events
						case "touchstart":
						case "touchmove":
						case "touchend":
						case "touchcancel":
							e = document.createEvent("TouchEvents")
							args = Object.Extend({
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
								args.touches, args.targetTouches, args.changedTouches, args.scale, args.rotation)
							break

						// iphone gesture events
						case "gesturestart":
						case "gestureend":
						case "gesturecancel":
							e = document.createEvent("GestureEvents")
							args = Object.Extend({
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
								args.target, args.scale, args.rotation)
							break

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
							e = document.createEvent("Events")
							e.initEvent(evt_i, args.bubbles, args.cancelable)
					}
					if( !e ) continue
					else this.each(function() {
						this.dispatchEvent(e)
						delete e.result
						delete e.returnValue
					})
				}

				return this

			},

			live: function live(e, f) {
				// .live(e, f) - handle events for nodes that will exist in the future
				var selector = this.selector,
					context = this.context
				// wrap f
				function _handler(evt) {
					// when the 'live' event is fired
					// re-execute the selector in the original context
					$(selector, context)
						// then see if the event would bubble into a match
						.intersect($(evt.target).parents().first().union($(evt.target)))
						// then fire the real handler on the matched nodes
						.each(function() {
							evt.target = this
							f.call(this, evt)
						})
				}
				// bind the handler to the context
				$(context).bind(e, _handler)
				// record f so we can 'die' it if needed
				register_live(selector, context, e, f, _handler)
				return this
			},

			die: function die(e, f) {
				// die(e, [f]) - stop f [or all] from living for event e
				var selector = this.selector,
					context = this.context,
					h = unregister_live(selector, context, e, f)
				$(context).unbind(e, h)
				return this
			},

			liveCycle: function liveCycle(e) {
				// .liveCycle(e, ...) - bind each /f/ in /.../ to /e/
				// one call per trigger. when the last handler is executed
				// the next trigger will call the first handler again
				var i = 0,
					funcs = Array.Slice(arguments, 1, arguments.length)
				return this.live(e, function(evt) {
					funcs[i].call(this, evt)
					i = ++i % funcs.length
				})
			},

			// short-cuts for calling bind or trigger
			click: function click(f) {
				// .click([f]) - trigger [or bind] the 'click' event
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
			keyup: binder('keyup'),
			keydown: binder('keydown'),
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

	$.plugin(function Transform() {
		// the regex that matches all the accelerated css property names
		var accel_props_re = /(?:scale|translate|rotate|scale3d|translateX|translateY|translateZ|translate3d|rotateX|rotateY|rotateZ|rotate3d)/

		var speeds = {
			"slow": 700,
			"medium": 500,
			"normal": 300,
			"fast": 100,
			"instant": 0,
			"now": 0
		}

		/// Transformation Module: provides wrapper for using -webkit-transform ///
		return {
			$duration: function duration(speed) {
				// $.duration(/s/) - given a speed description (string|number), return a number in milliseconds
				return speeds[speed] || parseFloat(speed)
			},

			// like jquery's animate(), but using only webkit-transition/transform
			transform: function transform(end_css, speed, callback) {
				// .transform(css, [/s/], [/cb/]) - animate css properties on each node
				// animate css properties over a duration
				// accelerated: scale, translate, rotate, scale3d,
				// ... translateX, translateY, translateZ, translate3d,
				// ... rotateX, rotateY, rotateZ, rotate3d
				if( isFunc(speed) ) {
					callback = speed
					speed = null 
				}
				speed = speed || "normal"
				var duration = $.duration(speed),
					props = [], j = 0, i = 0, ii = null,
					// what to send to the -webkit-transform
					trans = "",
					// real css values to be set (end_css without the transform values)
					css = {}
				for( i in end_css )
					// pull all the accelerated values out of end_css
					if( accel_props_re.test(i) ) {
						ii = end_css[i]
						if( ii.join )
							ii = ii.join(", ")
						else if( ii.toString )
							ii = ii.toString()
						trans += " " + i + "(" + ii + ")"
					}
					else // stick real css values in the css dict
						css[i] = end_css[i]
				// make a list of the properties to be modified
				for( i in css )
					props[j++] = i
				// and include -webkit-transform if we have transform values to set
				if( trans )
					props[j++] = "-webkit-transfrom"

				// apply the duration (TODO: and easing)
				// set which properties to apply a duration to
				css['-webkit-transition-property'] = props.join(', ')
				// apply the same duration to each property
				css['-webkit-transition-duration'] =
					props.map(function() { return duration + "ms" })
						.join(', ')

				// apply the transformation
				if( trans )
					css['-webkit-transform'] = trans
				// apply the css to the actual node
				this.css(css)
				// queue the callback to be executed at the end of the animation
				// NOT EXACT!
				return this.future(duration, callback)
			},

			hide: function hide(callback) {
				// .hide() - each node gets display:none
				return this.each(function() {
					if( this.style ) {
						this._display = this.style.display === "none" ? "" : this.style.display
						this.style.display = 'none'
					}
				}).future(50, callback)
			},

			show: function show(callback) {
				// .show() - show each node
				return this.each(function() {
					if( this.style ) {
						this.style.display = this._display
						delete this._display
					}
				}).future(50, callback)
			},

			toggle: function toggle(callback) {
				// .toggle() - show each hidden node, hide each visible one
				this.weave(this.css("display"))
					.fold(function(display, node) {
						if( display === "none" ) {
							node.style.display = node._old_display ? node._old_display : "block"
							delete node._old_display
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
					.show(function(){
						this.transform({opacity:"1.0", translate3d:[0,0,0]}, speed, callback)
					})
			},
			fadeOut:   function fadeOut(speed, callback, _x, _y) {
				// .fadeOut() - fade each node to opacity:0.0
				_x = _x || 0.0
				_y = _y || 0.0
				return this.each(function(t) {
					$(t).transform({
						opacity:"0.0",
						translate3d:[_x,_y,0.0]
					}, speed, function() { this.hide() })
				}).future($.duration(speed), callback)
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

	$.plugin(function Http() {
		/// HTTP Request Module: provides wrappers for making http requests ///

		var JSON = JSON || {}

		// static helper to create &foo=bar strings from object properties
		function formencode(obj) {
			var s = [], j = 0, o = JSON.parse(JSON.stringify(obj)) // quickly remove all non-stringable items
			for( var i in o )
				s[j++] = i + "=" + escape(o[i])
			return s.join("&")
		}

		return {
			$http: function http(url, opts) {
				var xhr = new XMLHttpRequest()
				if( isFunc(opts) )
					opts = {success: boundmethod(opts, xhr)}
				opts = Object.Extend({
					method: "GET",
					data: null,
					state: Function.Empty, // onreadystatechange
					success: Function.Empty, // onload
					error: Function.Empty, // onerror
					async: true,
					withCredentials: false
				}, opts)
				opts.state = boundmethod(opts.state, xhr)
				opts.success = boundmethod(opts.success, xhr)
				opts.error = boundmethod(opts.error, xhr)
				if( opts.data && opts.method === "GET" )
					url += "?" + formencode(opts.data)
				else if( opts.data && opts.method === "POST" )
					opts.data = formencode(opts.data)
				xhr.open(opts.method, url, opts.async)
				xhr.withCredentials = opts.withCredentials
				xhr.onreadystatechange = function onreadystatechange() {
					if( opts.state ) opts.state()
					if( xhr.readyState === 4 )
						if( xhr.status === 200 )
							opts.success(xhr.responseText)
						else
							opts.error(xhr.status, xhr.statusText)
				}
				xhr.send(opts.data)
				return $([xhr])
			},

			$post: function post(url, opts) {
				if( isFunc(opts) )
					opts = {success: opts}
				opts = opts || {}
				opts.method = "POST"
				return $.http(url, opts)
			},

			$get: function get(url, opts) {
				if( isFunc(opts) )
					opts = {success: opts}
				opts = opts || {}
				opts.method = "GET"
				return $.http(url, opts)
			}
		}
	})

	$.plugin(function Database() {
		/// Database Module: provides access to the sqlite database ///

		// static error handler
		function SqlError(t, e) { throw new Error("sql error ["+e.code+"] "+e.message) }

		function assert(cond, msg) {
			if( ! cond ) {
				throw new Error("assert failed: "+msg)
			}
		}

		function execute(stmt, values, callback, errors) {
			// .execute(/sql/, [/values/], [/cb/], [/errcb/]) - shortcut for using transaction
			if( stmt == null ) return null
			if( isFunc(values) ) {
				errors = callback
				callback = values
				values = null
			}
			values = values || []
			callback = callback || Function.Empty
			errors = errors || SqlError
			assert( isType(this[0], "Database"), "can only call .sql() on a bling of Database" )
			return this.transaction(function(t) {
				t.executeSql(stmt, values, callback, errors)
			})
		}
		function transaction( f ) {
			// .transaction() - provides access to the db's raw transaction() method
			// but, use .execute() instead, its friendlier
			this.zip('transaction').call(f)
			return this
		}
		return {
			$db: function db(fileName, version, displayName, maxSize) {
				// .db([/file/], [/ver/], [/name/], [/size/]) - get a new connection to the local database
				var d = $([window.openDatabase(
					fileName || "bling.db",
					version || "1.0",
					displayName || "bling database",
					maxSize || 1024)
				])
				d.transaction = transaction
				d.execute = execute
				return d
			}
		}
	})

	$.plugin(function Template() {
		function match_forward(text, find, against, start, stop) {
			var count = 1
			if( stop == null || stop === -1 )
				stop = text.length
			for( var i = start; i < stop; i++ ) {
				if( text.charAt(i) === against )
					count += 1
				else if( text.charAt(i) === find )
					count -= 1
				if( count === 0 )
					return i
			}
			return -1
		}

		var type_re = /([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/

		function compile(text) {
			var ret = [],
				chunks = text.split(/%[\(\/]/),
				end = -1, i = 1, n = chunks.length,
				key = null, rest = null, match = null
			ret.push(chunks[0])
			for( ; i < n; i++) {
				end = match_forward(chunks[i], ')', '(', 0, -1)
				if( end === -1 )
					return "Template syntax error: unmatched '%(' in chunk starting at: "+chunks[i].substring(0,15)
				key = chunks[i].substring(0,end)
				rest = chunks[i].substring(end)
				match = type_re.exec(rest)
				if( match === null )
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
		compile.cache = {}

		function _render(text, values) {
			// $.render(/t/, /v/) - replace markers in string /t/ with values from /v/
			var cache = compile.cache[text] // get the cached version
				|| (compile.cache[text] = compile(text)), // or compile and cache it
				// the first block is always just text
				output = [cache[0]],
				// j is an insert marker into output
				j = 1 // (because .push() is slow on an iphone, but inserting at length is fast everywhere)
				// (and because building up this list is the bulk of what render does)

			// then the rest of the cache items are: [key, pad, fixed, type, text remainder] 5-lets
			for( var i = 1, n = cache.length; i < n-4; i += 5) {
				var key = cache[i],
					// the format in three pieces
					// (\d).\d\w
					pad = cache[i+1],
					// \d.(\d)\w
					fixed = cache[i+2],
					// \d.\d(\w)
					type = cache[i+3],
					// the text remaining after the end of the format
					rest = cache[i+4],
					// the value to render for this key
					value = values[key]

				// require the value
				if( value == null )
					value = "missing required value: "+key

				// format the value according to the format options
				// currently supports 'd', 'f', and 's'
				switch( type ) {
					case 'd':
						output[j++] = "" + parseInt(value, 10)
						break
					case 'f':
						output[j++] = parseFloat(value).toFixed(fixed)
						break
					// output unsupported formats like %s strings
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

		// modes for the synth machine
		var TAGMODE = 1, IDMODE = 2, CLSMODE = 3, ATTRMODE = 4, VALMODE = 5, DTEXTMODE = 6, STEXTMODE = 7

		function _synth(expr) {
			// $.synth(/expr/) - given a CSS expression, create DOM nodes that match
			var tagname = '', id = '', cls = '', attr = '', val = '',
				text = '', attrs = {}, parent = null, mode = TAGMODE,
				ret = $([]), i = 0, c = null
			function emitText() {
				// puts a TextNode in the resulting tree
				var node = $.HTML.parse(text)
				if( parent )
					parent.appendChild(node)
				else
					ret.push(node)
				text = ''
				mode = TAGMODE
			}
			function emitNode() {
				// puts a Node in the results
				var node = document.createElement(tagname)
				node.id = id ? id : null
				node.className = cls ? cls : null
				for(var k in attrs)
					node.setAttribute(k, attrs[k])
				if( parent )
					parent.appendChild(node)
				else
					ret.push(node)
				parent = node
				tagname = ''; id = ''; cls = ''
				attr = ''; val = ''; text = ''
				attrs = {}
				mode = TAGMODE
			}

			// 'c' steps across the input, one character at a time
			while( (c = expr.charAt(i++)) ) {
				if( c === '+' && mode === TAGMODE)
					parent = parent ? parent.parentNode : parent
				else if( c === '#' && (mode === TAGMODE || mode === CLSMODE || mode === ATTRMODE) )
					mode = IDMODE
				else if( c === '.' && (mode === TAGMODE || mode === IDMODE || mode === ATTRMODE) ) {
					if( cls.length > 0 )
						cls += " "
					mode = CLSMODE
				}
				else if( c === '.' && cls.length > 0 )
					cls += " "
				else if( c === '[' && (mode === TAGMODE || mode === IDMODE || mode === CLSMODE || mode === ATTRMODE) )
					mode = ATTRMODE
				else if( c === '=' && (mode === ATTRMODE))
					mode = VALMODE
				else if( c === '"' && mode === TAGMODE)
					mode = DTEXTMODE
				else if( c === "'" && mode === TAGMODE)
					mode = STEXTMODE
				else if( c === ']' && (mode === ATTRMODE || mode === VALMODE) ) {
					attrs[attr] = val
					attr = ''
					val = ''
					mode = TAGMODE
				}
				else if( c === '"' && mode === DTEXTMODE )
					emitText()
				else if( c === "'" && mode === STEXTMODE )
					emitText()
				else if( (c === ' ' || c === ',') && (mode !== VALMODE && mode !== ATTRMODE) && tagname.length > 0 ) {
					emitNode()
					if( c == ',' )
						parent = null
				}
				else if( mode === TAGMODE )
					tagname += c != ' ' ? c : ''
				else if( mode === IDMODE ) id += c
				else if( mode === CLSMODE ) cls += c
				else if( mode === ATTRMODE ) attr += c
				else if( mode === VALMODE ) val += c
				else if( mode === DTEXTMODE || mode === STEXTMODE ) text += c
				else throw new Error("Unknown input/state: '"+c+"'/"+mode)
			}

			if( tagname.length > 0 )
				emitNode()

			if( text.length > 0 )
				emitText()

			return ret
		}

		return {
			$render: _render,
			$synth: _synth,

			template: function template(defaults) {
				// .template([defaults]) - mark nodes as templates, add optional defaults to .render()
				// if defaults is passed, these will be the default values for v in .render(v)
				this.render = function(args) {
					// an over-ride of the basic .render() that applies these defaults
					return _render(this.map($.HTML.stringify).join(''), Object.Extend(defaults,args))
				}

				return this.remove() // the template item itself should not be in the DOM
			},

			render: function render(args) {
				// .render(args) - replace %(var)s-type strings with values from args
				// accepts nodes, returns a string
				return _render(this.map($.HTML.stringify).join(''), args)
			},

			synth: function synth(expr) {
				// .synth(expr) - create DOM nodes to match a simple css expression
				// supports the following css selectors:
				// tag, #id, .class, [attr=val]
				// and the additional helper "text"
				return _synth(expr).appendTo(this)

				/* Example:
					> $("body").synth("div#one.foo.bar[orb=bro] span + p")
					> == $([<div id="one" class="foo bar" orb="bro"> <span></span> <p></p> </div>])

					And, the new nodes would already be children of "body".

					You can create the nodes on their own by using the global version:

					> $.synth("div#one p")
					> == $([<div id="one"><p></p></div>])

					These will not be attached to anything when they are returned.

					Each expression returns a single node that is the parent of the new tree.
					But, you can pass in a comma-separated list of expressions to multiple nodes back.

					> $.synth("div#one, div#two")
					> == $([<div id="one"></div>, <div id="two"></div>])

					You can use the new quote selector to add text nodes.

					> $.synth('div#one "hello" + div#two "world"')
					> == $([<div id="one">hello<div id="two">world</div></div>])

					You can use the '+' operator not only for adjacency:

					> $.synth("div h3 'title' + p 'body'")
					> == $([<div><h3>title</h3><p>body</p></div>])

					But, you can also repeat the '+' in order to ascend any number of times.

					> $.synth("ul li h3 'one' + p 'body' ++ li h3 'two' + p 'body'")
					> == $([<ul><li><h3>one</h3><p>body</p><li><h3>two</h3><p>body</p></li></ul>])

					If you ascend higher than the root, you get a list of separate nodes.

					> $.synth("ul li p +++ span")
					> == $([<ul><li><p></p></li></ul>, <span></span>])

				*/
			}

		}
	})

})(Bling)
