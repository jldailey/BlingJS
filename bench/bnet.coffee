[ $ ] = require './setup'

data = [
	42
	"Hello world"
	{ a: 42 }
	[ "Hello", "world" ]
]

for item in data then do (item) ->
	$.bench "BNET.stringify(#{$.type item})", -> $.BNET.stringify item

