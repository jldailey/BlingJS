[$, assert] = require './setup'

describe "$.Promise()", ->
	describe "wait", ->
		it "queues a callback", (done) ->
			$.Promise().wait((err, data) -> done(err)).resolve()
		it "calls back in a later tick if already resolved", (done) ->
			output = null
			$.Promise().resolve("magic").wait (err, data) ->
				output = data
			# it does not fire yet
			assert.equal output, null
			$.delay 20, ->
				assert.equal output, "magic"
				done()
	describe "resolve", ->
		it "passes data to queued callbacks", (done) ->
			$.Promise().wait((err, data) ->
				if data isnt "magic"
					done "rejected: no magic!"
				else done()
			).resolve "magic"
		it "ignores repeated calls", ->
			count = 1
			a = $.Promise().wait -> count += count
			a.resolve()
			a.resolve()
			assert.equal count, 2 # not 4, if it had run twice
		describe "optional timeout", ->
			it "sets error to 'timeout'", (done) ->
				$.Promise().wait 100, (err, data) ->
					assert.equal err, 'timeout'
					done()
			it "does not fire an error if the promise is resolved in time", (done) ->
				pass = false
				$.Promise().wait(100, (err, data) ->
					assert.equal err, null
					pass = data
				).resolve true
				$.delay 200, ->
					assert.equal pass, true
					done()
	describe "reject", ->
		it "passes errors to queued callbacks", (done) ->
			$.Promise().wait((err, data) ->
				if String(err) isnt "Error: fizzle"
					done "expected: 'Error: fizzle' got: '#{String err}'"
				else done()
				).reject "fizzle"
		it "ignores repeated calls", ->
			pass = ""
			a = $.Promise().wait (err, data) -> pass += String(err)
			a.reject "error"
			a.reject "error"
			assert.equal pass, "Error: error" # not 4, if it had run twice
	describe "reset", ->
		it "resets", ->
			rp = $.Promise()
			count = 0
			rp.wait (err, data) -> count += data
			rp.resolve 1
			assert.equal count, 1
			rp.reset()
			rp.wait (err, data) -> count += data
			rp.resolve 1
			assert.equal count, 2 # if it's 1 then the second waiter never fired
			# if it's 3 then the first waiter fired twice
	describe "status flags", ->
		it ".resolved is false at first", ->
			assert.equal $.Promise().resolved, false
		it ".resolved is true after .resolve()", ->
			assert.equal $.Promise().resolve().resolved, true
		it "rejected", ->
			assert.equal $.Promise().rejected, false
			assert.equal $.Promise().reject().rejected, true

	describe "inheritance", ->
		it "works with default constructor", ->
			class Foo extends $.Promise
			f = new Foo()
			f.wait (err, data) -> f.pass = data
			f.resolve true
			assert.equal f.pass, true
		it "works with super", ->
			class Foo extends $.Promise
				constructor: (@pass) -> super @
			f = new Foo(false)
			f.wait (err, data) -> f.pass = data
			f.resolve true
			assert f.pass
	describe ".compose()", ->
		it "composes promises", ->
			pass = false
			a = $.Promise()
			b = $.Promise()
			c = $.Promise.compose(a, b).wait -> pass = true
			a.resolve()
			b.resolve()
			assert pass
	describe ".collect()", ->
		it "exists", ->
			assert 'collect' of $.Promise
		it "is a function", ->
			assert.equal "function", $.type $.Promise.collect
		it "returns a promise", ->
			assert.equal 'promise', $.type $.Promise.collect()
			assert 'then' of $.Promise.collect()
		it "collects the output of promises in order", (done) ->
			a = $.Promise()
			b = $.Promise()
			c = $.Promise()
			$.Promise.collect([a,b,c]).then (list) ->
				assert.deepEqual list, ['a','b','c']
				done()
			b.resolve('b')
			c.resolve('c')
			a.resolve('a')
		it "fails when any sub-promise fails", (done) ->
			a = $.Promise()
			b = $.Promise()
			c = $.Promise()
			d = $.Promise.collect([a,b,c])
			c.resolve('c')
			b.reject("err_b")
			a.resolve('a')
			d.wait (err) ->
				assert.equal "Error: err_b", String(err)
				done()

	describe ".handler()", ->
		it "is a function", ->
			assert.equal $.type($.Promise().handler), 'function'
		it "is an (err, data) callback", ->
			assert.equal $.Promise().handler.length, 2
		it "can resolve a promise", (done) ->
			p = $.Promise()
			p.handler(null, true)
			p.then -> done()
		it "can reject a promise", (done) ->
			p = $.Promise()
			p.handler(new Error(), null)
			p.wait (err) ->
				assert (err?)
				done()

