require("coffee-script")
dom = require("jldom")
dom.registerGlobals(global)
global.document = dom.createDocument()
global.window = global
require("../dist/bling.js")

$.testGroup "Test Internals",
	true: -> true
	trueFail: (cb) -> cb true
	trueAsync: (cb) -> setTimeout (-> cb false), 100
	trueAsyncFail: (cb) -> setTimeout (-> cb true), 200
	assert: -> $.assert true, "this will not display"
	asyncFail: (callback) ->
		setTimeout (->callback new Error("delayed error")), 500
	assertFail: (cb) ->
		$.assert false, "this will throw an exception, but is expected"
	async1: (callback) ->
		setTimeout (-> callback false), 300
	asyncDepends: (callback) ->
		$.depends 'async1', -> callback false

