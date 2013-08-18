[ $ ] = require './setup'

do ->
	text = { t: "text", EN: "en", FR: "fr" }
	opts = { lang: "FR" }
	$.bench 'compact text', ->
		$.compact text, opts
	link = { t: "link", href: "#home", content: "content" }
	$.bench 'compact link', ->
		$.compact link, opts
	
	
