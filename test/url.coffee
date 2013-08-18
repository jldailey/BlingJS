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

			"proto://"
			{ protocol: "proto" }

			"sqlite://:memory:"
			{ protocol: "sqlite", path:"/:memory:" }

			"sqlite:///:memory:"
			{ protocol: "sqlite", path:"/:memory:" }

			"sqlite:///usr/local/data/file.db"
			{ protocol: "sqlite", path:"/usr/local/data/file.db" }

		]

		for i in [0...testData.length-1] by 2
			do (str=testData[i],pattern=testData[i+1]) ->
				it "parses #{str}", ->
					assert ($.matches pattern, $.URL.parse str), "#{JSON.stringify pattern} matches #{JSON.stringify $.URL.parse str}"

		queryTestData = [
			"p://host?key=value",
			{ key: "value" },

			"p://host?=value",
			{ },

			"p://host?a=b&c=d",
			{ a: "b", c: "d" },

			"p://host?key=",
			{ key: "" },

			"p://host?KeY=Value",
			{ "KeY": "Value" },

			"p://host?‰=€",
			{ "‰": "€" }
			
			"p://host?&a==s p a c e s",
			{ "a": "=s p a c e s" },

			"p://host?&a=%20zzz%20",
			{ "a": " zzz " }

		]

		for i in [0...queryTestData.length-1] by 2
			do (str=queryTestData[i],pattern=queryTestData[i+1]) ->
				it "parses query params: #{str}", ->
					q = $.URL.parse(str, true).query
					assert.deepEqual pattern, q
