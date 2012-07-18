(($) ->
	$.plugin
		provides: "unittest"
		depends: "core"
	, ->
		testCount = passCount = failCount = 0
		failed = []
		invokeTest = (group, name, func) ->
			return if not $.is "function", func
			_log = (msg) -> $.log "#{group}: #{name}... #{msg}"
			# tests with 'fail' in the name are expected to fail
			shouldFail = name.toLowerCase().indexOf("fail") isnt -1
			done = $.once (err) ->
				testCount--
				if (!!err isnt shouldFail)
					_log "fail: #{err}"
					failCount++
					failed.push name
				else
					_log "pass"
					passCount++
					$.provide name
			f = (done) ->
				try func(done)
				catch err then done(err)
				finally
					# tests with 'async' in the name dont finish immediately
					if name.toLowerCase().indexOf("async") is -1 then done()
			testCount++
			try f(done)
			catch err then done(err)

		testReport = $.once ->
			$.log "Passed: #{passCount} Failed: #{failCount} [#{failed}]"

		$:
			approx: (a, b, margin=.1) -> Math.abs(a - b) < margin
			assert: (cnd, msg = "no message") -> if not cnd then throw new Error "Assertion failed: #{msg}"
			assertEqual: (a, b, label) ->
				if a != b
					throw Error "#{label or ''} (#{a?.toString()}) should equal (#{b?.toString()})"
			assertArrayEqual: (a, b, label) ->
				for i in [0...a.length]
					try
						$.assertEqual(a[i], b[i], label)
					catch err
						throw Error "#{label or ''} #{a?.toString()} should equal #{b?.toString()}"
			testGroup: (name, funcs) ->
				interval = setInterval (-> if testCount is 0 then clearInterval(interval); testReport()), 50
				for k,func of funcs
					invokeTest(name, k, func)
		assertEqual: (args...) ->
			if args.length > 1 # short-cut the trivial cases
				args = args.map (x) => # call any functions passed as arguments
					if $.is "function", x then x.call(@,@) else x
				a = args[0]
				for i in [1...args.length]
					$.assertEqual a, args[i]
			return @
)(Bling)
