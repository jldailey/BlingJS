require "./common"

$.depends "math, random, unittest", ->
	$.testGroup "random",
		coin: ->
			$.assert $.approx $($.random.coin() for _ in [0...1000]).mean(), .5, .05
		ints: ->
			$.assert $.approx $($.random.int(0,10) for _ in [0...20000]).mean(), 5, .7
		gauss: ->
			$.assert $.approx $($.random.gaussian() for _ in [0...1000]).mean(), .5

