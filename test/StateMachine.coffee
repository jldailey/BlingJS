[$, assert] = require './setup'

describe ".StateMachine", ->
	it "allows subclassing to define machines", ->
		class T extends $.StateMachine
		t = new T
		assert $.is 'function', t.run
	describe ".run()", ->
		it "reads input and rules from @STATE_TABLE", ->
			class Capper extends $.StateMachine
				@STATE_TABLE = [
					{
						enter: ->
							@output = "<<"
							@GO 1
					}
					{
						def: (c) -> @output += c.toUpperCase()
						eof: @GO 2
					}
					{
						enter: -> @output += ">>"
					}
				]
				constructor: ->
					super(Capper.STATE_TABLE)

			assert.equal new Capper().run("hello").output, "<<HELLO>>"

