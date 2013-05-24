[$, assert] = require './setup'

describe "Object", ->
	it "should have a keys method", ->
		assert typeof Object.keys is "function"
	it "should have a values method", ->
		assert typeof Object.values is "function"
	describe ".keys()", ->
		it "should return the list of keys", ->
			assert.deepEqual Object.keys( "a": 1, b: 2 ), ['a', 'b']
	describe ".values()", ->
		it "should return the list of values", ->
			assert.deepEqual Object.values( "a": 1, b: 2 ), [1, 2]

describe "Bling", ->
	it "should have a symbol with side effects", ->
		assert Bling?
		assert.equal Bling.symbol, "$"
		assert.equal global.$, Bling
		Bling.symbol = "_"
		assert.equal global._, Bling
		global.$ = "before"
		Bling.symbol = "$"
		assert.equal global.$, Bling
		Bling.symbol = "_"
		assert.equal global.$, "before"
		Bling.symbol = "$"
		assert.equal global.$, Bling
	it "should be constructable by call (python style)", ->
		b = Bling([1,2,3])
		assert.equal b[0], 1
		assert.equal b[1], 2
		assert.equal b[2], 3
	it "should have have the right constructor name", ->
		assert.equal Bling([1,2]).constructor.name, "Bling"
	it "should correct the length value", ->
		assert.equal(Array(10).length,10)
		assert.equal(Bling(10).length, 0)

	it "can be created from an array", ->
		assert.deepEqual $([1,2,3]), [1,2,3]
	it "can be created from multiple arguments", ->
		assert.deepEqual $(1,2,3), [1,2,3]
	it "can be created from CSS selector", ->
		assert.equal $("td").length, 8
	it "can be created from an arguments object", ->
		f = -> Bling(arguments)
		assert.equal $.type(f(1,2,3)), "bling"
		assert.equal f(1,2,3).length, 3
		assert.deepEqual f(1,2,3), [1,2,3]

	describe ".identity", ->
		it "should be a function", -> assert $.is "function", $.identity
		it "should echo anything", -> assert.equal $.identity(a = {}), a

	describe ".bound", ->
		f = -> @value
		a = value:'a'
		b = value:'b'
		it "binding to a should return a's value", ->
			assert.equal do $.bound(a, f), 'a'
		it "binding to b should return b's value", ->
			assert.equal do $.bound(b, f), 'b'

	describe "$.log", ->
		describe ".out", ->
			it "defaults to console.log", ->
				assert.equal $.log.out, console.log
			it "is called by $.log", ->
				try
					pass = false
					$.log.out = (arg) -> pass = arg
					$.log true
					assert pass
				finally
					$.log.out = console.log

	describe "$.logger", ->
		it "creates a logger with a fixed prefix", ->
			f = $.logger('[magic]')
			message = ""
			try
				$.log.out = (a...) -> message = a.join " "
				f "message"
				assert message.indexOf("[magic] message") > -1
			finally
				$.log.out = console.log

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

	describe ".plugin()", ->
		describe "creating new plugins", ->
			$.plugin ->
				$:
					testGlobal: -> 9
				testOp: -> 42
			it "should define new globals", ->
				assert.equal $.testGlobal?(), 9
			it "should define new instance methods", ->
				assert.equal $().testOp?(), 42
			it "should provide a default global wrapper", ->
				assert.equal $.testOp?(), 42

	describe ".hash()", ->
		describe "hashes any type of object", ->
			it "number", -> assert $.hash(42) isnt $.hash(43)
			it "string", -> assert $.hash("foo") isnt $.hash("bar")
			it "array", -> assert $.hash("poop") isnt $.hash(["poop"])
			it "object", -> assert ($.hash a:1) isnt ($.hash a:2)
			it "bling", -> assert ($.hash $)?
		describe "always produces finite hashes", ->
			it "for objects", -> assert isFinite $.hash a:1
			it "for empty objects", -> assert isFinite $.hash {}
			it "for naked objects", -> assert isFinite $.hash Object.create null
		describe "the order of elements matters", ->
			it "in arrays", -> assert.notEqual $.hash(["a","b"]), $.hash(["b","a"])
			it "in blings", -> assert.notEqual $.hash($(["a","b"])), $.hash $(["b","a"])
		describe "overflow does not cause collisions", ->
			it "in arrays", -> assert.notEqual $.hash([1,2,3,0]), $.hash([1,2,3,99])
			it "in blings", -> assert.notEqual $.hash($(1,2,3,0)), $.hash(1,2,3,99)
			it "in objects", -> assert.notEqual $.hash({a:1,b:[1,2,3,0]}), $.hash({a:1,b:[1,2,3,99]})

	describe ".hook()", ->
		it "is a function", ->
			assert $.is 'function', $.hook
		it "returns a hook with append/prepend", ->
			p = $.hook()
			assert $.is 'function', p.append
			assert $.is 'function', p.prepend
		it "returns a function", ->
			p = $.hook()
			assert $.is 'function', p
		it "computes values when called", ->
			hook = $.hook()
			hook.append (x) -> x + 2
			hook.prepend (x) -> x * 2
			assert.equal hook(4), 10

	describe ".keysOf()", ->
		it "is like Object.keys", ->
			assert.deepEqual $.keysOf(a:1), ['a']
		it "returns a bling", ->
			assert $.is 'bling', $.keysOf(a:1)
		it "includes any enumerable property", ->
			a = a: 1
			$.defineProperty a, "b", get: -> 2
			assert.deepEqual $.keysOf(a), ["a", "b"]

	describe ".valuesOf()", ->
		it "returns a bling", ->
			assert $.is 'bling', $.valuesOf(a:1)
		it "returns the set of values", ->
			assert.deepEqual $.valuesOf(a:1), [1]
		it "includes any enumerable properties", ->
			a = a: 1
			$.defineProperty a, "b", get: -> 2
			assert.deepEqual $.valuesOf(a), [1, 2]

	describe ".config(name, def)", ->
		it "gets config from the environment", ->
			try
				process.env.UNIT_TEST_MAGIC = "magic"
				assert.equal $.config.get("UNIT_TEST_MAGIC"), "magic"
			finally
				delete process.env.UNIT_TEST_MAGIC
		it "supports a default value", ->
			assert.equal $.config.get("NOT_FOUND", "default"), "default"
		it "can be called directly", ->
			assert.equal $.config("NOT_FOUND", "default"), "default"
		it "can parse and set values from string data", ->
			assert.deepEqual $.config.parse("""NO_LEAD='no leading whitespace'
				LEADING='ignores leading whitespace'
				NOQUOTES=does not require any quotes
			"""), {
					NO_LEAD: "no leading whitespace"
					LEADING: "ignores leading whitespace"
					NOQUOTES: "does not require any quotes"
				}

	describe ".histogram(data)", ->
		it "draws a histogram", ->
			assert $.is 'string', $.histogram( [1,2,3,4,5] )
		it "can get real", ->
			assert $.is 'string', $.histogram $.ones(1000).map(-> $.random.gaussian .65, .07), .01
	
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
	
	describe "RequestQueue", ->
		it "pushes throttled messages through a real requester", (done) ->
			# Make a mock requester
			count = 0
			requester = (opts, cb) ->
				assert opts.method is "POST"
				count += opts.index
				cb(false, opts.index)
			rq = new $.RequestQueue(requester)
			# Push 3 messages every 101ms
			rq.start 3, 101
			# Queue some messages (5 should take 202ms to send)
			for index in [0...5] by 1 then do (index) ->
				rq.post {index}, (err, data) ->
					assert.equal err, false
					assert.equal data, index
			# Stop in 250ms
			$.delay 250, ->
				rq.stop()
				assert.equal count, 10
				done()
	
