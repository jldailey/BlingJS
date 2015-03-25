
[$, assert] = require './setup'

describe "$.debugStack", ->
	it "reads all the files in stack trace", (done) ->
		$.delay 1, $.throttle 1000, ->
			lines = $.debugStack(new Error("foo"))
			$.log lines
			list = lines.split(/\n/)
			assert.equal list.length, 14, lines
			done()