describe "$.Progress", ->
	it "is a Promise", ->
		p = $.Progress()
		waiting = true
		p.wait (err, data) -> waiting = false
		p.resolve()
		assert.equal waiting, false
	describe "is an incremental Promise", ->
		p = $.Progress(10)
		_cur = _max = _done = 0
		p.on "progress", (cur, max) ->
			_cur = cur; _max = max
		p.wait (err, data) -> _done = data
		it "p.resolve(n) adjusts progress by n", ->
			p.resolve(1)
			assert.equal _cur, 1
			assert.equal _max, 10
		it "progress() with no args returns current progress", ->
			assert.equal p.progress(), _cur
		it "progress(cur) is a setter", ->
			p.progress(9)
			assert.equal p.progress(), 9
			assert.equal _done, 0
		it "completing progress resolves the Promise", ->
			p.progress(10)
			assert.equal _done, 10
		it "result of resolved Progress is the final progress value", (done) ->
			q = $.Progress(2)
			q.then (item) ->
				assert item is 'b'
				done()
			q.finish 1, 'a'
			q.finish 1, 'b'
		it "emits 'progress' events", ->
			a = $.Progress(2)
			data = []
			a.on 'progress', (cur, max) -> data.push [cur, max]
			a.resolve 1
			a.resolve 1
			assert.deepEqual data, [ [1,2], [2,2] ]
		describe ".include()", ->
			it "can include other promises", ->
				a = $.Progress(2)
				b = $.Promise()
				a.include(b)
				a.resolve 1
				a.resolve 1
				assert.equal a.resolved, false
				b.resolve()
				assert.equal a.resolved, true
			it "can include other progress", ->
				a = $.Progress(2)
				b = $.Progress(2)
				a.include(b)
				a.resolve 1
				a.resolve 1
				assert.equal a.resolved, false
				b.resolve 1
				assert.equal a.resolved, false
				b.resolve 1
				assert.equal a.resolved, true
			it "can include recursively", (ok) ->
				run = (level, cb) ->
					unless level > 0
						$.delay 10, cb
						return $.Promise().resolve()
					done = $.Progress(2)
					done.include run level-1, ->
						done.resolve(1)
						$.delay 10, ->
							assert.equal done.resolved, true, "done should be true"
					done.resolve(1)
					assert.equal done.resolved, false, "done should be false"
					$.delay 10, cb
					done
				run 5, ok
			describe "ignores", ->
				it "objects", (done) ->
					a = $.Progress(1)
					a.include({})
					a.then -> done()
					a.finish(1)
				it "strings", (done) ->
					a = $.Progress(1)
					a.include("a")
					a.then -> done()
					a.finish(1)
				it "undefined", (done) ->
					a = $.Progress(1)
					a.include(undefined)
					a.then -> done()
					a.finish(1)
				it "null", (done) ->
					a = $.Progress(1)
					a.include(null)
					a.then -> done()
					a.finish(1)
				it "arrays", (done) ->
					a = $.Progress(1)
					a.include([1,2,3])
					a.then -> done()
					a.finish(1)

