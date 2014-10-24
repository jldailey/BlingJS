$.plugin
	provides: "StateMachine"
	depends: "type"
, ->
	$: StateMachine: class StateMachine # see plugins/synth for a complete usage example
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
		GO: go = (m, enter=false) -> ->
			if enter # force enter to trigger
				@_mode = null
			@mode = m
		@GO: go

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

