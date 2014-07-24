module.exports = [
	require '../dist/min.bling.js'
	require 'assert'
	require 'fs'
]

$.units.enable()

$.bench = (label, func) ->
	n = 0
	elapsed = 0
	while elapsed < 3000
		start = $.now
		do func
		elapsed += $.now - start
		n += 1
	ms = "#{elapsed/n}ms"
	ns = $.units.convertTo("ns", ms)
	ns = $.commaize parseInt(ns, 10)
	ms = $.commaize parseFloat(ms).toFixed(4)
	console.log "[#{label}] #{ns}ns (#{ms}ms) per operation"

