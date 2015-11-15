$.plugin
	provides: "StateMachine"
	depends: "type, logger"
, ->
	_callAll = (f, c, arg) ->
		while $.is 'function', f
			f = f.call c, arg
		if $.is 'number', f
			c.state = f	
	
	log = $.logger "[StateMachine]"

	$: StateMachine: class StateMachine # see plugins/synth for a complete usage example
		constructor: (@table) ->
			state = null
			$.defineProperty @, "state",
				set: (m) ->
					if m isnt state and m of @table
						_callAll @table[state = m].enter, @
					else if m is null
						state = null
					state
				get: -> state

		# static and instance versions of a state-changer factory
		goto: go = (m, reset=false) -> ->
			if reset # force enter: to trigger
				@state = null
			@state = m
		@goto: go

		tick: (c) ->
			row = @table[@state]
			return null unless row?
			_callAll (row[c] ? row.def), @, c

		run: (inputs) ->
			# run the enter: rule for state 0
			@state = 0
			# run all the inputs through the machine
			@tick(c) for c in inputs
			# run the eof: rule for the final state
			_callAll @table[@state].eof, @
			@

