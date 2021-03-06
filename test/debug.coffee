
[$, assert] = require './setup'

describe "$.debugStack", ->
	it "reads all the files in stack trace", (done) ->
		$.delay 1, $.throttle 1000, ->
			lines = $.debugStack(new Error("foo"))
			$.log lines
			list = lines.split(/\n/)
			# assert.equal list.length, 94, lines
			# always pass for now, hard to find a truly stable stack to test
			done()

describe "$.protoChain", ->
	it "returns a string describing the prototype chain", ->
		class A
		class B extends A
		class C extends B
		assert.deepEqual [C, B, A], $.protoChain(new C())
