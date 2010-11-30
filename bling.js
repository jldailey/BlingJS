/* bling.js
 * --------
 * Named after the bling operator ($) to which it is bound by default.
 * This is a jQuery-like framework, using any WebKit shortcuts that we can.
 * All other browsers play at your own risk.
 * Blame: Jesse Dailey <jesse.dailey@gmail.com>
 */

Object.Extend = function extend(a, b, c) {
	// .extend(a, b, [c]) - merge values from b into a
	// if c is present, it should be a list of property names to copy
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

Object.Keys = function(o) {
	var keys = [], j = 0
	for( var i in o )
		keys[j++] = i
	return keys
}

Object.Extend(Function.prototype, {
	inherit: function (T) {
		//  A.inherit(T) will make type A inherit members from type T.
		this.prototype = new T() // get a copy of T's prototype (a copy!)
		return this.prototype.constructor = this // set the copy's constructor to ours
		/* Example:
			Make a subclass of Array

			> function MyType(){
			>	 Array.apply(this, arguments);
			> }
			> MyType.inherit(Array)
			> var a = new MyType()
			> a.push("foo")
		*/
	},
	bound: function (t, args) {
		// /f/.bound(/t/) - whenever /f/ is called, _this_ === /t/
		var f = this // the original function
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

			> more_stars = ["Janet", "Micheal", "Latoya"];
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
})

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

		if( selector[0] == "<" )
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
		else if( context.querySelectorAll != undefined )
			try {
				set = context.querySelectorAll(selector)
			} catch ( err ) {
				throw Error("invalid selector: " + selector, err)
			}
		else throw Error("invalid context: " + context)
	}
	else
		set = selector

	set.__proto__ = Bling.prototype
	set.selector = selector
	set.context = context

	return set
}
// finish defining the Bling type
Bling.inherit(Array)
function isBling(a)  { return isType(a, Bling) }
$ = Bling
Bling.symbol = "$" // for display purposes

/* Type Checking
 * -------------
 * Since we have a clear definition of inheritance, we can clearly detect
 * types and sub-types.
 * If you don't have a reference to the actual type,
 * you can pass the name as a string: isType(window, "DOMWindow") === true
 */
Object.Extend(window, {
	isType: function(a,T) {
		// isType(a,T) - true if object a is of type T (directly)
		return !a ? T === a
			: typeof(T) === "string" ? a.__proto__.constructor.name == T
			: a.__proto__.constructor === T
	},
	isSubtype: function(a, T) {
		// isSubtype(a,T) - true if object a is of type T (directly or indirectly)
		return a == null ? a == T
			: a.__proto__ == null ? false
			: typeof(T) === "string" ? a.__proto__.constructor.name == T
			: a.__proto__.constructor == T ? true
			: isSubtype(a.__proto__, T) // recursive
	},
	isString: function(a) {
		// isString(a) - true if object a is a string
		return typeof(a) == "string" || isSubtype(a, String)
	},
	// isNumber(a) - true if object a is a number
	isNumber: isFinite,
	isFunc: function(a) {
		// isFunc(a) - true if object a is a function
		return typeof(a) == "function" || isType(a, Function)
	},
	isNode: function(a) {
		// isNode(a) - true if object is a DOM node
		return a ? a.nodeType > 0 : false
	},
	isFragment: function(a) {
		// isFragment(a) - true if object is a DocumentFragment node
		return a ? a.nodeType == 11 : false
	},
	isArray: function(a) {
		// isArray(a) - true if object is an Array (or inherits Array)
		return a ? Function.ToString(a) == "[object Array]"
			|| isSubtype(a, Array) : false
	},
	isObject: function(a) {
		// isObject(a) - true if a is an object
		return typeof(a) == "object"
	},
	hasValue: function(a) {
		// hasValue(a) - true if a is not null nor undefined
		return !(a == null)
	}
})

// cache a reference
var OtoS = Object.prototype.toString

