
// define the bling operator
var $ = function(expr) {
	if( typeof(expr) == "string" ) {
		var q = document.querySelectorAll(expr);
		var a = new Array(q.length);
		for( var i = 0; i < q.length; i++ ) {
			a[i] = q[i];
		}
		return a;
	} else if( expr && expr.each ) {
		return expr;
	} else if( expr ) {
		return [ expr ];
	} else {
		return [];
	}
}

// quick way to add extension methods to an object
$.extend = function(a, b) {
	for( var i in b ) {
		a.__proto__[i] = b[i];
	}
}

// human readable view of an object
$.dump = function(obj, indent) {
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
			s += indent + k + ":" + " " + $.dump(v, indent) + ",\n";
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

// add some utils to all querySelector results (NodeLists)
$.extend($(), // grab a dummy result set, so we can extend it's prototype
{
	// keep track of our own length, so we can use different container types if needed
	len: function(l) {
		if( l == undefined )
			return this.length;
		this.length = l;
		return this;
	},

	/// Bling !! ///

	// define a functional basis: each, map, and reduce
	each: function(f) {
		for( var i = 0; i < this.len(); i++) {
			f.call(this[i]);
		}
		return this;
	},
	map: function(f) {
		var a = new Array();
		for( var i = 0; i < this.len(); i++) {
			a[i] = f.apply(this[i], [this[i]]);
		}
		return a;
	},
	reduce: function(f) {
		var accum = undefined;
		for( var i = 0; i < this.len(); i++) {
			accum = f.call(this[i], accum);
		}
		return accum;
	},

	// then define some common functional tools

	// zip(p) returns a list of the values of property p from each node
	zip: function(p) { return this.map(function() { return this[p] }); },
	// zap(p, v) sets property p to value v on all nodes in the list
	zap: function(p, v) { return this.each(function() { this[p] = v }); },
	// take(n) trims the list to only the first n elements
	take: function(n) { return this.len(Math.min(n,this.len())); }, // could be more careful, and 'undefine' out-of-bounds
	// skip(n) skips the first n elements in the list
	skip: function(n) { // could be faster
		// copy each item left n spaces
		for( var i = 0; i < this.len(); i++) {
			this[i] = this[i+n];
		}
		// reduce the length by n
		return this.len(Math.max(0, this.len() - n));
	},
	// join all elements into a sep-separated string
	join: function(sep) {
		return this.reduce(function(j) {
			return (j ? j + sep: "") + this;
		});
	},
	// slice(start, end) returns a contiguous subset of elements
	// the end-th item will not be included - the slice(0,2) will contain items 0, and 1.
	slice: function(start, end) { return this.take(end).skip(start); },
	// mash takes the given array and interleaves it in this array
	mash: function(a) {
		// first spread out this list, from back to front
		for(var i = this.len() - 1; i >= 0; i-- ) {
			this[(i*2)+1] = this[i];
		}
		// then interleave the source items, from front to back
		for(var i = 0; i < a.len(); i++) {
			this[i*2] = a[i];
		}
		return this;
	},

	// various common ways to reduce things
	max: function() {
		return this.reduce(function(x) {
			var p = parseFloat(this);
			x = x || 0;
			return p > x ? p : x;
		})
	},
	min: function() {
		return this.reduce(function(x) {
			var p = parseFloat(this);
			x = x || Math.pow(2,32);
			return p < x ? p : x;
		})
	},
	average: function() {
		var ret = this.reduce(function(x) {
			return [ (x ? x[0] : 0) + parseFloat(this), (x ? x[1] : 0) + 1 ];
		});
		return ret[0] / ret[1];
	},

	// try to continue with f in the same scope after about n milliseconds
	future: function(n, f) {
		var t = this;
		if( f )
			setTimeout(function() { f.call(t); }, n);
		return this;
	},


	/// DOM Manipulation ///
	// some basic jquery-like manipulations defined with the functional primitives

	// get/set the .innerHTML of all elements in list
	html: function(h) { return h ? this.zap('innerHTML', h) : this.zip('innerHTML') },
	// get/set the .innerText of all elements
	text: function(t) { return t ? this.zap('innerText', t) : this.zip('innerText') },
	// get/set the values of the nodes in the list
	val: function(v) { return v ? this.zap('value', v) : this.zip('value') },
	// css gets/sets css properties for every node in the list
	css: function(k,v) { 
		return v ? this.each(function() { this.style.setProperty(k, v); })
			: this.map(function() { return this.style.getPropertyValue(k) })
	},
	// bind an event handler, evt is a string, like 'click'
	bind: function(evt, f) {
		return this.each(function() {
			this.addEventListener(evt, f);
		})
	},
	// unbind an event handler, f is optional, evt is a string, like 'click'.
	unbind: function(evt, f) {
		return this.each(function() {
			this.removeEventListener(evt, f);
		})
	},


	/// Animations ///

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

	height: function() {
		return this.zip('scrollHeight').average();
	},
	width: function() {
		return this.zip('scrollWidth').average();
	},

});

