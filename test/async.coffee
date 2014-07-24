[$, assert] = require './setup'

describe "async", ->
	it "defines series and parallel", ->
		assert 'series' of $::
		assert 'parallel' of $::
	describe ".series(cb)", ->
		it "calls all funcs in series", (done) ->
			$([
				(cb) -> $.delay 200, -> cb(1)
				(cb) -> $.delay 100, -> cb(2)
				(cb) -> $.delay 10, -> cb(3)
				(cb) -> $.immediate -> cb(4)
			]).series ->
				assert.deepEqual @flatten(), [1,2,3,4]
				done()
	describe ".paralell(cb)", ->
		it 'calls all funcs in parallel', (done) ->
			$([
				(cb) -> $.delay 200, -> cb(1)
				(cb) -> $.delay 100, -> cb(2)
				(cb) -> $.delay 10, -> cb(3)
				(cb) -> $.immediate -> cb(4)
			]).parallel ->
				assert.deepEqual @flatten(), [1,2,3,4]
				done()
