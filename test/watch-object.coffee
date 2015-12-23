[$, assert] = require './setup'

describe "watchProperty", ->
	it "watches basic property changes", (done) ->
		o = { x: 10 }
		$.watchProperty o, 'x', (op, k, v) ->
			assert.equal op, 'change'
			assert.equal k, "x"
			assert.equal v, 42
			done()
		o.x = 42
	
	it "supports nested dot-notation", (done) ->
		o = { range: { min: 0, max: 10 } }
		$.watchProperty o, 'range.min', (op, k, v) ->
			assert.equal op, 'change'
			assert.equal k, 'range.min'
			assert.equal v, 42
			done()
		o.range.min = 42
	
	describe "arrays handle", (done) ->
		it "push", (done) ->
			o = { a: [1, 2, 3] }
			$.watchProperty o, 'a', (op, k, v) ->
				assert.equal op, 'insert'
				assert.equal k, "a.3"
				assert.equal v, 4
				done()
			o.a.push 4
		it "pop", (done) ->
			o = { a: [1, 2, 3] }
			$.watchProperty o, 'a', (op, k, v) ->
				assert.equal op, 'delete'
				assert.equal k, "a.2"
				assert.equal v, 1
				done()
			o.a.pop()

		it "shift", (done) ->
			o = { a: [1, 2, 3] }
			$.watchProperty o, 'a', (op, k, v) ->
				assert.equal op, 'delete'
				assert.equal k, "a.0"
				assert.equal v, 1
				done()
			o.a.shift()
		it "unshift", (done) ->
			o = { a: [1, 2, 3] }
			$.watchProperty o, 'a', (op, k, v) ->
				assert.equal op, 'insert'
				assert.equal k, "a.0"
				assert.equal v, -1 
				done()
			o.a.unshift -1
		describe "splice", ->
			it "(1,1,42)", (done) ->
				o = { a: [1, 2, 3, 4] }
				$.watchProperty o, 'a', (op, k, v) ->
					assert.equal op, 'change'
					assert.equal k, "a.1"
					assert.equal v, 42
					done()
				o.a.splice 1,1,42
			it "(1,2,42)", ->
				o = { a: [1, 2, 3, 4] }
				events = $()
				$.watchProperty o, 'a', (op, k, v) ->
					events.push {op,k,v}
				o.a.splice 1,2,42
				assert.deepEqual events.last(2), [
					{ op: 'change', k: 'a.1', v: 42 }
					{ op: 'delete', k: 'a.2', v: 1 }
				]
			it "(1,0,42)", ->
				o = { a: [1, 2, 3, 4] }
				events = $()
				$.watchProperty o, 'a', (op, k, v) ->
					events.push {op,k,v}
				o.a.splice 1,0,42
				assert.deepEqual o.a.join(), "1,42,2,3,4"
				assert.deepEqual events, [
					{ op: 'change', k: 'a.3', v: 3 }
					{ op: 'change', k: 'a.2', v: 2 }
					{ op: 'change', k: 'a.1', v: 42 }
				]


