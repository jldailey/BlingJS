[$, assert] = require './setup'

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
			$.random.seed = 42
			r = $.random.string(16)
			$.random.seed = 43
			s = $.random.string(16)
			$.random.seed = 42
			t = $.random.string(16)
			it "should produce same output for the same seed", ->
				assert.equal r, t
			it "should produce different output for a new seed", ->
				assert.notEqual r, s
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
