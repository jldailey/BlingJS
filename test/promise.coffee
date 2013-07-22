[$, assert] = require './setup'

describe "$.Promise()", ->
	p = $.Promise()
	pass = false
	it "can be waited on", ->
		p.wait (err, data) -> pass = data
	it "can be finished", ->
		p.finish true
	it "passes the finished data to listeners", ->
		assert pass
	it "calls back instantly if already finished", ->
		pass = false
		p.wait (err, data) -> pass = data
		assert pass
	it "can be checked", ->
		assert.equal $.Promise().finished, false
		assert.equal $.Promise().finish().finished, true
		assert.equal $.Promise().failed, false
		assert.equal $.Promise().fail().failed, true
	it "can be reset", ->
		pass = false
		p.reset()
		p.wait (err, data) -> pass = data
		assert.equal pass, false # not fired yet
		p.finish(true)
		assert pass
	it "clears callbacks after fire", ->
		id = 0
		p.wait (err, data) -> id += data # handler A
		p.finish 1
		p.wait (err, data) -> id += data # handler B
		p.finish 1
		assert.equal id, 2 # if handler A or B ran more than once, id would be >= 3

	it "ignores more than one call to .finish()", ->
		pass = 1
		a = $.Promise().wait -> pass += pass
		a.finish()
		a.finish()
		assert.equal pass, 2 # not 4, if it had run twice

	it "ignores more than one call to .fail()", ->
		pass = 1
		a = $.Promise().wait (err, data) -> pass += err
		a.fail pass
		a.fail pass
		assert.equal pass, 2 # not 4, if it had run twice

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
	describe ".join()", ->
		it "joins one promise to another", ->
			pass = false
			a = $.Promise()
			a.wait (err, data) -> pass = data
			b = $.Promise()
			a.join b
			b.finish true
			assert pass
	describe ".compose()", ->
		it "composes promises", ->
			pass = false
			a = $.Promise()
			b = $.Promise()
			c = $.Promise.compose(a, b).wait -> pass = true
			a.finish()
			b.finish()
			assert pass

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
					$.immediate cb
					return $.Promise().finish()
				done = $.Progress(2)
				done.include run level-1, ->
					done.finish(1)
					assert.equal done.finished, true
				done.finish(1)
				assert.equal done.finished, false
				$.immediate cb
				done
			run 5, ok

