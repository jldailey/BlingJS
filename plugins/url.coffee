$.plugin
	depends: "type",
	provides: "url,URL"
, ->

	url_re = /\b(?:([a-z+]+):)(?:\/{1,2}([^?\/#]*?))(\/[^?]*)*(?:\?([^#]+))*(?:#([^\s]+))*$/i
	user_pass_re = /^([^:]+):([^@]+)@/
	username_re = /^([^:@]+)@/
	host_port_re = /^([^:]+):(\d+)/

	parse_host = (host) ->
		return {} unless host? and host.length > 0
		ret = { host }
		if ret.host.indexOf(",") > -1 then $.extend ret, {
			hosts: ret.host.split(",").map(parse_host)
			host: undefined
		} else
			if (m = ret.host.match user_pass_re) then $.extend ret, {
				username: m[1]
				password: m[2]
				host: ret.host.replace user_pass_re, ''
			} else if (m = ret.host.match username_re) then $.extend ret, {
				username: m[1]
				host: ret.host.replace username_re, ''
			}
			if (m = ret.host.match host_port_re) then $.extend ret, {
				host: m[1]
				port: m[2]
			}


		return ret

	parse = (str, parseQuery=false) ->
		ret = if (m = str?.match url_re) then {
			protocol: m[1]
			host:     m[2]
			path:     m[3]
			query:    m[4]?.replace /^\?/,''
			hash:     m[5]?.replace /^#/, ''
		} else null

		if ret?
			if parseQuery
				query = ret.query ? ""
				ret.query = Object.create null
				for pair in query.split('&')
					if (i = pair.indexOf '=') > -1
						ret.query[pair.substring 0,i] = unescape pair.substring i+1
					else if pair.length > 0
						ret.query[pair] = null
				delete ret.query[""]

			$.extend ret, parse_host(ret.host)

			# remove null undefined values from parsed response
			$.keysOf(ret).each (key) ->
				switch $.type ret[key]
					when "null","undefined" then delete ret[key]
					when "string" then if ret[key].length is 0 then delete ret[key]
				null

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

