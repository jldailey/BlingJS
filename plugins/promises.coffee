(($) ->
	$.plugin () -> # Promises plugin
		Promise = (steps = 1) ->
			@steps = steps
			@state = 0 # 0 is unfulfilled, > 0 is in progress, eq to steps is done, -1 is cancelled, -2 is error
			@value = null
			fs = []
			es = []
			ps = []
			@then = (f, e, p) =>
				if @state is @steps
					return f(@value)
				else
					fs.push f
				if @state is -2
					return e(@value)
				else
					es.push e
				ps.push p if Object.IsFunc p

			@cancel = () =>
				fs = []
				es = []
				ps = []
				@state = -1

			@fulfill = (v) =>
				@state += 1
				@value = v
				if Object.Type(v) is "error"
					@state = -2
					while f = es.pop()
						f(v)
				else
					if @state is steps
						while f = fs.pop()
							f(v)
					else
						for p in ps
							p(@state, ste

		return {
			name: "Promises"
		}
)(Bling)
# vim: ft=coffee
