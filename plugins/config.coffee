(($) ->
	$.plugin
		provides: 'config'
	, ->
		$: config: get: (name, def) -> process.env[name] ? def
)(Bling)

