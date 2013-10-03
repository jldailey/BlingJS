$ = require "../../dist/bling.coffee"

$.render.register "a", (o, opts) ->
	$.log "a: starting"
	p = $.Promise()
	$.delay 200, ->
		$.log "a: finishing"
		p.finish "DATA-A"
	p

$.render.register "b", (o, opts) ->
	$.log "b: starting"
	p = $.Promise()
	$.delay 200, ->
		p.finish { t: "a" }
	p

$.render.register "c", (o, opts) ->
	$.log "c: starting"
	return [ "c: ", { t: "a" }]

# $.render({t:"b"}).wait (err, result) -> $.log "b result:", err, result

$.render({t:"c"}).wait (err, result) -> $.log "c result:", err, result
