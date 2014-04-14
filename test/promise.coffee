[$, assert] = require './setup'

describe "$.Promise()", ->
	describe "wait", ->
		it "queues a callback", (done) ->
			$.Promise().wait((err, data) -> done(err)).finish()
		it "calls back in a later tick if already finished", (done) ->
			output = null
			$.Promise().finish("magic").wait (err, data) ->
				output = data
			# it does not fire yet
			assert.equal output, null
			$.delay 20, ->
				assert.equal output, "magic"
				done()
	describe "finish", ->
		it "passes data to queued callbacks", (done) ->
			$.Promise().wait((err, data) ->
				if data isnt "magic"
					done "failed: no magic!"
				else done()
			).finish "magic"
		it "ignores repeated calls", ->
			count = 1
			a = $.Promise().wait -> count += count
			a.finish()
			a.finish()
			assert.equal count, 2 # not 4, if it had run twice
		describe "optional timeout", ->
			it "sets error to 'timeout'", (done) ->
				$.Promise().wait 100, (err, data) ->
					assert.equal err, 'timeout'
					done()
			it "does not fire an error if the promise is finished in time", (done) ->
				pass = false
				$.Promise().wait(100, (err, data) ->
					assert.equal err, null
					pass = data
				).finish true
				$.delay 200, ->
					assert.equal pass, true
					done()
	describe "fail", ->
		it "passes errors to queued callbacks", (done) ->
			$.Promise().wait((err, data) ->
				if err isnt "fizzle"
					done "failed: no fizzle!"
				else done()
				).fail "fizzle"
		it "ignores repeated calls", ->
			pass = 1
			a = $.Promise().wait (err, data) -> pass += err
			a.fail pass
			a.fail pass
			assert.equal pass, 2 # not 4, if it had run twice
	describe "reset", ->
		it "resets", ->
			rp = $.Promise()
			count = 0
			rp.wait (err, data) -> count += data
			rp.finish 1
			assert.equal count, 1
			rp.reset()
			rp.wait (err, data) -> count += data
			rp.finish 1
			assert.equal count, 2 # if it's 1 then the second waiter never fired
			# if it's 3 then the first waiter fired twice
	describe "status flags", ->
		it "finished", ->
			assert.equal $.Promise().finished, false
			assert.equal $.Promise().finish().finished, true
		it "failed", ->
			assert.equal $.Promise().failed, false
			assert.equal $.Promise().fail().failed, true

	describe "inheritance", ->
		it "works with default constructor", ->
			class Foo extends $.Promise
			f = new Foo()
			f.wait (err, data) -> f.pass = data
			f.finish true
			assert.equal f.pass, true
		it "works with super", ->
			class Foo extends $.Promise
				constructor: (@pass) -> super @
			f = new Foo(false)
			f.wait (err, data) -> f.pass = data
			f.finish true
			assert f.pass
	describe ".compose()", ->
		it "composes promises", ->
			pass = false
			a = $.Promise()
			b = $.Promise()
			c = $.Promise.compose(a, b).wait -> pass = true
			a.finish()
			b.finish()
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
			b.finish('b')
			c.finish('c')
			a.finish('a')
		it "can mix errors and results, in order", (done) ->
			a = $.Promise()
			b = $.Promise()
			c = $.Promise()
			$.Promise.collect([a,b,c]).then (list) ->
				assert.deepEqual list, ['a','err_b','c']
				done()
			b.fail("err_b")
			c.finish('c')
			a.finish('a')

describe "$.Progress", ->
	it "is a Promise", ->
		p = $.Progress()
		waiting = true
		p.wait (err, data) -> waiting = false
		p.finish()
		assert.equal waiting, false
	describe "is an incremental Promise", ->
		p = $.Progress(10)
		_cur = _max = _done = 0
		p.on "progress", (cur, max) ->
			_cur = cur; _max = max
		p.wait (err, data) -> _done = data
		it "p.finish(n) adjusts progress by n", ->
			p.finish(1)
			assert.equal _cur, 1
			assert.equal _max, 10
		it "progress() with no args returns current progress", ->
			assert.equal p.progress(), _cur
		it "progress(cur) is a setter", ->
			p.progress(9)
			assert.equal p.progress(), 9
			assert.equal _done, 0
		it "completing progress finishes the Promise", ->
			p.progress(10)
			assert.equal _done, 10
		it "result of finished Progress is the final progress value", ->
			p.progress(11.1)
			assert.equal _done, 10 # the value at the time it was completed
		it "emits 'progress' events", ->
			a = $.Progress(2)
			data = []
			a.on 'progress', (cur, max) -> data.push [cur, max]
			a.finish 1
			a.finish 1
			assert.deepEqual data, [ [1,2], [2,2] ]
		it "can 'include' other promises", ->
			a = $.Progress(2)
			b = $.Promise()
			a.include(b)
			a.finish 1
			a.finish 1
			assert.equal a.finished, false
			b.finish()
			assert.equal a.finished, true
		it "can 'include' other progress", ->
			a = $.Progress(2)
			b = $.Progress(2)
			a.include(b)
			a.finish 1
			a.finish 1
			assert.equal a.finished, false
			b.finish 1
			assert.equal a.finished, false
			b.finish 1
			assert.equal a.finished, true
		it "can 'include' recursively", (ok) ->
			run = (level, cb) ->
				unless level > 0
					$.delay 10, cb
					return $.Promise().finish()
				done = $.Progress(2)
				done.include run level-1, ->
					done.finish(1)
					$.delay 10, ->
						assert.equal done.finished, true, "done should be true"
				done.finish(1)
				assert.equal done.finished, false, "done should be false"
				$.delay 10, cb
				done
			run 5, ok

