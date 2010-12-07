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
				result.push($.synth("p").text(this.join("\n"))
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
		return result
	}

	function generateModuleDocs(name, module, template) {
		var ul = $.synth("ol.apilist[module="+name+"]")
		for( var k in module ) {
			var source = $(Function.PrettyPrint(module[k]))
				desc = getDescription(source),
				examples = getExamples(source)
			ul.append(template.render({
				reference: k, 
				definition: desc[0], 
				description: desc[1]
			}))
			.find("li")
			.last(1)
			.append(examples)
		}
		ul.find("a").cycle('click', function() {
			var $this = $(this),
				name = $this.attr('name').first(),
				func = eval("Bling.prototype."+name),
				source = getSource(func)
			source.find(".com").filter(function() {
				return this.innerText.indexOf("Example:") > -1
			}).remove()
			$this.parent()
				.append("<h6>Implementation:</h6>")
				.append(source)
				.find("h6, h6 + pre").click(function () {
					$(this).parent().find("h6, pre").remove()
				})
			return false
		}, function() {
			var $this = $(this)
			$this.parent().find("h6, h6 + pre").remove()
		})
		return ul
	}

	$.doc = function doc(x) {
		// .doc(/x/) - generate doc html, /x/ is function or module object
	}

	$.doc.module = function (m) {
	}

	$.doc.func = function (f) {
	}

})(Bling)