// Array.Slice works like python's slice (negative indexes, etc)
// and works on any indexable (not just array instances, notably 'arguments')
Array.Slice = function (o, i, j) {
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
Number.Px = function (x,d) { return (parseInt(x)+(d|0))+"px" }

// add string functions
Object.Extend(String, {
	HtmlEscape: function htmlescape(x) {
		// String.HtmlEscape(string) - take an string of html, return a string of escaped html
		return x.replace(/</g,'&lt;')
		.replace(/>/g,'&gt;')
		.replace(/\t/g,'&nbsp;&nbsp;')
	},
	PadLeft: function pad(s, n, c) {
		// String.PadLeft(string, width, fill=" ")
		c = c || " "
		while( s.length < n )
			s = c + s
		return s
	},
	Splice: function splice() {
		// String.Splice(start, length, ...) - replace a substring with ...
		var s = arguments[0], a = arguments[1], b = arguments[2],
			repl = Array.Slice(arguments, 3).join('')
		return s.substring(0,a) + repl + s.substring(b)
	}
})

// build simple closures to avoid repitition later
Object.Extend(Function, {
	Empty: function (){},
	NotNull: function (x) { return x != null },
	NotUndefined: function (x) { return x != undefined },
	IndexFound: function (x) { return x > -1 },
	ReduceAnd: function (x) { return x && this },
	UpperLimit: function (x) { return function(y) { return Math.min(x, y) }},
	LowerLimit: function (x) { return function(y) { return Math.max(x, y) }},
	ToString: function (x) { return OtoS.apply(x) },
	Px: function (d) { return function() { return Number.Px(this,d) } },
	PrettyPrint: (function() {
		var operators = /!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g,
			keywords = /\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g,
			singleline_comment = /\/\/.*?(?:\n|$)/,
			multiline_comment = /\/\*(?:.|\n)*?\*\//,
			all_numbers = /\d+\.*\d*/g,
			bling_symbol = /\$(?:\(|\.)/g
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
		return function prettyPrint(js, colors) {
			if( isFunc(js) )
				js = js.toString()
			if( ! isString(js) )
				throw TypeError("prettyPrint requires a function or string to format")
			if( $("style#pp-injected").length == 0 ) {
				colors = Object.Extend({
					opr: "#880",
					str: "#008",
					com: "#080",
					kwd: "#088",
					num: "#808",
					bln: "#800"
				}, colors)
				var css = "code.pp .bln { font-size: 17px; } "
				for( var i in colors )
					css += "code.pp ."+i+" { color: "+colors[i]+"; }"
				$("head").append($.synth("style#pp-injected").text(css))
			}
			return "<code class='pp'>"+
				// extract comments
				$(extract_comments(js))
					.fold(function(text, comment) {
						// extract quoted strings
						return $(extract_quoted(text))
							.fold(function(code, quoted) {
								// label number constants
								return (code
									// label operator symbols
									.replace(operators, "<span class='opr'>$&</span>")
									// label numbers
									.replace(all_numbers, "<span class='num'>$&</span>")
									// label keywords
									.replace(keywords, "<span class='kwd'>$&</span>")
									.replace(bling_symbol, "<span class='bln'>$$</span>(")
									.replace(/\t/g, "&nbsp;&nbsp;")
								) +
								// label string constants
								(quoted ? "<span class='str'>"+quoted+"</span>" : "")
							})
							// collapse the strings
							.join('')
							// append the extracted comment
							+ (comment ? "<span class='com'>"+comment+"</span>" : "")
					})
					.join('')+
			"</code>"
		}
	})()
})

Bling.addOps = function addOps() {
	// .addOps([obj or funcs]) - adds bling operations
	// ex. Bling.addOps({nop:function(){ return this; })
	// ex. Bling.addOps(function nop(){ return this })
	// $("body").nop().nop()
	for(var i = 0, n = arguments.length; i < n; i++) {
		var a = arguments[i]
		if( isFunc(a) )
			if( a.name == null )
				throw new Error("cannot add an anonymous method (must have a name)")
			else
				Bling.prototype[a.name] = a
		else if( isObject(a) )
			Object.Extend(Bling.prototype, a)
		else
			throw new Error("can only add an object or function, not:" + typeof(a))
	}
}

Bling.module = function module(name, Module) {
	// .module(name, module) - add a bunch of functions to Bling.prototype
	var m = Module(),
		f = arguments.callee
	f.order.push(name)
	f[name] = m
	Bling.addOps(m)
}
Bling.module.order = [] // preserve the order for generating docs

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

	// used in .zip()
	function _getter(p) {
		var v
		return function() {
			v = this[p]
			return isFunc(v) ? v.bound(this) : v
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
			// .each(/f/) - applies function /f/ to every item /x/ in _this_
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
			// .map(/f/) - collects /f/.call(/x/, /x/) for every item /x/ in _this_
			var n = this.len(),
				a = Bling(n),
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
			// .reduce(/f/, [/init/]) - a = /f/(a, /x/) for /x/ in _this_
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
			// .union(/other/) - collect all /x/ from _this_ and /y/ from _other_
			// no duplicates, use concat if you want to preserve dupes
			var ret = Bling(),
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
			// .intersect(/other/) - collect all /x/ that are in _this_ and _other_
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
			/* Example:
				> $([1, 2, 3]).intersect([3, 4, 5])
				> == $([3])
			*/
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
			// .contains(/x/) - true if /x/ is in _this_, false otherwise
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
			this.each(function() {
				var t = this
				if( isObject(t) && isNumber(t) ) {
					t = Number(t)
				}
				if( t == item ) ret++
			})
			return ret
			/* Example:
				> $("body").count(document.body)
				> == 1
			*/
		},

		zip: function zip() {
			// .zip([/p/, ...]) - collects /x/./p/ for all /x/ in _this_
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
						b = Bling(), n = arguments.length, nn = this.length,
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
			// .zap(p, v) - set /x/./p/ = /v/ for all /x/ in _this_
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
			// .take([/n/]) - collect the first /n/ elements of _this_
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
			// .skip([/n/]) - collect all but the first /n/ elements of _this_
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

		first: function first(n) {
			// .first([/n/]) - collect the first [/n/] element[s] from _this_
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
			// .last([/n/] - collect the last [/n/] elements from _this_
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
			if( this.length == 0 ) return ""
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
				b = Bling(n), it = null
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
			// .matches(/expr/) - collects true if /x/.matchesSelector(/expr/) for /x/ in _this_
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
					return false;
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
				> var a = $([1, 1, 1])
				> var b = $([2, 2, 2])
				> a = a.weave(b) 
				> == $([2, 1, 2, 1, 2, 1])
				>	a.fold(function(x,y) {
				>		return x + y
				>	})
				> == $([3, 3, 3, 3])
			*/
		},

		flatten: function flatten() {
			// .flatten() - collect all /y/ in each /x/ in _this_, in depth-first order.
			var b = Bling(),
				n = this.len(), c = null, d = 0,
				i = 0, j = 0, k = 0;
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
			return Bling.symbol
				+"(["
				+this.map(function(){
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
			// .future(/n/, /f/) -  continue with /f/ on _this_ after /n/ milliseconds
			if( f ) { timeoutQueue.schedule(f.bound(this), n) }
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
				> $(b).len() === 1
				> b.length  === 10
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
			var d = document.createElement("body")
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
			Bling(x).append(this)
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
			Bling(x).prepend(this)
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
			var b = Bling(), j = -1
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
				// TODO: so... this is the first case where we slow down all browsers
				// in order to support more than just webkit... testing is needed to
				// know the true cost, .css() is a very central function
				var webkit_re = /^-webkit-/
				var setter = this.zip('style.setProperty').map(function(){
					var set = this;
					return function(k,v) {
						if( webkit_re.test(k) ) {
							set(k.replace(webkit_re, '-moz-'), v)
							set(k.replace(webkit_re, '-o-'), v)
							set(k.replace(webkit_re, ''), v)
						}
						set(k,v)
					}
				})

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
			// .defaultCss(k, [v]) - adds an inline <style> to <head>, with this.selector { k: v }
			// If k is an object of k:v pairs, then v is not required
			// Unlike, css() which applies css directly to the style attribute,
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
			return this.map(function() { return this.childNodes[n] })
		},

		children: function children() {
			// .children() - returns all children of each node
			return this.map(function() {
				return Bling(this.childNodes, this)
			})
		},

		parent: function parent() {
			// .parent() - collects the parentNode of each item in this
			return this.zip('parentNode')
		},

		parents: function parents() {
			// .parents() - collects the full ancestry up to the owner
			return this.map(function() {
				var b = Bling(), j = -1,
					p = this
				while( p = p.parentNode )
					b[++j] = p
				return b
			})
		},

		prev: function prev() {
			// .prev() - collects the full chain of .previousSibling nodes
			return this.map(function() {
				var b = Bling(), j = -1,
					p = this
				while( p = p.previousSibling )
					b[++j] = p
				return b
			})
		},

		next: function next() {
			// .next() - collects the full chain of .nextSibling nodes
			return this.map(function() {
				var b = Bling(), j = -1,
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
				.map(function() { return Bling(expr, this) })
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
			return this.map(function() {
				if( isBling(this) ) return this.floats()
				return parseFloat(this)
			})
		},

		ints: function ints() {
			// .ints() - parseInt(/x/) for /x/ in _this_
			return this.map(function() {
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
				if( isBling(this) ) return this.squares();
				return this * this
			})
		},

		magnitude: function magnitude() {
			// .magnitude() - compute the vector length of _this_
			var n = this.map(function() {
				if( isBling(this) ) return this.magnitude();
				return parseFloat(this);
			})
			return Math.sqrt(n.squares().sum())
		},

		scale: function scale(r) {
			// .scale(/r/) - /x/ *= /r/ for /x/ in _this_
			return this.map(function() {
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
		var f = null
		// eval is evil! but there is no other way to set a function's name, and the generated docs need a name
		eval("f = function "+e+"(f) { // ."+e+"([f]) - trigger [or bind] the '"+e+"' event \nreturn isFunc(f) ? this.bind('"+e+"',f) : this.trigger(e, f ? f : {}) }")
		return f
	}

	// detect and fire the document.ready event
	setTimeout(function() {
		if( Bling.prototype.trigger != null
			&& document.readyState == "complete") {
			Bling(document).trigger('ready')
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
				e = (e||"").split(comma_sep),
				n = e.length
			return this.each(function() {
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
			return this.each(function() {
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
				this.bind(e[i], function(evt) {
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
				return function(evt) {
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
			args = Object.Extend({
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
							args.touches, args.targetTouches, args.changedTouches, args.scale, args.rotation);
						break;

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
				else this.each(function() {
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
					.each(function() {
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
		keydwon: binder('keydown'),
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

	// the regex that matches all the accelerated css properties
	var accel_props_re = /(?:scale|translate|rotate|scale3d|translateX|translateY|translateZ|translate3d|rotateX|rotateY|rotateZ|rotate3d)/

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
			var duration = Bling.duration(speed),
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
					this._display = this.style.display == "none" ? undefined : this.style.display;
					this.style.display = 'none';
				}
			}).future(50, callback)
		},

		show: function show(callback) {
			// .show() - show each node
			return this.each(function() {
				if( this.style ) {
					this.style.display = this._display ? this._display : "block";
					this._display = undefined;
				}
			}).future(50, callback)
		},

		toggle: function toggle(callback) {
			// .toggle() - show each hidden node, hide each visible one
			this.weave(this.css("display"))
				.fold(function(display, node) {
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
				.show(function(){
					this.transform({opacity:"1.0", translate3d:[0,0,0]}, speed, callback)
				})
		},
		fadeOut:   function fadeOut(speed, callback, _x, _y) {
			// .fadeOut() - fade each node to opacity:0.0
			_x = _x || 0.0
			_y = _y || 0.0
			return this.each(function(t) {
				Bling(t).transform({
					opacity:"0.0",
					translate3d:[_x,_y,0.0]
				}, speed, function() { this.hide() })
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
	Object.Extend(Bling, {
		http: function http(url, opts) {
			var xhr = new XMLHttpRequest()
			if( isFunc(opts) )
				opts = {success: opts.bound(xhr)}
			opts = Object.Extend({
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
			return this.transaction(function(t) {
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

	var type_re = /([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/

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
	compile.cache = {}

	function _render(text, values) {
		// get the cached compiled version
		var cache = compile.cache[text]
			|| (compile.cache[text] = compile(text)),
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
			switch( type ) {
				case 'd':
					output[j++] = "" + parseInt(value)
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
	Bling.render = _render

	// modes for the synth machine
	var TAGMODE = 1, IDMODE = 2, CLSMODE = 3, ATTRMODE = 4, VALMODE = 5, DTEXTMODE = 6, STEXTMODE = 7

	function synth(expr) {
		var tagname = '', id = '', cls = '', attr = '', val = '',
			text = '', attrs = {}, parent = null, mode = TAGMODE,
			ret = $([]), i = 0, c = null
		parent = null
		function emitText() {
			node = document.createTextNode(text)
			if( parent )
				parent.appendChild(node)
			else
				ret.push(node)
			text = ''
			mode = TAGMODE
		}
		function emitNode() {
			node = document.createElement(tagname)
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

		while( (c = expr.charAt(i++)) ) {
			if( c == '+' && mode == TAGMODE)
				parent = parent ? parent.parentNode : parent
			else if( c == '#' && (mode == TAGMODE || mode == CLSMODE || mode == ATTRMODE) )
				mode = IDMODE
			else if( c == '.' && (mode == TAGMODE || mode == IDMODE || mode == ATTRMODE) )
				mode = CLSMODE
			else if( c == '[' && (mode == TAGMODE || mode == IDMODE || mode == CLSMODE || mode == ATTRMODE) )
				mode = ATTRMODE
			else if( c == '=' && (mode == ATTRMODE))
				mode = VALMODE
			else if( c == '"' && mode == TAGMODE)
				mode = DTEXTMODE
			else if( c == "'" && mode == TAGMODE)
				mode = STEXTMODE
			else if( c == ']' && (mode == ATTRMODE || mode == VALMODE) ) {
				attrs[attr] = val
				attr = ''
				val = ''
				mode = TAGMODE
			}
			else if( c == '"' && mode == DTEXTMODE )
				emitText()
			else if( c == "'" && mode == STEXTMODE )
				emitText()
			else if( (c == ' ' || c == ',') && (mode != VALMODE && mode != ATTRMODE) && tagname.length > 0 )
				emitNode()
			else if( mode == TAGMODE )
				tagname += c != ' ' ? c : ''
			else if( mode == IDMODE ) id += c
			else if( mode == CLSMODE ) cls += c
			else if( mode == ATTRMODE ) attr += c
			else if( mode == VALMODE ) val += c
			else if( mode == DTEXTMODE || mode == STEXTMODE ) text += c
			else throw new Error("Unknown input/state: '"+c+"'/"+mode)

		}

		if( tagname.length > 0 )
			emitNode()

		if( text.length > 0 )
			emitText()

		return ret
	}
	Bling.synth = synth

	return {
		template: function template(defaults) {
			// .template([defaults]) - mark nodes as templates, add optional defaults to .render()
			// if defaults is passed, these will be the default values for v in .render(v)
			defaults = Object.Extend({
			}, defaults)
			// over-ride the basic .render() with one that applies these defaults
			this.render = function(args) {
				return _render(this.map(Bling.HTML.stringify).join(''), Object.Extend(defaults,args))
			}

			return this.remove() // the template item itself should not be in the DOM
		},

		render: function render(args) {
			// .render(args) - replace %(var)s-type strings with values from args
			// accepts nodes, returns a string
			return _render(this.map(Bling.HTML.stringify).join(''), args)
		},

		synth: function synth(expr) {
			// .synth(expr) - create DOM nodes to match a simple css expression
			// supports the following css selectors:
			// tag, #id, .class, [attr=val]
			// and the additional helper "text"
			return synth(expr).appendTo(this)

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

