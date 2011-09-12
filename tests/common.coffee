global.assert = (c, msg) ->
	if not c
		throw Error msg
global.assertEqual = (a, b, label) ->
	if a isnt b
		throw Error "#{label or ''} (#{a?.toString()}) should equal (#{b?.toString()})"
global.assertArrayEqual = (a, b, label) ->
	for i in [0...a.length]
		try
			assertEqual(a[i], b[i], label)
		catch err
			throw Error "#{label or ''} #{a?.toString()} should equal #{b?.toString()}"

dom = require("./domjs/dom")
dom.registerGlobals(global)
global.document = dom.createDocument()
global.window = global
require("../bling.coffee")


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
				test()
				passed += 1
				total[1] += 1
				ui.output "#{name}_#{test_name}...ok"
			catch err
				ui.output "#{name}_#{test_name}...fail: '#{err.toString()}'"
				failed += 1
				total[2] += 1
				failures.push(test_name)
		# ui.output "#{ui.green}Pass: #{passed}#{ui.normal}" +
			# ( if failed > 0 then "#{ui.yellow}/#{passed+failed}#{ui.normal}#{ui.red} Fail: #{failed}#{ui.normal} [ #{failures.join(', ')} ]" else "" )
global.testReport = () ->
	ui.output "Total: #{total[0]} Passed: #{total[1]} Failed: #{total[2]} [ #{failures.join(', ')} ]"

testGroup("Testing Framework"
	pass: () -> true
)
