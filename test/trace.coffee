[$, assert] = require './setup'

describe ".trace", ->
	f = -> 42
	g = [] # an output buffer
	h = $.trace "label", f, (a...) ->
		g.push a.join ''
	it "should not trace the original function", ->
		f()
	it "should trace the returned function", ->
		h "one", "two" # but this will
		assert /global\.label\('one','two'\): \d+ms/.test g[0]

describe ".time", ->
	f = -> 42
	pass = false
	it "reports execution time", ->
		$.time f, (m) ->
			assert /\[trace\] \dms/.test m
			pass = true
		assert pass, "logger must be called"
	it "accepts an optional prefix", ->
		$.time "LABEL", f, (m) -> assert /\[LABEL\] \dms/.test m
	it "return the value that f returns", ->
		assert.equal $.time( (->42), (->) ), 42

