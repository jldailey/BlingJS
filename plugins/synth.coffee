$.plugin
	provides: "StateMachine"
, ->
	$: StateMachine: class StateMachine
		constructor: (stateTable) ->
			@debug = false
			@reset()
			@table = stateTable
			Object.defineProperty @, "modeline",
				get: -> @table[@_mode]
			Object.defineProperty @, "mode",
				set: (m) ->
					@_lastMode = @_mode
					@_mode = m
					if @_mode isnt @_lastMode and @modeline? and 'enter' of @modeline
						ret = @modeline['enter'].call @
						while $.is("function",ret)
							ret = ret.call @
					m
				get: -> @_mode

		reset: ->
			@_mode = null
			@_lastMode = null

		# static and instance versions of a state-changer factory
		GO: (m) -> -> @mode = m
		@GO: (m) -> -> @mode = m
		
		tick: (c) ->
			row = @modeline
			if not row?
				ret = null
			else if c of row
				ret = row[c]
			else if 'def' of row
				ret = row['def']
			while $.is "function",ret
				ret = ret.call @, c
			ret

		run: (inputs) ->
			@mode = 0
			for c in inputs
				ret = @tick(c)
			if $.is "function",@modeline?.eof
				ret = @modeline.eof.call @
			while $.is "function",ret
				ret = ret.call @
			@reset()
			return @

$.plugin
	provides: "synth"
	depends: "StateMachine, type"
, ->
	class SynthMachine extends $.StateMachine
		basic =
			"#": @GO 2
			".": @GO 3
			"[": @GO 4
			'"': @GO 6
			"'": @GO 7
			" ": @GO 8
			",": @GO 10
			"+": @GO 11
			eof: @GO 13

		@STATE_TABLE = [
			{ # 0: START
				enter: ->
					@tag = @id = @cls = @attr = @val = @text = ""
					@attrs = {}
					@GO 1
			},
			$.extend({ # 1: read a tag name
				def: (c) -> @tag += c
			}, basic),
			$.extend({ # 2: read an #id
				def: (c) -> @id += c
			}, basic),
			$.extend({ # 3: read a .class name
				enter: -> @cls += " " if @cls.length > 0
				def: (c) -> @cls += c
			}, basic),
			{ # 4: read an attribute name (left-side)
				"=": @GO 5
				"]": -> @attrs[@attr] = @val; @GO 1
				def: (c) -> @attr += c
				eof: @GO 12
			},
			{ # 5: read an attribute value (right-side)
				"]": -> @attrs[@attr] = @val; @GO 1
				def: (c) -> @val += c
				eof: @GO 12
			},
			{ # 6: read double-quoted text
				'"': @GO 8
				def: (c) -> @text += c
				eof: @GO 12
			},
			{ # 7: read single-quoted text
				"'": @GO 8
				def: (c) -> @text += c
				eof: @GO 12
			},
			{ # 8: emit text and continue
				enter: ->
					@emitNode() if @tag
					@emitText() if @text
					@GO 0
			},
			{}, # 9: empty
			{ # 10: emit node and start a new tree
				enter: ->
					@emitNode()
					@cursor = null
					@GO 0
			},
			{ # 11: emit node and step sideways to create a sibling
				enter: ->
					@emitNode()
					@cursor = @cursor?.parentNode
					@GO 0
			},
			{ # 12: ERROR
				enter: -> throw new Error "Error in synth expression: #{@input}"
			},
			{ # 13: FINALIZE
				enter: ->
					@emitNode() if @tag
					@emitText() if @text
			}
		]
		constructor: ->
			super(SynthMachine.STATE_TABLE)
			@fragment = @cursor = document.createDocumentFragment()
		emitNode: ->
			if @tag
				node = document.createElement @tag
				node.id = @id or null
				node.className = @cls or null
				for k of @attrs
					node.setAttribute k, @attrs[k]
				@cursor.appendChild node
				@cursor = node
		emitText: ->
			@cursor.appendChild $.type.lookup("<html>").node(@text)
			@text = ""

	return {
		$:
			synth: (expr) ->
				# .synth(expr) - create DOM nodes to match a simple css expression
				s = new SynthMachine()
				s.run(expr)
				if s.fragment.childNodes.length == 1
					$(s.fragment.childNodes[0])
				else
					$(s.fragment)
	}
