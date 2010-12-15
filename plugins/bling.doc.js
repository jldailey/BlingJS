(function($) {

	Function.PrettyPrint = (function() {
		// closure scope:
		var operators = /!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g,
			keywords = /\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g,
			singleline_comment = /\/\/.*?(?:\n|$)/,
			multiline_comment = /\/\*(?:.|\n)*?\*\//,
			all_numbers = /\d+\.*\d*/g,
			bling_symbol = /\$(?:\(|\.)/g
		function find_unescaped_quote(s, i, q) {
			var r = s.indexOf(q, i)
			while( s.charAt(r-1) === "\\" && r < s.length && r > 0)
				r = s.indexOf(q, r+1)
			return r
		}
		function find_first_quote(s, i) {
			var a = s.indexOf('"', i),
				b = s.indexOf("'", i)
			if( a === -1 ) a = s.length
			if( b === -1 ) b = s.length
			return a === b ? [null, -1]
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
				if( j === -1 ) {
					ret.push(s.substring(i))
					break
				}
				ret.push(s.substring(i,j))
				k = find_unescaped_quote(s, j+1, q[0])
				if( k === -1 )
					throw Error("unmatched "+q[0]+" at "+j)
				ret.push(s.substring(j, k+1))
				i = k+1
			}
			return ret
		}
		function first_comment(s) {
			var a = s.match(singleline_comment),
				b = s.match(multiline_comment)
				return a === b ? [-1, null]
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
				throw TypeError("prettyPrint requires a function or string to format, not '"+typeof(js)+"'")
			if( Bling("style#pp-injected").length === 0 ) {
				var i, css = "code.pp .bln { font-size: 17px; } "
				colors = Object.Extend({
					opr: "#880",
					str: "#008",
					com: "#080",
					kwd: "#088",
					num: "#808",
					bln: "#800"
				}, colors)
				for( i in colors )
					css += "code.pp ."+i+" { color: "+colors[i]+"; }"
				Bling("head").append(Bling.synth("style#pp-injected").text(css))
			}
			return "<code class='pp'>"+
				// extract comments
				Bling(extract_comments(js))
					.fold(function(text, comment) {
						// extract quoted strings
						return Bling(extract_quoted(text))
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

	var example_re = /\s*[Ee]xample:\s*/,
		end_line = /\n/g,
		code_line = /(^|\n)\s*\&gt;\s/,
		blank_line = /^\s*$/,
		singleline_comment = /^\/\/ */,
		multiline_comment_open = /^\/\* */,
		multiline_comment_close = /\s*\*\/\s*$/,
		b_word = /\/(\w+)\//g,
		i_word = /_(\w+)_/g

	function getDescription(node) {
		// return a pair of [definition, description] strings
		var desc = node.find(".com").take(1).text().first();
		desc = desc ? desc
			.replace(singleline_comment,'')
			.replace(b_word, "<b>$1</b>")
			.replace(i_word, "<i>$1</i>")
			: "unknown - unknown"
		return desc.split(" - ")
	}
	function getExamples(node) {
		// return a list of [<p>, <pre>, <p>, <pre>, ...]
		var examples = node.find(".com").skip(1).html(),
			result = $([]), codeQueue = [], paraQueue = [],
			i = 0, j = 0, n = examples.length, example = null
			lines = null, line = null

		paraQueue.flush = function() {
			if( this.length > 0 ) {
				result.push($.synth("p").text(this.join("\n")))
				this.length = 0
			}
			return this.length == 0
		}

		codeQueue.flush = function() {
			if( this.length > 0 ) {
				result.push($.synth("pre")
					.html(Function.PrettyPrint(codeQueue.join('\n'))))
				this.length = 0
			}
			return this.length == 0
		}

		while( (example = examples[i++]) != null ) {
			if( example_re.test(example) ) {
				lines = example.split(end_line)
				j = 0
				while( (line = lines[j++]) != null ) {
					if( code_line.test(line) ) {
						codeQueue.push(line.replace(code_line, '$1'))
						paraQueue.flush()
					}
					else if ( ! blank_line.test(line) ) {
						paraQueue.push(line.replace(/\/\*/g,"").replace(/\*\//g,""))
						codeQueue.flush()
					} 
					else if( codeQueue.flush() ) { }
					else { paraQueue.flush() }
				}
			}
		}
		if( codeQueue.length > 0 )
			result.push($(Function.PrettyPrint(codeQueue.join('\n'))))
		if( paraQueue.length > 0 )
			result.push($("<p>").html(paraQueue.join('\n')))
		return result.flatten()
	}


	function walk(name, x, visit) {
		var keys = Object.Keys(x),
			i = 0, n = keys.length,
			key = null, val = null
		for(; i < n; i++) {
			key = keys[i],
			val = x[key]

			if( isObject(val) ) {
				// recurse
				arguments.callee(key.charAt(0) == '$' ? 'Bling.' + key.substr(1) : name + "." + key, val, visit)
			} else if( isFunc(val) ) {
				visit(key.charAt(0) == '$' ? 'Bling.' + key.substr(1) : name + "." + key, val)
			}
		}
	}

	$.plugin(function Doc() {
		return {
			$doc: {
				module: function (name, func_template) {
					var ret = $([])
					if( ! func_template )
						func_template = $.synth("li a[href=api:%(reference)s] '%(definition)s' + div '%(description)s' + div '%(examples)s'")
					walk("Bling.prototype", Bling.plugin.s[name], function visit(name, f) {
						var text = Function.PrettyPrint(f),
							nodes = $(text),
							examples = getExamples(nodes),
							description = getDescription(nodes),
							output = func_template.render({
								reference: name.replace("Bling.prototype.","").replace("Bling.",""),
								definition: description[0],
								description: description[1],
								examples: examples.map($.HTML.stringify).join("")
							})
						ret.push($(output))
					})
					return ret
				}
			}
		}
	})


})(Bling)

