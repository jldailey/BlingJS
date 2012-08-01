(($) ->
	$.plugin
		provides: 'config'
	, ->
		get = (name, def) -> process.env[name] ? def
		$: config: $.extend(get, get: get)
)(Bling)

