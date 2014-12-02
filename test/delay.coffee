[$, assert] = require './setup'

describe ".delay(ms, f)", ->
	it "runs f after a delay of ms", (done) ->
		t = $.now
		$.delay 40, ->
			delta = Math.abs(($.now - t) - 40)
			assert delta < 10
			done()
	it "can be cancelled", (done) ->
		pass = true
		d = $.delay 100, -> pass = false
		$.delay 10, -> d.cancel()
		$.delay 150, ->
			assert pass
			done()
	it "accepts multiple timeouts at once", (done) ->
		count = 0
		$.delay
			20: -> count += 1
			40: -> count += 2
			60: -> count += 3
			80: ->
				assert.equal count, 6
				done()

describe ".immediate(f)", ->
	it "runs f on the next tick", (done) ->
		pass = false
		$.immediate ->
			assert pass = true
			done()

describe ".interval(ms, f)", ->
	it "runs f repeatedly", (done) ->
		count = 0
		i = $.interval 20, -> count += 1
		$.delay 200, ->
			assert 8 <= count <= 11, "Count: #{count} is not between 8 and 11"
			i.cancel()
			done()
	it "can be paused/resumed", (done) ->
		count = 0
		i = $.interval 20, -> count += 1
		$.delay 100, -> i.pause()
		$.delay 200, -> i.resume()
		$.delay 400, ->
			assert 11 <= count <= 15, "Count: #{count} is not between 11 and 15"
			i.cancel()
			done()

