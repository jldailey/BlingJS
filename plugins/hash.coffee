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
			$.hash(Object) +
				$($.hash(k) + $.hash(v) for k,v of o).sum()
		}
		array:   { hash: (o) ->
			$.hash(Array) + $(o.map $.hash).reduce(((a,x) -> ((a*a)+(x|0)) % maxHash), 1)
		}
		bool:    { hash: (o) -> parseInt(1 if o) }
	return {
		$:
			hash: (x) -> $.type.lookup(x).hash(x)
		hash: -> $.hash @
	}
