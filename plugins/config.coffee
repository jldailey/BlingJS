do ($ = Bling) ->
	$.plugin
		provides: 'config'
		depends: 'type'
	, ->
		get = (name, def) -> process.env[name] ? def
		$: config: $.extend(get, get: get)

