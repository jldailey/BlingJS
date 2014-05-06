[ $, assert ] = require './setup'

$.bench 'Promise: new', -> new $.Promise()
$.bench 'Promise: 10,000 waiting', ->
	sum = 0
	handler = (err, data) -> sum += data
	p = new $.Promise()
	for _ in [0...10000]
		p.wait handler
	p.resolve 1
	assert.equal sum, 10000
