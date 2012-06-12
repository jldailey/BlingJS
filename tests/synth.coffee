
common = require('./common')

testGroup("StateMachine",
	hello: ->
		class TestMachine extends $.StateMachine
			@STATE_TABLE = [
				{ # 0
					enter: ->
						@output = "<"
						@GO(1)
				}
				{ # 1
					def: (c) -> @output += c.toUpperCase()
					eof: @GO(2)
				}
				{ # 2
					enter: -> @output += ">"
				}
			]
			constructor: ->
				super(TestMachine.STATE_TABLE)
				@output = ""
		m = new TestMachine()
		assertEqual(m.run("hello").output, "<HELLO>")
		assertEqual(m.run("hi").output, "<HI>")
)

testGroup("Synth",
	basic_node: -> assertEqual($.synth("style").toString(), "$([<style/>])")
	id_node: -> assertEqual($.synth('style#specialId').toString(), '$([<style id="specialId"/>])')
	class_node: -> assertEqual($.synth('style.specClass').toString(), '$([<style class="specClass"/>])')
	attr_node: -> assertEqual($.synth('style[foo=bar]').toString(), '$([<style foo="bar"/>])')
	combo_node: -> assertEqual($.synth("style[a=b].c#d").toString(), '$([<style id="d" class="c" a="b"/>])')
	text: -> assertEqual($.synth("style 'text'").toString(), "$([<style>text</style>])")
	entity1: -> assertEqual($.synth("style 'text&amp;stuff'").toString(), "$([<style>text&amp;stuff</style>])")
	entity2: -> assertEqual($.synth("style 'text&stuff'").toString(), "$([<style>text&stuff</style>])")
)

testReport()

