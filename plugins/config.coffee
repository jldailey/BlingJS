$.plugin
	provides: 'config'
	depends: 'type'
, ->
	get = (name, def) -> switch arguments.length
		when 0 then $.extend({}, process.env)
		else process.env[name] ? def
	set = (name, val) -> process.env[name] = val
	parse = (data) ->
		ret = {}
		$(data.toString("utf8").split "\n")
			.filter($.isEmpty, false)
			.filter(/^#/, false)
			.map(-> @replace(/^\s+/,'').split '=')
			.each (kv) ->
				if kv[0]?.length
					ret[kv[0]] = kv[1].replace(/^["']/,'').replace(/['"]$/,'')
		ret

	$: config: $.extend(get, {get, set, parse})

