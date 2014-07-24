[$, assert] = require './setup'

describe ".config(name, def)", ->
	it "gets config from the environment", ->
		try
			process.env.UNIT_TEST_MAGIC = "magic"
			assert.equal $.config.get("UNIT_TEST_MAGIC"), "magic"
		finally
			delete process.env.UNIT_TEST_MAGIC
	it "supports a default value", ->
		assert.equal $.config.get("NOT_FOUND", "default"), "default"
	it "can be called directly", ->
		assert.equal $.config("NOT_FOUND", "default"), "default"
	it "can parse and set values from string data", ->
		assert.deepEqual $.config.parse("""NO_LEAD='no leading whitespace'
			LEADING='ignores leading whitespace'
			NOQUOTES=does not require any quotes
		"""), {
				NO_LEAD: "no leading whitespace"
				LEADING: "ignores leading whitespace"
				NOQUOTES: "does not require any quotes"
			}
	
