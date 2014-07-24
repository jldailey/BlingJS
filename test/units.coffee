[$, assert] = require './setup'

describe "Units plugin:", ->
	describe ".units", ->
		$.units.enable()
		it "handles strings with unit-suffixed numbers", ->
			assert.equal $.type("34px"), "units"
		it "does not handle strings with numbers alone", ->
			assert.notEqual $.type("34"), "units"
		it "converts between units", ->
			assert.equal $.units.convertTo('cm', '300in'), "762cm"
		it "can find non-trivial conversions through inferrence", ->
			assert.equal $.units.convertTo('px', '.1yd'), "345.58313554298553px"
		it "simply adds a unit to un-suffixed numbers", ->
			assert.equal $.units.convertTo('px', '10.1'), '10.1px'
		it "does not crash on bad numbers", ->
			assert not isFinite $.units.convertTo('px', Infinity)
			assert not isFinite $.units.convertTo('px', NaN)
		it "can convert compound units like m/s", ->
			assert.equal $.units.convertTo("px/ms", "42in/s"), "4.032px/ms"
