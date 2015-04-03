[$, assert] = require "./setup"

describe "Compat plugin", ->
	describe "provides", ->
		describe "Map", ->
			it "is global", ->
				assert $.is 'function', $.global.Map
			it "get/set/has keys", ->
				m = new Map()
				m.set 'foo', 'bar'
				assert m.has 'foo'
				assert.equal (m.get 'foo'), 'bar'
		it "Buffer.isBuffer", ->
			assert $.is 'function', Buffer.isBuffer
		it "String::trimLeft", ->
			assert $.is 'function', String.prototype.trimLeft
		it "String::split", ->
			assert $.is 'function', String.prototype.split
		it "String::lastIndexOf", ->
			assert $.is 'function', String.prototype.lastIndexOf
		it "Array::join", ->
			assert $.is 'function', Array.prototype.join
		it "Event::preventAll", ->
			assert $.is 'function', Event.prototype.preventAll
		it "Math.sign", ->
			assert.equal Math.sign(-12), -1
			assert.equal Math.sign(0), 1



