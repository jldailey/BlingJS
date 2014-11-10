$.plugin
	provides: 'config'
	depends: 'type'
, ->
	get = (name, def) -> switch arguments.length
		when 0 then $.extend({}, process.env)
		else process.env[name] ? def
	set = (name, val) -> switch arguments.length
		when 1 then $.extend process.env, arguments[0]
		when 2 then process.env[name] = val
	parse = (data) ->
		ret = {}
		$(data.toString("utf8").split "\n") \
			.filter($.isEmpty, false) \
			.filter(/^#/, false) \
			.map(-> @replace(/^\s+/,'').split '=') \
			.each (kv) -> if kv[0]?.length then ret[kv[0]] = kv[1] \
				.replace(/^["']/,'') \
				.replace(/['"]$/,'')
		ret
	watch = (name, func) ->
		prev = process.env[name]
		$.interval 1003, ->
			if (cur = process.env[name]) isnt prev
				func(prev, cur)
				prev = cur

	$: config: $.extend(get, {get, set, parse, watch})

