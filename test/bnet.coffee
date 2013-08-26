[$, assert] = require './setup'

cmp = (a, b) ->
	ta = $.type a, tb = $.type b
	assert.equal ta, tb
	switch ta
		when "number","string","bool","null","undefined" then assert.equal a, b
		when "array","bling","object" then assert.deepEqual a, b
		when "regex" then assert.equal a.toString(), b.toString()
		when "function"
			assert.equal a.toString().replace(/{\s+/m,'{').replace(/\s+}/m,'}'),
				a.toString().replace(/{\s+/m,'{').replace(/\s+}/m,'}')

describe "$.BNET", ->
	data = [
		42
		[2,0,"42#"]

		"foo"
		[3,0,"foo'"]

		true
		[1,0,1,"!"]

		false
		[1,0,0,"!"]

		null
		[0,"~"]

		undefined
		[0,"_"]

		[1,2,3]
		[12,0,1,0,"1#",1,0,"2#",1,0,"3#]"]

		$(1,2,3)
		[12,0,1,0,"1#",1,0,"2#",1,0,"3#$"]

		{a:1,b:2}
		[16,0,1,0,"a'",1,0,"1#",1,0,"b'",1,0,"2#}"]

		(x) -> x * x
		[25,0,0,"'",4,0,1,0,"x']",13,0,"return x * x;')"]

		/^f.*o$/
		[6,0,"^f.*o$/"]

		class sq then constructor: (x) -> x * x
		[21,0,2,0,"sq'",4,0,1,0,"x']",6,0,"x * x;')"]

		do -> # class instances
			class Foo
				sq: -> return @x * @x
			$.BNET.registerClass Foo
			f = new Foo()
			f.x = 4
			f
		[15,0,1,0,"1#",8,0,1,0,"x'",1,0,"4#}C"]

	]

	toCodes = (s) -> s.split(//).map (c) -> c.charCodeAt(0)
	explode = (a) -> $(a).map((x) -> switch
			when $.is 'number', x then x
			else toCodes x
		).flatten()
	
	# prepare the data
	for _,i in data by 2
		data[i+1] = explode data[i+1]

	describe "stringify", ->
		for item, i in data by 2 then do (item, i) ->
			it "handles #{$.type item}", ->
				expected = data[i+1]
				output = toCodes $.BNET.stringify(item)
				assert.deepEqual output, expected
	
	describe "parse", ->
		for item, i in data by 2 then do (item, i) ->
			it "handles #{$.type item}", ->
				input = data[i+1].map((n) -> String.fromCharCode n).join ''
				output = $.BNET.parse input
				cmp output, item
	
	describe "round-trip", ->
		for item, i in data by 2 then do (item, i) ->
			it "converts #{$.type item}", ->
				cmp item, $.BNET.parse $.BNET.stringify item

