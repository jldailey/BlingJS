$ = require "../../dist/bling.coffee"

expect = (val) ->
	(err, result) ->
		$.assert !err, "Expected '#{val}', got error: #{err}"
		$.assert (result is val), "Expected '#{val}', got result: #{result}"
		$.log "Passed (#{result})"

$.render.register "nesting-three", (o, opts) -> $.render.reduce o.content, opts
$.render({t:"nesting-three",content:[
	{t:"text",EN:"Hello"},
	p = $.Promise()
]}).wait expect "Hello World"
p.resolve " World"
