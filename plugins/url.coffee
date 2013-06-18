$.plugin
	provides: "url,URL"
, ->
	url_re = /\b(?:([a-z]+):)(?:\/*([^:?\/#]+))(?::(\d+))*(\/[^?]*)*(?:\?([^#]+))*(?:#([^\s]+))*$/i

	parse = (str) ->
		m = str?.match url_re
		return if m? then {
			protocol: m[1]
			host:     m[2]
			port:     m[3]
			path:     m[4]
			query:    m[5]?.replace /^\?/   ,''
			hash:     m[6]?.replace /^#/    ,''
		} else null
	
	clean = (val, re, prefix = '', suffix ='') ->
		x = val ? ""
		return if x and not re.test x then prefix+x+suffix else x

	stringify = (url) ->
		return [
			clean(url.protocol, /:$/, '', ':'),
			clean(url.host, /^\//, '//'),
			clean(url.port, /^:/, ':'),
			clean(url.path, /^\//, '/'),
			clean(url.query, /^\?/, '?'),
			clean(url.hash, /^#/, '#')
		].join ''

	return $: URL: { parse, stringify }

