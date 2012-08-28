# Hash plugin
# -----------
# `$.hash(o)` Reduces any thing to an integer hash code (not secure).
$.plugin
	provides: "hash"
	depends: "type"
, ->
	$.type.extend
		unknown: { hash: (o) -> $.checksum $.toString o }
		object:  { hash: (o) ->
			$.hash(Object) +
				$($.hash(o[k]) for k of o).sum() +
				$.hash Object.keys o
		}
		array:   { hash: (o) ->
			$.hash(Array) + $(o.map $.hash).reduce (a,x) ->
				(a*a)+(x|0)
			, 1
		}
		bool:    { hash: (o) -> parseInt(1 if o) }
	return {
		$:
			hash: (x) -> $.type.lookup(x).hash(x)
		hash: -> $.hash @
	}
