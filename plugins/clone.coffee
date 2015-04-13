
$.plugin {
	provides: "clone"
	depends: "type"
}, ->
	$.type.extend {
		unknown: clone: (s) -> null # err on the side of caution
		string:  clone: (s) -> s + ""
		number:  clone: (n) -> n + 0.0
		array:   clone: (a) -> a.concat []
		bling:   clone: (b) -> b.concat []
		object:  clone: (o) ->
			try return ret = Object.create(o.__proto__)
			finally for own k,v of o then ret[k] = $.type.lookup(v).clone(v)
	}
	# TODO: if dom enabled, invoke the cloneNode code here

	return { $: { clone: (o) -> $.type.lookup(o).clone(o) } }
