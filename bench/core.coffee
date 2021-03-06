[ $, _, Fs ] = require './setup'

$.bench 'function call', $.identity
$.bench 'bling from array', -> $ [1,2,3]
$.bench 'bling from nothing', -> $()
$.bench 'bling from multiple arguments', -> $(1,2,3)
$.bench 'bling from arguments object', -> (-> $ arguments)(1,2,3)

data = [
	42
	"Hello World"
	{ a: 1 }
	[ "Hello", "World" ]
]

for item in data then do (item) ->
	$.bench "JSON.stringify(#{$.type item})", -> JSON.stringify item
		
text = Fs.readFileSync "bench/snapshot.json"
$.bench "JSON.parse(140k file)", -> JSON.parse text

