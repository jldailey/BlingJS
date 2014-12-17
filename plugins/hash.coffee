# Hash plugin
# -----------
# `$.hash(o)` Reduces any thing to an integer hash code (not secure).
$.plugin
	provides: "hash"
	depends: "type"
, ->
	maxHash = Math.pow(2,32)
	array_hash = (d) -> (o) -> d + $($.hash(x) for x in o).reduce(((a,x) -> ((a*a)+(x|0))%maxHash), 1)
	$.type.extend
		unknown:   { hash: (o) -> $.checksum $.toString o }
		object:    { hash: (o) -> 1970931729 + $($.hash(k) + $.hash(v) for k,v of o).sum() }
		array:     { hash: array_hash(1816922041) }
		arguments: { hash: array_hash(298517431) }
		bling:     { hash: array_hash(92078573) }
		bool:      { hash: (o) -> parseInt(1 if o) }
		regexp:    { hash: (o) -> 148243084 + $.checksum $.toString o }
	return {
		$: { hash: (x) -> $.type.lookup(x).hash(x) }
		hash: -> $.hash @
	}
