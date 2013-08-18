[$, assert] = require './setup'

describe "RequestQueue", ->
	it "pushes throttled messages through a real requester", (done) ->
		# Make a mock requester
		count = 0
		requester = (opts, cb) ->
			assert opts.method is "POST"
			count += opts.index
			cb(false, opts.index)
		rq = new $.RequestQueue(requester)
		# Push 3 messages every 101ms
		rq.start 3, 101
		# Queue some messages (5 should take 202ms to send)
		for index in [0...5] by 1 then do (index) ->
			rq.post {index}, (err, data) ->
				assert.equal err, false
				assert.equal data, index
		# Stop in 250ms
		$.delay 250, ->
			rq.stop()
			assert.equal count, 10
			done()
