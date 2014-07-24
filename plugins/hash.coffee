# Hash plugin
# -----------
# `$.hash(o)` Reduces any thing to an integer hash code (not secure).
$.plugin
	provides: "hash"
	depends: "type"
, ->
	maxHash = Math.pow(2,32)
	$.type.extend
		unknown: { hash: (o) -> $.checksum $.toString o }
		object:  { hash: (o) ->
			1970931729 + # $.hash(Object)
				$($.hash(k) + $.hash(v) for k,v of o).sum()
		}
		array:   { hash: array_hash = (o) ->
			1816922041 + # $.hash(Array)
				$($.hash(x) for x in o).reduce(((a,x) -> ((a*a)+(x|0)) % maxHash), 1)
		}
		arguments: { hash: (o) ->
			298517431 + # $.hash('Arguments')
				array_hash o
		}
		bool:    { hash: (o) -> parseInt(1 if o) }
	return {
		$:
			hash: (x) ->
				$.type.lookup(x).hash(x)
		hash: -> $.hash @
	}
