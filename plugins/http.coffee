# HTTP Client Plugin
# -----------
# Things like `.ajax()`, `.get()`, `$.post()`.
$.plugin
	depends: "dom"
	provides: "http"
, ->
	formencode = (obj) -> # create &foo=bar strings from object properties
		return if $.is 'object', obj
			o = JSON.parse JSON.stringify obj # quickly remove all non-stringable items
			("#{i}=#{escape o[i]}" for i of o).join "&"
		else obj

	$.type.register "http",
		is: (o) -> $.isType 'XMLHttpRequest', o
		array: (o) -> [o]

	return {
		$:
			# __$.http(url, [opts/callback])__ - fetch _url_ using HTTP (method in _opts_)
			http: (url, opts = {}) ->
				xhr = new XMLHttpRequest()
				if $.is "function", opts
					opts = success: $.bound(xhr, opts)
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
					headers: {}
				}, opts
				# Bind all the event handlers.
				opts.state = $.bound(xhr, opts.state)
				opts.success = $.bound(xhr, opts.success)
				opts.error = $.bound(xhr, opts.error)
				# Append url parameters.
				if opts.data and opts.method is "GET"
					url += "?" + formencode(opts.data)
				else if opts.data and opts.method is "POST"
					opts.data = formencode(opts.data)
				# Open the connection.
				xhr.open(opts.method, url, opts.async)
				# Set the options.
				xhr = $.extend xhr,
					asBlob: opts.asBlob
					timeout: opts.timeout
					followRedirects: opts.followRedirects
					withCredentials: opts.withCredentials
					# There is one central state handler that calls the
					# various handlers bound to opts.
					onreadystatechange: ->
						opts.state?()
						if xhr.readyState is 4
							if xhr.status is 200
								opts.success xhr.responseText
							else
								opts.error xhr.status, xhr.statusText
				for k,v of opts.headers
					xhr.setRequestHeader k, v
				# Send the request body.
				xhr.send opts.data
				# Return the wrapped xhr object (for cancelling mostly)
				return $(xhr)

			# __$.post(_url_, [_opts_])__ - fetch _url_ with a POST request
			post: (url, opts = {}) ->
				if $.is("function",opts)
					opts = success: opts
				opts.method = "POST"
				$.http(url, opts)

			# __$.get(_url_, [_opts_])__ - fetch _url_ with a GET request
			get: (url, opts = {}) ->
				if( $.is("function",opts) )
					opts = success: opts
				opts.method = "GET"
				$.http(url, opts)
	}
