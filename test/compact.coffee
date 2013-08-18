[ $, assert ] = require './setup'

describe "Compact", ->
	describe "basic markup:", ->
		describe "text", ->
			it "renders strings in a language", ->
				assert.equal $.compact({t:"text",EN:"A"}, { lang: "EN" }), "A"
			it "selects one language from several", ->
				assert.equal $.compact({ t: "text", EN: "A", FR: "B" }, { lang: "FR" }), "B"
		it "link", ->
			assert.equal $.compact({t:"link",href:"#home",content:"Home"}),
				"<a href='#home'>Home</a>"
	describe "logic stuff:", ->
		describe "let", ->
			it "assigns a scoped value", ->
				assert.equal $.compact({ t: "let", name: "x", value: "foo", content: [
					{ t: "get", name: "x" }
				]}), "foo"
			it "supports complex values", ->
				assert.equal $.compact(
					{ t: "let", name: "x", value: { t: "text", EN: "foo" }, content: [
							{ t: "get", name: "x" }
						]
					}, { lang: "EN" }), "foo"
			it "supports nesting scopes", ->
				assert.equal $.compact(
					{ t: "let", name: "y", value: "foo", content: [
						{ t: "let", name: "y", value: "bar", content: [
							{ t: "get", name: "y" }
						] },
					] }, { lang: "EN" }), "bar"

