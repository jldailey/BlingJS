[$, assert] = require './setup'

describe "Type plugin:", ->
	describe ".type()", ->
		describe "should classify", ->
			it "'string'", -> assert.equal $.type(''), 'string'
			it "'number'", -> assert.equal $.type(42), 'number'
			it "'undefined'", -> assert.equal $.type(), "undefined"
			it "'null'", -> assert.equal $.type(null), "null"
			it "'array'", -> assert.equal $.type([]), "array"
			it "'function'", -> assert.equal $.type(->), "function"
			it "'bool'", -> assert.equal $.type(true), "bool"
			it "'regexp'", -> assert.equal $.type(//), "regexp"
			it "'window'", -> assert.equal $.type(window), "global"
			it "'arguments'", -> assert.equal $.type(arguments), "arguments"

	describe ".is()", ->
		describe "should identify", ->
			it "'string'", -> assert $.is 'string', ''
			it "'number'", -> assert $.is 'number', 42
			it "'undefined'", -> assert.equal $.type(), "undefined"
			it "'null'", -> assert $.is "null", null
			it "'array'", -> assert $.is "array", []
			it "'function'", -> assert $.is "function", ->
			it "'bool'", -> assert $.is "bool", true
			it "'regexp'", -> assert $.is "regexp", /^$/
			it "'window'", -> assert $.is "global", window
			it "'arguments'", -> assert $.is "arguments", arguments

	describe ".inherit(a,b)", ->
		a = a: 1
		b = b: 2
		$.inherit a, b
		it "should set b's __proto__ to a", ->
			assert.equal b.__proto__, a
		it "b should inherit properties from a", ->
			assert.equal b.a, 1
		it "but b should not own those properties", ->
			assert not b.hasOwnProperty "a"

	describe ".extend(a,b)", ->
		a = a: 1
		b = b: 2
		c = $.extend a, b
		it "should return the modified a", -> assert.equal c, a
		it "should give a properties from b", -> assert.equal a.b, 2
		it "should copy those properties", ->
			a.b = 3
			assert.equal b.b, 2
		it "can extend many b's at once", ->
			d = d: 1
			$.extend d, { e: 2 }, { f: 3 }
			assert.equal d.e, 2
			assert.equal d.f, 3

	describe ".defineProperty()", ->
		describe "getters", ->
			a = {}
			$.defineProperty a, "getter",
				get: -> 2
			it "should be readable", ->
				assert.equal a.getter, 2
			it "should not be settable", ->
				a.getter = 3
				assert.equal a.getter, 2
			it "should be enumerable", ->
				assert.notEqual -1, Object.keys(a).indexOf("getter")
			it "should be configurable"
		describe "setters", ->
			a = {}
			$.defineProperty a, "setter",
				set: (v) ->
			it "should be settable", ->
				a.setter = 10
			it "should not be gettable", ->
				assert.equal a.setter, undefined
			it "should be enumerable", ->
				assert.notEqual -1, Object.keys(a).indexOf("setter")

	describe ".isType()", ->
		it "should compare against actual types", ->
			assert $.isType Array, []
		it "or against names of constructors", ->
			assert( $.isType('Array', []) )
		it "should work on non-builtin types", ->
			class Foo
			f = new Foo()
			assert $.isType Foo, f

	describe ".isSimple()", ->
		describe "should accept", ->
			it "strings", -> assert $.isSimple ""
			it "numbers", -> assert $.isSimple 42.0
			it "bools", -> assert( $.isSimple false )
		describe "should reject", ->
			it "objects", -> assert not $.isSimple {}
			it "arrays", -> assert not $.isSimple []

	describe ".isEmpty()", ->
		describe "should accept", ->
			it "empty strings", -> assert $.isEmpty ""
			it "nulls", -> assert $.isEmpty null
			it "undefineds", -> assert $.isEmpty undefined
			it "empty arrays", -> assert $.isEmpty []
			it "empty objects", -> assert $.isEmpty {}
		describe "should reject", ->
			it "full strings", -> assert not $.isEmpty "abc"
			it "arrays with items", -> assert not $.isEmpty [1,2,3]
			it "objects with keys", -> assert not $.isEmpty a:1

	describe ".toArray()", ->
		a = $([1,2,3])
		b = a.toArray()
		it "should produce an Array", ->
			assert.equal b.constructor.name, "Array"
		it "should preserve data", ->
			assert.equal b[1], 2
		it "should preserve length", ->
			assert.equal b.length, 3
		it "should not preserve bling functions", ->
			assert not b.zap

	describe ".as()", ->
		describe "should convert", ->
			it "strings to numbers", -> assert.equal ($.as "number", "1234"), 1234

