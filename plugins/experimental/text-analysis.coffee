require "./dist/bling"

len = (o) -> o?.length | 0

indices = $.memoize (str, substr) ->
	# $.log "indices(..., #{substr})"
	switch len(substr)
		when 0 then $.range 0, len(str)
		when 1
			i = -1
			i while (i = str.indexOf substr, i+1) > -1
		else
			subsub = substr[0...len(substr)-1]
			indices(str, subsub).filter (x) -> str.indexOf(substr,x) is x

commonSubstrings = (a,b,min_length=3,limit=10) ->
	a = a.toLowerCase()
	b = b.toLowerCase()
	ret = {}
	for i in [0...len(b)]
		for j in [0...len(b)]
			if (j - i) < min_length-1 then continue
			c = b[i..j]
			if len(indices a,c) > 0
				ret[c] = 1
	return Object.keys(ret).sort((x,y) -> len(y) - len(x))[0...limit]

a = "The quick brown dog jumped over the lazy red fox."
b = "Jumper pumped the quick fake, and jumped toward the basket."
$.log commonSubstrings(a, b, 3, 10)

ld = $.memoize (s, t) ->
	switch true
		when not s then len(t)
		when not t then len(s)
		when s is t then 0
		when s[0] is t[0] then ld(s[1..],t[1..])
		else 1 + Math.min(
			ld(s, t[1..]),
			ld(s[1..], t),
			ld(s[1..], t[1..])
		)

$.log ld "kitten", "sitting"

