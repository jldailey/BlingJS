[$, assert] = require './setup'

describe "$.TNET", ->
	describe ".parse()", ->
		describe "supports type:", ->
			it "numbers", ->
				assert.equal $.TNET.parse("2:42#"), 42
			it "strings", ->
				assert.equal $.TNET.parse("3:foo'"), "foo"
			it "bool", ->
				assert.equal $.TNET.parse("4:true!"), true
				assert.equal $.TNET.parse("0:!"), false
			it "null", ->
				assert.equal $.TNET.parse("0:~"), null
			it "undefined", ->
				assert.equal $.TNET.parse("0:_"), undefined
			it "array", ->
				assert.deepEqual $.TNET.parse("12:1:1#1:2#1:3#]"), [1,2,3]
			it "bling", ->
				assert.deepEqual $.TNET.parse("12:1:1#1:2#1:3#$"), $(1,2,3)
			it "object", ->
				assert.deepEqual $.TNET.parse("16:1:a'1:1#1:b'1:2#}"), {a:1,b:2}
			it "function", ->
				f = $.TNET.parse "29:2:sq'4:1:x']13:return x * x;')"
				assert $.is 'function', f
				assert.equal f.name, 'sq'
				assert.equal f(4), 16
			it "regexp", ->
				expect = /^f.*o$/
				got = $.TNET.parse("6:^f.*o$/")
				assert $.is 'regexp', got
				assert.equal got.toString(), expect.toString()
		it "can parse a Buffer:", ->
			str = $.TNET.stringify { magic: "token" }
			buf = new Buffer(str)
			assert.deepEqual $.TNET.parse(buf), { magic: "token" }
	
	describe ".parseOne()", ->
		it "returns the left-overs", ->
			data = $.TNET.stringify( a: 'b' ) + $.TNET.stringify( b: 'c' )
			[value, data] = $.TNET.parseOne(data)
			assert.deepEqual value, { a: 'b' }
			assert.equal data, $.TNET.stringify b: 'c'
			[value, data] = $.TNET.parseOne(data)
			assert.deepEqual value, { b: 'c' }
			assert.equal data, ''

	describe ".stringify()", ->
		describe "supports type:", ->
			it "numbers", ->
				assert.equal $.TNET.stringify(42), "2:42#"
			it "string", ->
				assert.equal $.TNET.stringify("foo"), "3:foo'"
			it "bool", ->
				assert.equal $.TNET.stringify(true), "4:true!"
			it "null", ->
				assert.equal $.TNET.stringify(null), "0:~"
			it "undefined", ->
				assert.equal $.TNET.stringify(undefined), "0:_"
			it "array", ->
				assert.equal $.TNET.stringify([1,2,3]), "12:1:1#1:2#1:3#]"
			it "bling", ->
				assert.equal $.TNET.stringify($ 1,2,3), "12:1:1#1:2#1:3#$"
			it "object", ->
				assert.equal $.TNET.stringify({a:1,b:2}), "16:1:a'1:1#1:b'1:2#}"
			it "function", ->
				assert.equal $.TNET.stringify((x)->x*x), "27:0:'4:1:x']13:return x * x;')"
			it "function with name", ->
				class Foo
					constructor: (x) -> return x * x
				assert.equal $.TNET.stringify(Foo), "30:3:Foo'4:1:x']13:return x * x;')"
			it "regexp", ->
				assert.equal $.TNET.stringify(/^f.*o$/), "6:^f.*o$/"
			it "class instance", ->
				class Foo
					sq: -> return @x * @x
				f = new Foo()
				f.x = 4
				assert.throws ->
					$.TNET.stringify f # Foo is not registered yet
				$.TNET.registerClass Foo
				assert.equal $.TNET.stringify(f), "15:1:1#8:1:x'1:4#}C"
				g = $.TNET.parse $.TNET.stringify(f)
				assert.equal g.sq(), 16


