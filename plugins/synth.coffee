$.plugin
	provides: "synth"
	depends: "StateMachine, type, dom"
, ->
	class SynthMachine extends $.StateMachine
		common = # a common template included in lots of the state machine rules
			"#":  -> 2
			".":  @goto 3, true
			"[":  -> 4
			'"':  -> 6
			"'":  -> 7
			" ":  -> 8
			"\t": -> 8
			"\n": -> 8
			"\r": -> 8
			",":  -> 10
			"+":  -> 11
			eof:  -> 13

		@STATE_TABLE = [
			{ # 0: START
				enter: ->
					@tag = @id = @cls = @attr = @val = @text = ""
					@attrs = {}
					1
			},
			$.extend({ # 1: read a tag name
				def: (c) -> @tag += c; 1
			}, common),
			$.extend({ # 2: read an #id
				def: (c) -> @id += c; 2
			}, common),
			$.extend({ # 3: read a .class name
				enter: -> @cls += " " if @cls.length > 0; 3
				def: (c) -> @cls += c; 3
			}, common),
			{ # 4: read an attribute name (left-side)
				"=": -> 5
				"]": -> @attrs[@attr] = @val; @attr = @val = ""; 1
				def: (c) -> @attr += c; 4
				eof: -> 12
			},
			{ # 5: read an attribute value (right-side)
				"]": -> @attrs[@attr] = @val; @attr = @val = ""; 1
				def: (c) -> @val += c; 5
				eof: -> 12
			},
			{ # 6: read double-quoted text
				'"': -> 8
				def: (c) -> @text += c; 6
				eof: -> 12
			},
			{ # 7: read single-quoted text
				"'": -> 8
				def: (c) -> @text += c; 7
				eof: -> 12
			},
			{ # 8: emit text and continue
				enter: ->
					@emitNode()
					@emitText()
					0
			},
			{}, # 9: empty
			{ # 10: emit node and start a new tree
				enter: ->
					@emitNode()
					@cursor = null
					0
			},
			{ # 11: emit node and step sideways to create a sibling
				enter: ->
					@emitNode()
					@cursor = @cursor?.parentNode
					0
			},
			{ # 12: ERROR
				enter: -> throw new Error "Error in synth expression: #{@input}"
			},
			{ # 13: FINALIZE
				enter: ->
					@emitNode()
					@emitText()
					0
			}
		]
		constructor: ->
			super(SynthMachine.STATE_TABLE)
			@reset()
		reset: ->
			@fragment = @cursor = document.createDocumentFragment()
			@tag = @id = @cls = @attr = @val = @text = ""
			@attrs = {}
		emitNode: ->
			if @tag
				node = document.createElement @tag
				if @id then node.id = @id
				if @cls then node.className = @cls
				for k of @attrs
					node.setAttribute k, @attrs[k]
				@cursor.appendChild node
				@cursor = node
		emitText: ->
			if @text?.length > 0
				@cursor.appendChild $.type.lookup("<html>").node(@text)
				@text = ""


	machine = new SynthMachine()
	return {
		$:
			synth: (expr) ->
				# .synth(expr) - create DOM nodes to match a simple css expression
				machine.reset()
				machine.run(expr)
				if machine.fragment.childNodes.length == 1
					$(machine.fragment.childNodes[0])
				else
					$(machine.fragment)
	}
