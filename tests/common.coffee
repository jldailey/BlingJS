global.assert = (c, msg) ->
	if not c
		throw Error msg
global.assertEqual = (a, b, label) ->
	if a != b
		throw Error "#{label or ''} (#{a?.toString()}) should equal (#{b?.toString()})"
global.assertArrayEqual = (a, b, label) ->
	for i in [0...a.length]
		try
			assertEqual(a[i], b[i], label)
		catch err
			throw Error "#{label or ''} #{a?.toString()} should equal #{b?.toString()}"

require("coffee-script")
dom = require("jldom")
dom.registerGlobals(global)
global.document = dom.createDocument()
global.window = global
require("../dist/bling.js")
Bling.plugin
	provides: "assert"
, ->
	return {
		assert: (msg, func) ->
			if msg and not func?
				func = msg
				msg = ""
			global.assert func.call @,@
			return @
		assertEqual: (args...) ->
			if args.length > 1 # short-cut the trivial cases
				args = args.map (x) => # call any functions passed as arguments
					if $.is "function", x then x.call(@,@) else x
				a = args[0]
				for i in [1...args.length]
					global.assertEqual a,args[i]
			return @
	}

UI =
	dumb: # a dumb terminal
		output: (a...) -> console.log.apply console, a
		red: ""
		green: ""
		yellow: ""
		normal: ""
	cterm: # a color terminal
		output: (a...) -> console.log.apply console, a
		red: "[0;31;40m"
		green: "[0;32;40m"
		yellow: "[0;33;40m"
		normal: "[0;37;40m"
	html: # an html document
		output: (a...) -> document.write a.join(' ')+"<br>"
		red: "<font color='red'>"
		green: "<font color='green'>"
		yellow: "<font color='yellow'>"
		normal: "</font>"

# pick an output UI
global.ui = switch process?.env.TERM
	when "dumb" then UI.dumb
	when undefined then UI.html
	else UI.cterm

argv = process?.argv
if argv and argv.length > 2
	test_to_run = argv[2]
else
	test_to_run = "*"

# counters for test total/pass/fail
total = [0,0,0]
failures = []
global.testGroup = (name, tests) ->
	failed = passed = 0
	for test_name of tests
		if test_to_run in ["*", test_name, name]
			test = tests[test_name]
			total[0] += 1
			try
				if test_to_run isnt "*"
					console.log "Running test:"
					console.log test.toString()
				test()
				passed += 1
				total[1] += 1
				ui.output "#{name}_#{test_name}...#{ui.green}ok#{ui.normal}"
			catch err
				ui.output "#{name}_#{test_name}...#{ui.red}fail:#{ui.normal} '#{err.toString()}'"
				failed += 1
				total[2] += 1
				failures.push(test_name)
				if test_to_run isnt "*"
					throw err
		# ui.output "#{ui.green}Pass: #{passed}#{ui.normal}" +
			# ( if failed > 0 then "#{ui.yellow}/#{passed+failed}#{ui.normal}#{ui.red} Fail: #{failed}#{ui.normal} [ #{failures.join(', ')} ]" else "" )
global.testReport = () ->
	ui.output "#{total[0]} Tests, #{total[1]} Passed, #{total[2]} Failed: [ #{failures.join(', ')} ]"

testGroup("Testing Framework"
	pass: () -> true
)
