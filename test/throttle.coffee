[$, assert] = require "./setup"

describe "Throttle plugin:", ->
	describe ".throttle(ms, f)", ->
		it "returns a new f that will only run once every ms", (done) ->
			count = 0
			f = -> count += 1
			g = $.throttle 100, f
			i = $.interval 25, g
			$.delay 500, ->
				i.cancel()
				assert.equal count, 5
				done()
	describe ".debounce(ms, f)", ->
		it "returns a new f that will not run twice within ms", (done) ->
			count = 0
			f = -> count += 1
			g = $.debounce 500, f
			i = $.interval 25, g
			$.delay 600, ->
				i.cancel()
				assert.equal count, 1
				done()
			done()
