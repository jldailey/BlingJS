[$, assert] = require './setup'

describe "Middleware plugin:", ->
	describe "$.middleware()", ->
		it "constructs new middleware chains", ->
			m = $.middleware()
			assert.equal 'function', $.type m.use
			assert.equal 'function', $.type m.invoke
		it "registers with the type system", ->
			assert.equal 'middleware', $.type $.middleware()
		describe "::use(f)", ->
			it "adds a middleware to the chain", ->
				m = $.middleware()
				pass = false
				m.use (arg, next) ->
					pass = arg
					next()
				m.invoke true
				assert.equal true, pass
			it "can have any number of middleware", ->
				m = $.middleware()
				count = 0
				for i in [0...10]
					m.use (arg, next) -> count += arg; next()
				m.invoke 2
				assert.equal 20, count
		describe "::invoke(args...)", ->
			it "calls all the middleware in order", ->
				m = $.middleware()
				for i in [0...3] then do (i) -> # do a sequence of order-dependent operations
					m.use (arg, next) -> arg.count *= arg.count * (if i % 2 then 1 else -1 ); next()
				m.invoke obj = { count: 2 }
				assert.equal obj.count, -256
			it "accepts multiple arguments", ->
				m = $.middleware()
				pass = false
				m.use (arg1, arg2, next) ->
					pass = arg1 and arg2
					next()
				m.invoke true, true
				assert.equal true, pass
		describe "::unuse(f)", ->
			it "removes a middleware from the chain", ->
				m = $.middleware()
				pass = true
				m.use f = (arg, next) ->
					pass = arg
					next()
				m.unuse f
				m.invoke false
				assert.equal true, pass
