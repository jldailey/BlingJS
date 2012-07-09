(($) ->
	$.plugin
		provides: "cartesian"
	, ->
		$:
			cartesian: (sets...) ->
				n = sets.length
				ret = []
				helper = (cur, i) ->
					(return ret.push cur) if ++i >= n
					for x in sets[i]
						helper (cur.concat x), i
					null
				helper [], -1
				return $(ret)

	###
	if require.main is module
		require "../bling"
		console.log $.cartesian(
			[2,3,4,5],
			['sweet','ugly'],
			['cats','dogs','hogs']
		).map( -> @join " " )
		.join "\n"
	###
)(Bling)
