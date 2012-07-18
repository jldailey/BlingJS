(($) ->
	# HTTP Client Plugin
	# -----------
	# Things like `.ajax()`, `.get()`, `$.post()`.
	$.plugin
		depends: "dom"
		provides: "http"
	, ->
		formencode = (obj) -> # create &foo=bar strings from object properties
			o = JSON.parse(JSON.stringify(obj)) # quickly remove all non-stringable items
			("#{i}=#{escape o[i]}" for i of o).join "&"

		$.type.register "http",
			match: (o) -> $.isType 'ClientRequest', o
			array: (o) -> [o]

		return {
			$:
				# __$.http(url, [opts/callback])__ - fetch _url_ using HTTP (method in _opts_)
				http: (url, opts = {}) ->
					opts = $.extend {
						method: "GET"
						data: null
						state: $.identity # onreadystatechange
						success: $.identity # onload
						error: $.identity # onerror
						async: true
						asBlob: false
						timeout: 0 # milliseconds, 0 is forever
						followRedirects: false
						withCredentials: false
					}, opts

				# __$.post(_url_, [_opts_])__ - fetch _url_ with a POST request
				post: (url, opts = {}) ->
					if $.is "function", opts
						opts = success: opts
					opts.method = "POST"
					$.http url, opts

				# __$.get(_url_, [_opts_])__ - fetch _url_ with a GET request
				get: (url, opts = {}) ->
					if $.is "function", opts
						opts = success: opts
					opts.method = "GET"
					$.http url, opts
		}
)(Bling)
