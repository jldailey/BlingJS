
[$, assert] = require './setup'

describe "$.debugStack", ->
	it "reads all the files in stack trace", ->
		$.debugStack(new Error("foo"))
		# for now, just don't crash
		# verifying the output in a stable way is impossible at this point
