# Lazy Plugin
# -----------
# Asynchronously load scripts and stylesheets by injecting script and link tags into the head.
$.plugin
	depends: "dom"
	provides: "lazy"
, ->
	lazy_load = (elementName, props) ->
		$("head").append $.extend document.createElement(elementName), props
	$:
		# __$.script(src)__ loads javascript files asynchronously.
		script: (src) ->
			lazy_load "script", { src: src }
		# __$.style(src)__  loads stylesheets asynchronously.
		style: (src) ->
			lazy_load "link", { href: src, rel: "stylesheet" }

