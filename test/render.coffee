[ $, assert ] = require './setup'

expect = (value, done) -> (err, result) -> assert.equal result, value; done()

describe "Compact", ->
	describe "renders basic types as string:", ->
		it "strings", (done) ->
			$.render("Hello").wait expect "Hello", done
		it "numbers", (done) ->
			$.render(42).wait expect "42", done
		it "floats", (done) ->
			$.render(1/3).wait expect "0.3333333333333333", done
		describe "arrays of", ->
			it "strings", (done) ->
				$.render(["He","llo"]).wait expect "Hello", done
			it "numbers", (done) ->
				$.render([1,2,3]).wait expect "123", done
			it "arrays", (done) ->
				$.render([1,[2,[3]]]).wait expect "123", done
			it "mixed", (done) ->
				$.render(["a",1,1/4,["c"]]).wait expect "a10.25c", done
	describe "renders objects based on .t property", ->

		it "can register new handlers", (done) ->
			$.render.register 'testing', (o, opts) -> "magic"
			$.render({ t: "testing" }).wait expect "magic", done

		describe "built-in handlers", ->
			it "multi-lingual text", (done) ->
				$.render( { t: "text", EN: "Hello", FR: "Bonjour" }, { lang: "FR" }).wait(
					expect "Bonjour", done
				)
			describe "scoped assignment", ->
				it "assigns variables", (done) ->
					$.render({ t: "let", name: "x", value: "foo", content: [
						{ t: "get", name: "x" }
					]}).wait expect "foo", done
				it "supports nesting", (done) ->
					$.render(
						{ t: "let", name: "y", value: "foo", content: [
							{ t: "let", name: "y", value: "bar", content: [
								{ t: "get", name: "y" }
							] },
							{ t: "get", name: "y" }
						] }, { lang: "EN" }).wait expect "barfoo", done
			it "anchor tags (links)", (done) ->
				$.render({ t:"link", href:"#home", content:"Home" }).wait(
					expect "<a href='#home'>Home</a>", done
				)

