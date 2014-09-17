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

			"P://U@H?A=B#H",
			{ protocol: "P", username: "U", host: "H", query: "A=B", hash: "H" }

			"P://U:W@H?A=B#H",
			{ protocol: "P", username: "U", password: "W", host: "H", query: "A=B", hash: "H" }

			"proto://"
			{ protocol: "proto" }

			"sqlite://:memory:"
			{ protocol: "sqlite", host:":memory:" }

			"sqlite:///:memory:"
			{ protocol: "sqlite", path:"/:memory:" }

			"sqlite:///usr/local/data/file.db"
			{ protocol: "sqlite", path:"/usr/local/data/file.db" }

			"mongodb://1.2.3.4,5.6.7.8,9.10.11.12/db_name"
			{
				protocol: "mongodb"
				hosts: [ { host: "1.2.3.4" }, { host: "5.6.7.8" }, { host: "9.10.11.12" } ]
				path: "/db_name"
			}

			"mongodb://user:pass@1.2.3.4:1234,user2:pass2@5.6.7.8:5678,9.10.11.12:9112/db_name"
			{
				protocol: "mongodb"
				hosts: [
					{ host: "1.2.3.4", username: "user", password: "pass", port: "1234" }
					{ host: "5.6.7.8", username: "user2", password: "pass2", port: "5678" }
					{ host: "9.10.11.12", port: "9112" }
				]
				path: "/db_name"
			}
		]

		for i in [0...testData.length-1] by 2
			do (str=testData[i],pattern=testData[i+1]) ->
				it "parses #{str}", ->
					parsed = $.URL.parse(str)
					try assert.deepEqual pattern, parsed, "#{JSON.stringify pattern} matches #{JSON.stringify parsed}"
					catch err
						console.log "Assertion failed:", err.message
						console.log pattern
						console.log parsed
						throw err

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
