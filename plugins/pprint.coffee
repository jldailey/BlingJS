(($) ->
	$.plugin () -> # Pretty Print plugin
		operators = /!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g
		operator_html = "<span class='opr'>$&</span>"
		keywords = /\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g
		keyword_html = "<span class='kwd'>$&</span>"
		all_numbers = /\d+\.*\d*/g
		number_html = "<span class='num'>$&</span>"
		bling_symbol = /\$(\(|\.)/g
		bling_html = "<span class='bln'>$$</span>$1"
		tabs = /\t/g
		tab_html = "&nbsp;&nbsp;"
		singleline_comment = /\/\/.*?(?:\n|$)/
		multiline_comment = /\/\*(?:.|\n)*?\*\//
		comment_html = (comment) ->
			if comment then "<span class='com'>#{comment}</span>" else ""
		quoted_html = (quoted) ->
			if quoted then "<span class='str'>#{quoted}</span>" else ""

		first_quote = (s, i) -> # return the type of quote and its first index (after i)
			a = s.indexOf('"', i)
			b = s.indexOf("'", i)
			# move pointers to the end if no quotes were found
			a = s.length if a is -1
			b = s.length if b is -1
			# a is b only when they both missed (o.w. how could we find two diff. chars at the same index?)
			return [null, -1] if a is b
			# 
			return ['"', a] if a < b
			return ["'", b]
		closing_quote = (s, i, q) -> # find the closing quote
			r = s.indexOf(q, i)
			while( s.charAt(r-1) is "\\" and 0 < r < s.length)
				r = s.indexOf(q, r+1)
			r
		split_quoted = (s) -> # splits a string into a list where even items were inside quoted strings, odd items were unquoted
			i = 0
			n = s.length
			ret = []
			if not Object.IsString(s)
				if not Object.IsFunc(s.toString)
					throw TypeError("invalid string argument to split_quoted")
				else
					s = s.toString()
					n = s.length
			while( i < n )
				q = first_quote(s, i)
				j = q[1]
				if( j is -1 )
					ret.push(s.substring(i))
					break
				ret.push(s.substring(i,j))
				k = closing_quote(s, j+1, q[0])
				if( k is -1 )
					throw Error("unclosed quote: "+q[0]+" starting at "+j)
				ret.push(s.substring(j, k+1))
				i = k+1
			ret

		first_comment = (s) ->
			a = s.match(singleline_comment)
			b = s.match(multiline_comment)
			return [-1, null] if a is b
			return [b.index, b[0]] if a == null and b != null
			return [a.index, a[0]] if a != null && b == null
			return [b.index, b[0]] if b.index < a.index
			return [a.index, a[0]]

		split_comments = (s) ->
			ret = []
			i = 0
			n = s.length
			while( i < n )
				ss = s.substring(i)
				q = first_comment(ss)
				j = q[0]
				if( j > -1 )
					ret.push(ss.substring(0,j))
					ret.push(q[1])
					i += j + q[1].length
				else
					ret.push(ss)
					break
			ret

		return {
			name: "PrettyPrint"
			$:
				prettyPrint: (js, colors) ->
					js = js.toString() if Object.IsFunc(js)
					if not Object.IsString(js)
						throw TypeError("prettyPrint requires a function or string to format, not '"+Object.Type(js)+"'")
					if $("style#prettyPrint").length is 0
						css = "code.pp .bln { font-size: 17px; } "
						colors = Object.Extend(
							opr: "#880"
							str: "#008"
							com: "#080"
							kwd: "#088"
							num: "#808"
							bln: "#800"
						, colors)
						for cls of colors
							css += "code.pp .#{cls} { color: #{colors[cls]}; } "
						$.synth("style#prettyPrint")
							.text(css)
							.appendTo("head")
					ret = "<code class='pp'>" +
						($(split_comments(js)).fold (text, comment) ->
								$(split_quoted(text)).fold (code, quoted) ->
									code.replace(operators, operator_html).replace(all_numbers, number_html).replace(keywords, keyword_html).replace(bling_symbol, bling_html).replace(tabs, tab_html) + quoted_html(quoted)
							.join('') + comment_html(comment)
						.join('')) + "</code>"
		}

)(Bling)
# vim: ft=coffee
