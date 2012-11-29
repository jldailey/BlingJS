$.plugin
	provides: 'config'
	depends: 'type'
, ->
	get = (name, def) -> process.env[name] ? def
	set = (name, val) -> process.env[name] = val
	$: config: $.extend(get, {get: get, set: set})

