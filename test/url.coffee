[$, assert] = require './setup'

describe '$.URL', ->
	describe ".parse(string)", ->
		testData = [
			"proto://host",
			{ protocol: "proto", host: "host" },

			"http://blingjs.com/js/bling.js?ts=1234",
			{ protocol: "http", host: "blingjs.com", path: "/js/bling.js", query: "ts=1234" }

			"ws://localhost:3030",
			{ protocol: "ws", host: "localhost", port: "3030" }

			"",
			null

			"P://H?A=B#H",
			{ protocol: "P", host: "H", query: "A=B", hash: "H" }

		]

		for i in [0...testData.length-1] by 2
			do (str=testData[i],pattern=testData[i+1]) ->
				it "parses #{str}", ->
					assert $.matches pattern, $.URL.parse str
