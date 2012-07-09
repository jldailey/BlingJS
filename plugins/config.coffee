(($) ->
	$.plugin
		provides: 'config'
	, ->
		$: config: (name, def) -> process.env[name] ? def
)(Bling)

