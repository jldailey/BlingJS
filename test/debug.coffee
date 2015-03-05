
[$, assert] = require './setup'

describe "$.debugStack", ->
	it "reads all the files in stack trace", (done) ->
		$.delay 1, $.throttle 1000, ->
			console.log $.debugStack(new Error("foo"))
			done()
		# for now, just don't crash
		# verifying the output in a stable way is impossible at this point
