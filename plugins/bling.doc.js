(function($) {
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

	$.module("Doc", function() {
		return {
			$doc: {
				module: function (name, func_template) {
					var ret = $([])
					if( ! func_template )
						func_template = $.synth("li a[href=api:%(reference)s] '%(definition)s' div '%(description)s' div '%(examples)s'")
					walk("Bling.prototype", Bling.module[name], function visit(name, f) {
						var text = Function.PrettyPrint(f),
							nodes = $(text),
							examples = getExamples(nodes),
							description = getDescription(nodes),
							output = func_template.render({
								reference: name,
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

