[$, assert] = require './setup'

describe "PubSub plugin:", ->
	it "defines $.Hub", ->
		assert typeof $.Hub is "function"
	it "puts a root Hub on $ itself", ->
		assert typeof $.publish is "function"
		assert typeof $.subscribe is "function"
	it "can create new Hubs", ->
		h = new $.Hub()
		assert typeof $.publish is "function"
		assert typeof $.subscribe is "function"
	it "implements the pubsub protocol", ->
		h = new $.Hub()
		pass = false
		h.subscribe 'test-channel', -> pass = true
		h.publish 'test-channel'
		assert pass
	it "passes along published data", ->
		h = new $.Hub()
		pass = false
		h.subscribe 'test-channel', (data) -> pass = data
		h.publish 'test-channel', true
		assert pass
	it "the root behaves like a global Hub", ->
		pass = false
		$.subscribe 'test-channel', (data) -> pass = data
		$.publish 'test-channel', true
		assert pass
	it "doesn't crash if one listeners fails", (done) ->
		pass = false
		$.subscribe 'fail-channel', (data) -> throw "failed!"
		$.subscribe 'fail-channel', (data) -> pass = data
		try $.publish 'fail-channel', true
		catch err
			assert.equal err, "failed!" # the error still gets thrown
			assert pass # but not before all the non-failing listeners attempt to run
			done()
	describe ".subscribe()", ->
		hub = new $.Hub()
		it "attaches basic listeners to a channel", ->
			pass = false
			hub.subscribe "chan", (data) -> pass = data
			hub.publish "chan", true
			assert pass
		it "accepts an optional pattern object", ->
			pass = 0
			hub.subscribe "chan", { op: /oo$/ }, (obj) ->
				pass += obj.data
			hub.publish "chan", { op: "bar", data: 1 }
			hub.publish "chan", { op: "foo", data: 2 }
			assert.equal pass, 2

	describe ".unsubscribe()", ->
		hub = new $.Hub()
		it "can unsub a single listener", ->
			f = ->
			hub.subscribe("chan", f)
			assert.deepEqual hub.listeners["chan"], [ f ]
			hub.unsubscribe("chan", f)
			assert.notEqual hub.listeners["chan"][0], f
		it "can unsub all listeners at once", ->
			hub.subscribe("chan", ->)
			hub.subscribe("chan", ->)
			assert.equal hub.listeners["chan"].length, 2
			hub.unsubscribe "chan"
			assert.equal hub.listeners["chan"].length, 0
