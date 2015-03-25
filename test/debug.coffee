
[$, assert] = require './setup'

describe "$.debugStack", ->
	it "reads all the files in stack trace", (done) ->
		$.delay 1, $.throttle 1000, ->
			lines = $.debugStack(new Error("foo"))
			list = lines.split(/\n/)
			assert.equal list.length, 14, lines
			done()
		# for now, just don't crash
		# verifying the output in a stable way is impossible at this point
