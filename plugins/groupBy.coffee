$.plugin
	provides: "groupBy"
	depends: "type"
, ->
	groupBy: (key) ->
		groups = {}
		switch $.type key
			when 'array','bling'
				@each ->
					c = (@[k] for k in key).join ","
					(groups[c] or= $()).push @
			else @each -> (groups[@[key]] or= $()).push @
		return $.valuesOf groups
