[$, assert] = require "./setup"

describe "Throttle plugin:", ->
	describe ".throttle(ms, f)", ->
		it "returns a new f that will only run once every ms", (done) ->
			count = 0
			g = $.throttle 100, -> count += 1
			i = $.interval 25, g
			$.delay 525, ->
				i.cancel()
				assert.equal count, 5
				done()
	describe ".debounce(ms, f)", ->
		it "returns a new f that will not run twice within ms", (done) ->
			count = 0
			g = $.debounce 50, -> count += 1
			i = $.interval 5, g
			$.delay 500, ->
				i.cancel()
				$.delay 60, ->
					assert.equal count, 1
					done()
