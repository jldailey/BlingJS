$.plugin
	depends: "core"
	provides: "diff"
, ->
	lev_memo = Object.create null
	lev = (s,i,n,t,j,m) ->
		# distance is symmetric so we cache under two keys at once
		return lev_memo[[s,i,n,t,j,m]] ?= lev_memo[[t,j,m,s,i,n]] ?= do -> switch true
			when m <= 0 then n
			when n <= 0 then m
			else Math.min(
				1 + lev(s,i+1,n-1, t,j,m),
				1 + lev(s,i,n, t,j+1,m-1),
				(s[i] isnt t[j]) + lev(s,i+1,n-1, t,j+1,m-1)
			)
	
	collapse = (ops) -> # combines similar operations in a sequence
		$.inherit {
			toHTML: ->
				@reduce(((a,x) ->
					a += switch x.op
						when 'ins' then "<ins>#{x.v}</ins>"
						when 'del' then "<del>#{x.v}</del>"
						when 'sub' then "<del>#{x.v}</del><ins>#{x.w}</ins>"
						when 'sav' then x.v
				), "")
		}, ops.reduce(((a,x) ->
			if x.op is 'sub' and x.v is x.w # replacing with the same thing is just preserving
				x.op = 'sav'
				delete x.w
			unless a.length
				a.push x
			else
				if (last = a.last()).op is x.op
					last.v += x.v
					if last.op is 'sub'
						last.w += x.w
				else
					a.push x
			return a
		), $())


	diff_memo = Object.create null
	del = (c) -> {op:'del',v:c}
	ins = (c) -> {op:'ins',v:c}
	sub = (c,d) -> {op:'sub',v:c,w:d}
	diff = (s,i,n,t,j,m) ->
		# diffs are not symmetric, so only cache under one key
		return diff_memo[[s,i,n,t,j,m]] ?= collapse do -> switch true
			when m <= 0 then (del(c) for c in s.substr i,n)
			when n <= 0 then (ins(c) for c in t.substr j,m)
			else
				cost = (s[i] isnt t[j])
				costs =
					del: 1 + lev s,i+1,n-1, t,j,m
					ins: 1 + lev s,i,n, t,j+1,m-1
					sub: cost + lev s,i+1,n-1, t,j+1,m-1
				switch Math.min costs.del, costs.ins, costs.sub
					when costs.del then $(del s[i]).concat diff s,i+1,n-1, t,j,m
					when costs.ins then $(ins t[j]).concat diff s,i,n, t,j+1,m-1
					when costs.sub then $(sub s[i],t[j]).concat diff s,i+1,n-1, t,j+1,m-1

	$:
		stringDistance: (s, t) -> lev s,0,s.length, t,0,t.length
		stringDiff: (s, t) -> diff s,0,s.length, t,0,t.length

