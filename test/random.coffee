[$, assert] = require './setup'

Number.prototype.within = (n) -> of: (x) => Math.abs(x - @) < n 

describe "Random plugin:", ->
	describe ".random()", ->
		assert 0.0 < $.random() < 1.0
		describe ".real()", ->
			r = $.random.real 10,100
			it "should produce a number", ->
				assert $.is 'number', r
			it "is in the range", ->
				assert 10.0 < r < 100.0
		describe ".integer()", ->
			r = $.random.integer(3,9)
			it "should be an integer", ->
				assert.equal Math.floor(r), r
			it "is in the range", ->
				assert 3 <= r <= 9
		describe ".string()", ->
			s = $.random.string(16)
			it "is a string", ->
				assert $.is 'string', s
			it "has the right length", ->
				assert.equal s.length, 16
		describe ".seed()", ->
			f = (seed) ->
				$.random.seed = seed
				$.random.string(16)
			it "should produce same output for the same seed", ->
				assert.equal f(42), f(42)
			it "should produce different output for a new seed", ->
				assert.notEqual f(42), f(43)
		describe ".dice()", ->
			it "rolls multiple dice", ->
				for i in [0...100]
					roll = $.random.dice(2,8)
					assert $.is 'bling', roll
					assert.equal roll.length, 2
					for r in roll
						assert 1 <= r <= 8
		describe ".die()", ->
			it "rolls one die", ->
				for i in [0...100]
					assert 0 < $.random.die(6) < 7
		describe ".element()", ->
			it "chooses a random element", ->
				sum = 0
				elems = [1,2,3]
				e = $.random.element elems
				assert e in elems
				elems = [0,1]
				for i in [0..1000]
					sum += $.random.element elems
				assert Math.abs(sum - 500) < 50
			it "accepts weights", ->
				sum = 0
				elems = [0,1]
				weights = [6,4]
				for i in [0..1000]
					sum += $.random.element elems, weights
				assert Math.abs(sum - 400) < 50
		describe ".coin()", ->
			fair_margin = .01
			it "flips a coin", ->
				assert $.random.coin() in [true, false]
			it "is fair", ->
				for x in [heads = 0...$.random.seed = n = 5000] by 1 when $.random.coin() then heads += 1
				assert Number(heads/n).within(fair_margin).of(0.5)
			it "can be weighted (.66)", ->
				for x in [heads = 0...$.random.seed = n = 5000] by 1 when $.random.coin(.66) then heads += 1
				assert Number(heads/n).within(fair_margin).of(0.66)
			it "can be weighted (.99)", ->
				for x in [heads = 0...$.random.seed = n = 5000] by 1 when $.random.coin(.99) then heads += 1
				assert Number(heads/n).within(fair_margin).of(0.99)
			it "can be weighted (.01)", ->
				for x in [heads = 0...$.random.seed = n = 5000] by 1 when $.random.coin(.01) then heads += 1
				assert Number(heads/n).within(fair_margin).of(0.01)
		describe ".gaussian()", ->
			it "draws from a normal distribution", ->
				$.random.seed = 12345
				draws = $($.random.gaussian(2.5, 1) for [0...1000])
				assert Number(mean = draws.mean()) \
					.within(.04).of(2.5), "mean #{mean} should be 2.5"
				assert Number(std = Math.sqrt $(draws).minus(mean).pow(2).mean()) \
					.within(.04).of(1), "std #{std} should be 1"
				draws = $($.random.gaussian(3.5, 2) for [0...1000])
				assert Number(mean = draws.mean()) \
					.within(.04).of(3.5), "mean #{mean} should be 3.5"
				assert Number(std = Math.sqrt $(draws).minus(mean).pow(2).mean()) \
					.within(.07).of(2), "std #{std} should be 2"

