[$, assert] = require './setup'

describe "$.CSS", ->
	describe ".stringify", ->
		it "renders nested objects as css text", ->
			assert.equal $.CSS.stringify(a: { w: 1, " b": { h: 1 }}), "a { w: 1; } a b { h: 1; }"
	describe ".parse", ->
		it "parses CSS into nested objects", ->
			assert.deepEqual $.CSS.parse("a { w: 1; } a b { h: 1; }", true), {
				a: { w: 1, " b": { h: 1 } }
			}
		it "semi-colon is optional", ->
			assert.deepEqual $.CSS.parse("a { w: 1 }"), { a: { w: 1 } }
		it "merges nested rules", ->
			assert.deepEqual $.CSS.parse("a b { w: 1; }", true), {
				"a b": { w: 1 }
			}
		it "merges deeply nested rules", ->
			assert.deepEqual $.CSS.parse("a b c d { w: 1; }", true), {
				"a b c d": { w: 1 }
			}
		it "does not always merge nested rules", ->
			assert.deepEqual $.CSS.parse("a { w: 1; } a b c d { h: 1; }", true), {
				a: {
					w: 1
					" b c d": {
						h: 1
					}
				}
			}
		it "parses realistic CSS", ->
			assert.deepEqual $.CSS.parse("""
				body {
					background: url(/img/factory.png);
					margin: 0;
					padding: 0;
				}
				#projects {
					font-weight: bold;
					line-height: 24px;
					/* no comment */
				}
				#projects h1 {
					font-size: 28px;
				}
				#projects h1 + ul {
					list-style: none;
				}
			""", true), {
				body:
					background: "url(/img/factory.png)"
					margin: "0"
					padding: "0"
				"#projects":
					"font-weight": "bold"
					"line-height": "24px"
					" h1":
						"font-size": "28px"
						" + ul":
								"list-style": "none"
			}
		it "lets you turn off compacted output", ->
			assert.deepEqual $.CSS.parse("a { w: 0 } a b { w: 1; }", false),
				{ a: { w: 0 }, "a b": { w: 1 } }
