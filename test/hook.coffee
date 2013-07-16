[$, assert] = require './setup'

describe ".hook()", ->
	it "is a function", ->
		assert $.is 'function', $.hook
	it "returns a hook with append/prepend", ->
		p = $.hook()
		assert $.is 'function', p.append
		assert $.is 'function', p.prepend
	it "returns a function", ->
		p = $.hook()
		assert $.is 'function', p
	it "computes values when called", ->
		hook = $.hook()
		hook.append (x) -> x + 2
		hook.prepend (x) -> x * 2
		assert.equal hook(4), 10

