[$, assert] = require './setup'

describe "EventEmitter", ->
	it "works", ->
		a = $.EventEmitter a:1
		v = false
		a.on "event", -> v = true
		a.emit "event"
		assert v
	it "works on new blings automatically", ->
		b = $()
		v = false
		b.on "event", -> v = true
		b.emit "event"
		assert v
	it "provides (almost) the same API as node's EventEmitter", ->
		b = $()
		["addListener", "emit", "listeners", "on", "removeAllListeners", "removeListener", "setMaxListeners"].forEach (k) ->
			assert $.is 'function', b[k]
	it "can bless an object in-place", ->
		a = a:1
		b = $.EventEmitter(a)
		assert $.is 'function', a.emit
		assert $.is 'function', b.emit
	it "does not leak listeners", ->
		a = $.EventEmitter a:1
		a.on "smoke", -> "fire"
		a.on "smoke", -> "flee"
		assert.equal a.listeners("smoke").length, 2
		a.listeners("smoke").push("water")
		assert.equal a.listeners("smoke").length, 2
	it "accepts multiple events to bind at once", ->
		a = $.EventEmitter a:1
		pass = 0
		a.on(
			smoke: -> pass += 1
			steam: -> pass += 1
		)
		a.emit 'smoke'
		a.emit 'steam'
		assert.equal pass, 2
	it "returns itself after binding", ->
		a = $.EventEmitter()
		b = a.on( open: -> )
		c = a.on "close", ->
		assert.equal a, b
		assert.equal a, c
	describe "class extends support", ->
		class Foo extends $.EventEmitter
			constructor: ->
				super @
				@x = 1
			method: ->
		f = new Foo()
		it "gives new instances the EE interface", ->
			assert.equal $.type(f.on), "function"
		it "does not clobber instance methods", ->
			assert.equal $.type(f.method), "function"
		it "does not clobber instance properties", ->
			assert.equal $.type(f.x), "number"
		it "works", ->
			flag = false
			f.on 'event', -> flag = true
			f.emit 'event'
			assert.equal flag, true
		describe "inheritance chain", ->
			class A extends $.EventEmitter
				constructor: -> super @
				A: ->
			class B extends A
				B: ->
			class C extends B
			a = new A()
			b = new B()
			c = new C()
			it "goes through one level", ->
				assert.equal $.type(a.on), "function"
			it "goes through two levels", ->
				assert.equal $.type(b.on), "function"
			it "goes through three levels", ->
				assert.equal $.type(c.on), "function"
