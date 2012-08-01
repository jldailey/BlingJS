require "../../dist/bling"

do ($ = Bling) ->

	$.plugin
		provides: "text-analysis"
	, ->
		indices = $.memoize (str, substr) ->
			switch substr.length
				when 0 then $.range 0, str.length
				when 1
					i = -1
					i while (i = str.indexOf substr, i+1) > -1
				else
					subsub = substr[0...substr.length-1]
					indices(str, subsub).filter (x) -> str.indexOf(substr,x) is x

		ld = $.memoize (s, t) ->
			switch true
				when not s then t.length
				when not t then s.length
				when s is t then 0
				when s[0] is t[0] then ld s[1..],t[1..]
				else 1 + Math.min(
					ld(s, t[1..]),
					ld(s[1..], t),
					ld(s[1..], t[1..])
				)

		commonSubstrings = (a,b,min_length=1,limit=1) ->
			a = a.toLowerCase()
			b = b.toLowerCase()
			ret = {}
			for i in [0...b.length]
				for j in [0...b.length]
					if (j - i) < min_length-1 then continue
					c = b[i..j]
					if (indices a,c).length > 0
							ret[c] = 1
			$(Object.keys ret)
				.sort((x,y) -> y.length - x.length)
				.take(limit)

		$:
			stringDistance: ld
			stringsInCommon: commonSubstrings

