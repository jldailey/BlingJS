$.plugin
	depends: "type",
	provides: "url,URL"
, ->

	url_re = /\b(?:([a-z+]+):)(?:\/{1,2}([^?\/#]*?))(?::(\d+))*(\/[^?]*)*(?:\?([^#]+))*(?:#([^\s]+))*$/i

	parse = (str, parseQuery=false) ->
		ret = if (m = str?.match url_re) then {
			protocol: m[1]
			host:     m[2]
			port:     m[3]
			path:     m[4]
			query:    m[5]?.replace /^\?/,''
			hash:     m[6]?.replace /^#/, ''
		} else null

		if ret? and parseQuery
			query = ret.query ? ""
			ret.query = Object.create null
			for pair in query.split('&')
				if (i = pair.indexOf '=') > -1
					ret.query[pair.substring 0,i] = unescape pair.substring i+1
				else if pair.length > 0
					ret.query[pair] = null
			delete ret.query[""]

		ret

	clean = (val, re, prefix = '', suffix ='') ->
		x = val ? ""
		return if x and not re.test x then prefix+x+suffix else x

	stringify = (url) ->
		if $.is 'object', url.query
			url.query = ("#{k}=#{v}" for k,v of url.query).join("&")
		return [
			clean(url.protocol, /:$/, '', ':'),
			clean(url.host, /^\//, '//'),
			clean(url.port, /^:/, ':'),
			clean(url.path, /^\//, '/'),
			clean(url.query, /^\?/, '?'),
			clean(url.hash, /^#/, '#')
		].join ''

	return $: URL: { parse, stringify }

