[$, assert] = require './setup'

describe "Clone plugin:", ->
	it "adds $.clone", ->
		assert.equal $.type($.clone), "function"
	describe "can clone", ->
		it "strings", ->
			a = "hello"
			b = $.clone a
			assert.equal a, 'hello'
			assert.equal b, 'hello'
			b += "a"
			assert.equal a, 'hello'
			assert.equal b, 'helloa'
		it "numbers", ->
			a = 10.2
			b = $.clone a
			assert.equal a, 10.2
			assert.equal b, 10.2
			b += 1
			assert.equal a, 10.2
			assert.equal b, 11.2
		it "arrays", ->
			a = [1,2,3]
			b = $.clone a
			assert.deepEqual a, b
			b[1] = 5
			assert.deepEqual a, [1,2,3]
			assert.deepEqual b, [1,5,3]
		it "blings", ->
			a = $ 1,2,3
			b = $.clone a
			assert.deepEqual a, b
			b[1] = 5
			assert.deepEqual a, [1,2,3]
			assert.deepEqual b, [1,5,3]
		it "recursively", ->
			o = {
				a: [1,2,3]
				b: "hello"
				c: 42
				p: $.Promise()
			}
			p = $.clone o
			assert.deepEqual p, {
				a: [1,2,3]
				b: "hello"
				c: 42
				p: null
			}
			p.a[1] = 5
			assert.equal o.a[1], 2
			assert.equal p.a[1], 5
			p.b += "r"
			assert.equal o.b, "hello"
			assert.equal p.b, "hellor"


