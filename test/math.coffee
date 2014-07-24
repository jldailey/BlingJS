[$, assert] = require './setup'

describe "Math plugin:", ->
	describe ".avg()", ->
		it "average of an empty set is 0", ->
			assert.equal $([]).avg(), 0
		it "should compute the average", ->
			assert.equal $([1,2,3,4]).avg(), 2.5
		it "should be aliased as .mean()", ->
			assert.equal $::avg, $::mean

	describe ".sum()", ->
		it "should add an empty set as 0", ->
			assert.equal $([]).sum(), 0
		it "should compute the sum", ->
			assert.equal $([1,2,3,4,5]).sum(), 15
		it "should ignore non-numbers", ->
			assert.equal($([1,2,NaN,3]).sum(), 6)

	describe ".range(start,end)", ->
		it "should produce a sequence of ints from start to end", ->
			assert.equal($.range(1,6).toRepr(), '$([1, 2, 3, 4, 5])')
		it "start is optional, defaults to 0", ->
			assert.equal($.range(5).toRepr(), '$([0, 1, 2, 3, 4])')

	describe ".zeros()", ->
		it "should produce a set", ->
			assert $.is 'bling', $.zeros 10
		it "should produce all zeros", ->
			assert.equal 0, $.zeros(10).sum()

	describe ".ones()", ->
		it "should produce a set of ones", ->
			assert.equal $.ones(10).sum(), 10

	describe ".floats()", ->
		it "should convert everything to floats", ->
			assert.equal $(["12.1","29.9"]).floats().sum(), 42

	describe ".ints()", ->
		it "should convert everything to ints", ->
			assert.equal $(["12.1","29.9px"]).ints().sum(), 41

	describe ".px()", ->
		it "should convert everything to -px strings (for CSS)", ->
			assert.equal $(["12.1", "29.9"]).px(2).toRepr(), "$(['14px', '31px'])"

	describe ".min()", ->
		it "should return the smallest item", ->
			assert.equal $([12.1, 29.9]).min(), 12.1
		it "should ignore non-numbers", ->
			assert.equal( $([12.1, NaN, 29.9]).min(), 12.1)
		it "should return 0 for an empty set?"

	describe ".max()", ->
		it "should return the largest item", -> assert.equal( $([12.1, 29.9]).max(), 29.9)
		it "should ignore non-numbers", -> assert.equal( $([12.1, NaN, 29.9]).max(), 29.9)
		it "should return Infinity for an empty set?"
	
	describe ".dot()", ->
		it "computes the dot-product", ->
			assert.equal( $([1,2,3]).dot([4,5,6]), 4 + 10 + 18)
	
	describe ".angle()", ->
		it "computes the angle between vectors (in radians)", ->
			assert.equal( $(0,1,0).angle($ 1,0,0), $.deg2rad 90 )
			assert.equal( $(1,0,0).angle($ 1,0,0), $.deg2rad 0 )
		it "does not convert NaN to zero", ->
			assert not isFinite $(0,0,0).angle($ 0,0,0)
	
	describe ".cross()", ->
		it "computes the cross product of two vectors", ->
			assert.deepEqual( $(0,1,0).cross($ 1,0,0), [0,0,-1] )
		it "preserves order/direction", ->
			assert.deepEqual( $(1,0,0).cross($ 0,1,0), [0,0,1] )

	describe ".maxBy()", ->
		it "should return the largest item", ->
			assert.deepEqual $( {a:1}, {a:3}, {a:2} ).maxBy('a'), a:3
		it "accepts a value function", ->
			assert.deepEqual $( {a:1}, {a:3}, {a:2} ).maxBy((o) -> Math.pow(o.a,2)), a:3
	
	describe ".minBy()", ->
		it "should return the smallest item", ->
			assert.deepEqual $( {a:3}, {a:1}, {a:2} ).minBy('a'), a:1
		it "accepts a value function", ->
			assert.deepEqual $( {a:1}, {a:3}, {a:2} ).minBy((o) -> Math.pow(o.a,2)), a:1
	
	describe ".product()", ->
		it "computes the product of everything (like .sum() with *)", ->
			assert.equal $(2,4,6).product(), 48
	
	describe ".squares()", ->
		it "squares everything", -> assert.deepEqual $(2,4,6).squares(), [4, 16, 36]
	
	describe ".pow(n)", ->
		it "maps Math.pow", -> assert.deepEqual $(2,4,6).pow(3), [8,64,6*6*6]
	
	describe ".magnitude()", ->
		it "computes the vector length", -> assert.equal $(2,4,6).magnitude(), 7.483314773547883
	
	describe ".scale(r)", ->
		it "mulitiplies everything by a constant factor", -> assert.deepEqual $(2,4,6).scale(3), [6,12,18]
	
	describe ".add(n)", ->
		it "does vector addition (with a scalar)", ->
			assert.deepEqual $(2,4,6).add(2), [4,6,8]
		it "adds two vectors", ->
			assert.deepEqual $(2,4,6).add([3,5,9]), [5,9,15]
		it "truncates the longer vector if mis-sized", ->
			assert.deepEqual $(2,4,6,8).add([3,5,9]), [5,9,15]
		it "is also known as .plus()", ->
			assert.deepEqual $(2,4,6).plus(2), [4,6,8]
	describe ".sub(n)", ->
		it "does vector addition (with a scalar)", ->
			assert.deepEqual $(2,4,6).sub(2), [0,2,4]
		it "adds two vectors", ->
			assert.deepEqual $(2,4,6).sub([3,5,9]), [-1,-1,-3]
		it "truncates the longer vector if mis-sized", ->
			assert.deepEqual $(2,4,6,8).sub([3,5,9]), [-1,-1,-3]
		it "is also known as .minus()", ->
			assert.deepEqual $(2,4,6).minus(2), [0,2,4]
	
	describe ".normalize()", ->
		it "scales so that .magnitude() is 1", -> assert.equal $(2,4,6).normalize().magnitude(), 1
	
	describe ".deg2rad()", ->
		it "works as a global", -> assert.equal $.deg2rad(180), Math.PI
		it "works on a set", -> assert.deepEqual $(0,180).deg2rad(), [0, Math.PI]
	describe ".rad2deg()", ->
		it "works as a global", -> assert.equal $.rad2deg(Math.PI), 180
		it "works on a set", -> assert.deepEqual $(0,Math.PI).rad2deg(), [0, 180]


