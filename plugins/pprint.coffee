(($) ->
	$.plugin () -> # Pretty Print plugin
		operators = /!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g
		operatorHtml = "<span class='opr'>$&</span>"
		keywords = /\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g
		keywordHtml = "<span class='kwd'>$&</span>"
		allNumbers = /\d+\.*\d*/g
		numberHtml = "<span class='num'>$&</span>"
		blingSymbol = /\$(\(|\.)/g
		blingHtml = "<span class='bln'>$$</span>$1"
		tabs = /\t/g
		tabHtml = "&nbsp;&nbsp;"
		singlelineComment = /\/\/.*?(?:\n|$)/
		multilineComment = /\/\*(?:.|\n)*?\*\//
		commentHtml = (comment) ->
			if comment then "<span class='com'>#{comment}</span>" else ""
		quotedHtml = (quoted) ->
			if quoted then "<span class='str'>#{quoted}</span>" else ""

		firstQuote = (s, i) -> # return the type of quote and its first index (after i)
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
		closingQuote = (s, i, q) -> # find the closing quote
			r = s.indexOf(q, i)
			while( s.charAt(r-1) is "\\" and 0 < r < s.length)
				r = s.indexOf(q, r+1)
			r
		splitQuoted = (s) -> # splits a string into a list where even items were inside quoted strings, odd items were unquoted
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
				q = firstQuote(s, i)
				j = q[1]
				if( j is -1 )
					ret.push(s.substring(i))
					break
				ret.push(s.substring(i,j))
				k = closingQuote(s, j+1, q[0])
				if( k is -1 )
					throw Error("unclosed quote: "+q[0]+" starting at "+j)
				ret.push(s.substring(j, k+1))
				i = k+1
			ret

		firstComment = (s) ->
			a = s.match(singlelineComment)
			b = s.match(multilineComment)
			return [-1, null] if a is b
			return [b.index, b[0]] if a == null and b != null
			return [a.index, a[0]] if a != null && b == null
			return [b.index, b[0]] if b.index < a.index
			return [a.index, a[0]]

		splitComments = (s) ->
			ret = []
			i = 0
			n = s.length
			while( i < n )
				ss = s.substring(i)
				q = firstComment(ss)
				j = q[0]
				if( j > -1 )
					ret.push(ss.substring(0,j))
					ret.push(q[1])
					i += j + q[1].length
				else
					ret.push(ss)
					break
			ret

		foldCodeAndQuoted = (code, quoted) ->
			code.replace(operators, operatorHtml).replace(allNumbers, numberHtml).replace(keywords, keywordHtml).replace(blingSymbol, blingHtml).replace(tabs, tabHtml) + quotedHtml(quoted)

		foldTextAndComments = (text, comment) ->
			$(splitQuoted(text)).fold(foldCodeAndQuoted).join('') + commentHtml(comment)

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
					ret = "<code class='pp'>" + ($(splitComments(js)).fold(foldTextAndComments).join('')) + "</code>"
		}

)(Bling)
# vim: ft=coffee
