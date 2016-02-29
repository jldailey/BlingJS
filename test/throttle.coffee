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
			g = $.debounce 30, -> count += 1
			i = $.interval 5, g
			$.delay 300, ->
				i.cancel()
				checkpoint = 0
				$.delay 50, ->
					assert.equal checkpoint+1, count
					done()
	describe ".rate_limit(ms, f)", ->
		it "works like throttle with an auto-flush at the end", (done) ->
			count = 0
			g = $.rate_limit 30, -> count += 1
			i = $.interval 5, g
			$.delay 300, ->
				i.cancel()
				checkpoint = count
				$.delay 50, -> # one extra gets added after the interval stopped
					assert.equal checkpoint+1, count
					done()
