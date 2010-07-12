/* bling.js
 * --------
 * Named after the bling! operator ($), this is a jQuery-like framework,
 * using any and all WebKit specific hacks that we can.
 * All other browsers play at your own risk.
 */

Function.prototype.inheritsFrom = function(b) {
	this.prototype = new b();
	this.prototype.constructor = this;
}

var $ = (function() {
	function Bling(expr, context) {
		context = context || document;
		if( typeof(expr) == "string" ) {
			if( expr[0] == "<" ) {
				var d = document.createElement("div");
				d.innerHTML = expr;
				console.log("d",d);
				Array.apply(this, [d.childNodes.length]);
				for( var i = 0; i < d.childNodes.length; i++ ) {
					this.push( d.childNodes[i] )
				}
			} else {
				var q = context.querySelectorAll(expr);
				Array.apply(this, [q.length]);
				for( var i = 0; i < q.length; i++ ) {
					this.push( q[i] )
				}
			}
		} else if( typeof(expr) == "number" ) {
			Array.apply(this, [expr]);
		} else if( expr ) {
			if( expr.__proto__.constructor == Bling )
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
	Bling.inheritsFrom(Array);
	Bling.version = "0.0";

	Bling.dump = function(obj, indent) {
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
				s += indent + k + ":" + " " + Bling.dump(v, indent) + ",\n";
			}
			indent = indent.slice(1);
			s += indent + "}";
		} else if( typeof(obj) == "string" ) {
			s += indent + '"' + obj + '"';
		} else if( typeof(obj) == "function" ) {
			var t = "" + obj;
			s += t.slice(0, t.indexOf("\n")) + " ... }";
		} else {
			s += "" + obj;
		}
		return s.replace(/(?:\r|\n)+/g,"<br>").replace(/\t/g,"&nbsp;&nbsp;");
	}

	Bling.rgb = function(expr) { // accepts any color in css format
		// returns a 3-item bling with the floating point rgb values
		var d = document.createElement("div");
		d.style.color = expr;
		var rgb = d.style.getPropertyValue('color');
		if( rgb )
			return new Bling( rgb.slice(rgb.indexOf('(')+1, rgb.indexOf(')')) .split(", ")).floats()
		return new Bling();
	}

	Bling.extend = function(a, b) {
		for( var i in b ) {
			a[i] = b[i];
		}
	}

	Bling.plugins = [];
	Bling.plugin = function (name, methods) { 
		if( Bling.plugins.indexOf(name) == -1 ) {
			Bling.plugins.push(name);
			Bling.extend(Bling.prototype, methods);
		}
	}

	Bling.plugin("core", /// Core ///
	{

		// define a functional basis: each, map, and reduce
		// these act like the native forEach, map, and reduce, except they respect the context of the Bling
		// so the 'this' value in the callback f is always set to the item being processed
		each: function(f) {
			this.forEach(function(t) {
				f.call(t, t);
			});
			return this;
		},
		map: function(f) {
			return new Bling(Array.prototype.map.call(this, function(t) {
				return f.call(t, t);
			}));
		},
		reduce: function(f) {
			// along with respecting the context, we pass only the accumulation + 1 item
			// so you can use functions like Math.min directly $(numbers).reduce(Math.min)
			// this fails with the default reduce, since Math.min(a,x,i,items) is NaN
			return Array.prototype.reduce.call(this, function(a, x) {
				return f.apply(x, [a, x]);
			})
		},

		// zip(p) returns a list of the values of property p from each node
		zip: function(p) { return this.map(function() { return this[p] }); },
		// zap(p, v) sets property p to value v on all nodes in the list
		zap: function(p, v) { return this.each(function() { this[p] = v }); },
		// take(n) trims the list to only the first n elements
		take: function(n) {
			var a = new Bling(Math.min(n, this.length));
			for( var i = 0; i < a.length; i++) {
				a[i] = this[i]
			}
			return a;
		},
		// skip(n) skips the first n elements in the list
		skip: function(n) {
			var a = new Bling(Math.max(0,this.length - n));
			for( var i = 0; i < this.length - n; i++)
				a.push(this[i+n])
			return a;
		},
		// join all elements into a sep-separated string
		join: function(sep) {
			return this.reduce(function(j) {
				return j + sep + this;
			});
		},
		// slice(start, end) returns a contiguous subset of elements
		// the end-th item will not be included - the slice(0,2) will contain items 0, and 1.
		slice: function(start, end) { return this.take(end).skip(start); },
		// mash takes the given array and interleaves it in this array
		mash: function(a) {
			var b = new Bling(this.length + a.length);
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
		},

		// various common ways to map/reduce things
		floats:    function()  { return this.map(parseFloat) },
		ints:      function()  { return this.map(parseInt) },
		squares:   function()  { return this.map(function() { return this * this })},
		sum:       function()  { return this.reduce(function(x) { return x + this })},
		max:       function()  { return this.reduce(Math.max) },
		min:       function()  { return this.reduce(Math.min) },
		average:   function()  { return this.sum() / this.length },
		magnitude: function()  { return Math.sqrt(this.squares().sum()) },
		scale:     function(n) { return this.map(function() { return n * this })},

		// returns a css color string
		rgb: function() {
			if( this.length == 4 )
				return "rgba("+this.join(", ")+")"
			else if( this.length == 3 )
				return "rgb("+this.join(", ")+")"
			// else return undefined
		},

		// try to continue using f in the same scope after about n milliseconds
		future: function(n, f) {
			var t = this;
			if( f ) setTimeout(function() { f.call(t); }, n);
			return this;
		},

	})

	Bling.plugin("dom", /// DOM Manipulation ///
	{
		// get/set the .innerHTML of all elements in list
		html: function(h) { return h ? this.zap('innerHTML', h) : this.zip('innerHTML') },
		// get/set the .innerText of all elements
		text: function(t) { return t ? this.zap('innerText', t) : this.zip('innerText') },
		// get/set the values of the nodes in the list
		val: function(v) { return v ? this.zap('value', v) : this.zip('value') },
		height: function() { return this.zip('scrollHeight').max(); },
		width: function() { return this.zip('scrollWidth').max(); },
		// css gets/sets css properties for every node in the list
		css: function(k,v) { 
			return v ? this.each(function() { this.style.setProperty(k, v); })
				: this.map(function() { return this.style.getPropertyValue(k) })
		},
		// bind an event handler, evt is a string, like 'click'
		bind: function(evt, f) {
			console.log("bind", this, this.each, evt, f);
			return this.each(function() {
				console.log(this.addEventListener, evt, f);
				this.addEventListener(evt, f, false);
			})
		},
		// unbind an event handler, f is optional, evt is a string, like 'click'.
		unbind: function(evt, f) {
			return this.each(function() {
				this.removeEventListener(evt, f);
			})
		},
	})

	Bling.plugin("transform", /// Transformations and Animations ///
	{
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
		},

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

	// the operator we will give out publicly will handle everything
	// i.e., the constructor $(nodes), etc
	var operator = function(e,c) { return new Bling(e,c); }
	// all the static methods like $.dump
	Bling.extend(operator, Bling);
	// if you want to add more functionality, anyone can use $.plugin(name, methods) to add more
	return operator;
})()
