[$, assert] = require './setup'

describe "$.histogram(data)", ->
	it "draws a histogram", ->
		assert $.is 'string', $.histogram( [1,2,3,4,5] )
	it "can get real", ->
		assert $.is 'string', $.histogram $.ones(1000).map(-> $.random.gaussian .65, .07), .01
	
