[$, assert] = require './setup'

describe "Core plugin:", ->
	describe "$.log", ->
		describe ".out", ->
			it "defaults to console.log", ->
			it "is called by $.log", ->
				try
					pass = false
					$.log.out = (arg) -> pass = arg
					$.log true
					assert pass
				finally
					$.log.out = console.log

	describe "$.logger", ->
		it "creates a logger with a fixed prefix", ->
			f = $.logger('[magic]')
			message = ""
			try
				$.log.out = (a...) -> message = a.join " "
				f "message"
				assert message.indexOf("[magic] message") > -1
			finally
				$.log.out = console.log

	describe ".eq()", ->
		it "selects a new set with only one element", ->
			assert.equal $([1,2,3]).eq(1)[0], 2

	describe ".each(f)", ->
		it "repeats f for each element", ->
			check = 0
			$([1,2,3]).each -> check += 1
			assert.equal check, 3

	describe ".map(f)", ->
		it "returns a new set", ->
			a = $([1,2,3])
			b = a.map (->)
			assert.notEqual a,b
		it "containing the results of f(each item)", ->
			assert.deepEqual $([1,2,3]).map(->@*@), [1,4,9]
	
	describe ".filterMap(f)", ->
		it "works like map, but can omit some results", ->
			assert.deepEqual $(1,2,3,4).filterMap(->
				if @ % 2 then @*@
				else null
			), [1, 9]
	
	describe ".tap(f)", ->
		it "applies f to this", ->
			assert.deepEqual $([1,2]).tap(-> @push 3), [1,2,3]
		it "chains on f's return value", ->
			assert.equal $([1,2]).tap(-> { n: @length }).n, 2
		it "passes the set as `this` and as the only argument", ->
			$([1,2]).tap (set) ->
				assert.equal $.type(@), "bling"
				assert.equal $.type(set), "bling"
	
	describe ".replaceWith", ->
		it "copies values from array to this", ->
			assert.deepEqual $(1,2,3,4).replaceWith([5,6,7,8]), [5,6,7,8]
		it "does not create a new Bling", ->
			d = $(1,2,3,4)
			e = d.replaceWith([5,6,7])
			assert.deepEqual d, [5,6,7,4]

	describe ".coalesce()", ->
		it "should return the first non-null item", ->
			assert.equal $.coalesce(null, 42, 22), 42
		it "should accept an array as argument", ->
			assert.equal($.coalesce([null, 14, 42]), 14)
		it "should descend arrays if nested", ->
			assert.equal($.coalesce([null, [null, 14], 42]), 14)
		it "should span arrays if given multiple", ->
			assert.equal $.coalesce([null, null], [null, [null, 14], 42]), 14

	describe ".reduce()", ->
		it "applies a combiner to accumulate a single result", ->
			assert.equal $([1,2,3,4]).reduce( (a,x) -> a + x ), 10

	describe ".union()", ->
		it "combines two sets, eliminating duplicates", ->
			assert.deepEqual $([1,2,3,4]).union([2,3,4,5]), [1,2,3,4,5]

	describe ".intersect()", ->
		it "combines two sets, leaving only the duplicates", ->
			assert.deepEqual($([1,2,3,4]).intersect([2,3,4,5]), [2,3,4])

	describe ".distinct()", ->
		it "removes duplicates from a single set", ->
			assert.deepEqual($([1,2,2,3,4,3]).distinct(), [1,2,3,4])

	describe ".contains()", ->
		it "returns true if an item is found in the set", ->
			assert $([1,2,3]).contains 3
		it "returns false if an item is not found", ->
			assert not $([1,2,3]).contains 4

	describe ".count()", ->
		it "returns the number of matching items, if given an item", ->
			assert.equal $([1,2,2,3,4,3]).count(3), 2
		it "returns the total count if no item is given", ->
			assert.equal $([1,2,2,3,4,3]).count(), 6

	describe ".select()", ->
		selectObjects = $ [
			{id: 1, pX: 2, pY: 3, parent: { id: 2 }, children: [ { id: 3 }, { id: 5} ] },
			{id: 2, pX: 3, pY: 4, parent: { id: 4 }, children: [ { id: 6 } ] },
			{id: 3, pX: 4, pY: 5, parent: { id: 6 }, children: [ { id: 9 } ] },
		]
		it "extracts values from properties of items in a set", ->
			assert.deepEqual selectObjects.select('id'), [1,2,3]
		it "supports nested property names", ->
			assert.deepEqual selectObjects.select("parent.id"), [2,4,6]
		it "supports nesting into arrays", ->
			assert.deepEqual selectObjects.select("children.0.id"), [3,6,9]
		it "supports multiple arguments (creating simplified objects)", ->
			assert.deepEqual selectObjects.select("pX","pY"), [
				{ pX: 2, pY: 3 },
				{ pX: 3, pY: 4 },
				{ pX: 4, pY: 5 }
			]
		it "supports passing a regex, in lieu of multiple arguments", ->
			assert.deepEqual selectObjects.select(/^p[XY]/), [
				{ pX: 2, pY: 3 },
				{ pX: 3, pY: 4 },
				{ pX: 4, pY: 5 }
			]
		it "supports mixing a regex and string arguments", ->
			assert.deepEqual selectObjects.select(/^p[XY]/,"parent.id"), [
				{ pX: 2, pY: 3, id: 2 },
				{ pX: 3, pY: 4, id: 4 },
				{ pX: 4, pY: 5, id: 6 }
			]
		it "supports the * (read: flatten) operator", ->
			assert.deepEqual selectObjects.select("children.*.id"), [3,5,6,9]
		it "does not fail to select when asked for missing columns", ->
			assert.deepEqual selectObjects.select("pX","noExist","pY"), [
				{ pX: 2, pY: 3 }
				{ pX: 3, pY: 4 }
				{ pX: 4, pY: 5 }
			]

	describe ".zap()", ->
		it "assigns values to properties of items in a set", ->
			assert.deepEqual $([ {id:1}, {id:2}, {id:3} ]).zap('id', 13).select('id'), [13,13,13]
		it "supports using a function to compute the assigned values", ->
			assert.deepEqual $([ {id:1}, {id:2}, {id:3} ]).zap('id', -> @ * 2).select('id'), [2,4,6]
		it "supports nested property names", ->
			assert.deepEqual $([ {sub:{id:1}}, {sub:{id:2}}, {sub:{id:3}} ]).zap('sub.id', -> @*2).select('sub.id'), [2,4,6]

		it "can be given an object of key/value pairs to zap", ->
			assert.deepEqual $( {a: 1}, {a: 2}, {a: 3} ).zap({b: 2, c: 3}),
				[ {a:1,b:2,c:3}, {a:2,b:2,c:3}, {a:3,b:2,c:3} ]

	describe ".clean()", ->
		it "removes properties", ->
			assert.deepEqual $({a:1,b:2},{a:2,b:3}).clean('b').select('a'), [1, 2]
		it "removes multiple properties", ->
			assert.deepEqual $({a:1,b:2,c:3},{a:2,b:3,c:4}).clean('b','c').select('a'), [1, 2]

	describe ".take()", ->
		it "take0", -> assert.deepEqual $([1,2,3,4]).take(0), []
		it "take1", -> assert.deepEqual $([1,2,3,4]).take(1), [1]
		it "take2", -> assert.deepEqual $([1,2,3,4]).take(2), [1,2]
		it "take3", -> assert.deepEqual $([1,2,3,4]).take(3), [1,2,3]
		it "take4", -> assert.deepEqual $([1,2,3,4]).take(4), [1,2,3,4]
		it "take5", -> assert.deepEqual $([1,2,3,4]).take(5), [1,2,3,4]

	describe ".skip()", ->
		it "skip0", -> assert.deepEqual $([1,2,3,4]).skip(0), [1,2,3,4]
		it "skip1", -> assert.deepEqual $([1,2,3,4]).skip(1), [2,3,4]
		it "skip2", -> assert.deepEqual $([1,2,3,4]).skip(2), [3,4]
		it "skip3", -> assert.deepEqual $([1,2,3,4]).skip(3), [4]
		it "skip4", -> assert.deepEqual $([1,2,3,4]).skip(4), []
		it "skip5", -> assert.deepEqual $([1,2,3,4]).skip(5), []

	describe ".first()", ->
		a = $([1,2,3,4])
		it "returns a single element", -> assert.equal a.first(), 1
		it "acts like take", -> assert.deepEqual a.first(5), [1,2,3,4]
		it "acts like take", -> assert.deepEqual a.first(2), [1,2]
		it "acts like take", -> assert.deepEqual a.first(0), []

	describe ".last()", ->
		a = $([1,2,3,4])
		it "returns last element", -> assert.equal a.last(), 4
		it "returns multiple if asked", -> assert.deepEqual a.last(2), [3,4]
		it "returns empty if asked", -> assert.deepEqual a.last(0), []
		it "returns as much as it can", -> assert.deepEqual a.last(5), [1,2,3,4]

	describe ".slice()", ->
		a = $([1,2,3,4,5])
		it "slice1", -> assert.deepEqual $([1,2,3,4,5]).slice(0,5), [1,2,3,4,5]
		it "slice2", -> assert.deepEqual $([1,2,3,4,5]).slice(1,5), [2,3,4,5]
		it "slice3", -> assert.deepEqual $([1,2,3,4,5]).slice(2,5), [3,4,5]
		it "slice4", -> assert.deepEqual $([1,2,3,4,5]).slice(3,5), [4,5]
		it "slice5", -> assert.deepEqual $([1,2,3,4,5]).slice(4,5), [5]
		it "slice6", -> assert.deepEqual $([1,2,3,4,5]).slice(1,-2), [2,3]
		it "slice7", -> assert.deepEqual $([1,2,3,4,5]).slice(-1,-3), [5,4]
		it "slice8", -> assert.deepEqual $([1,2,3,4,5]).slice(-1,-4), [5,4,3]

	describe ".push()", ->
		it "appends to the set", ->
			assert.deepEqual $([1,2]).push(3), [1,2,3]
		it "overrides Array::push()", ->
			assert.notEqual Array::push, Bling::push
		it "returns the resulting set", ->
			assert $.is 'bling', $([1,2]).push(3)

	describe ".filter()", ->
		it "accepts a pattern object", ->
			assert.deepEqual $(
				{ x: 1, a: true }
				{ x: 2, a: false }
				{ x: 3, a: true }
			).filter( a: true ).select('x'), [ 1, 3 ]
		it "filters by a function", -> assert.deepEqual $([1,2,3,4,5]).filter((x) -> x % 2), [1,3,5]
		it "supports regular expressions", -> assert.deepEqual $(["foo","bar","baz"]).filter(/^ba/), ["bar","baz"]
		it "can chain DOM filters", -> assert.equal $("*").filter("td").filter(".d").length, 1
		it "filters might remove all nodes", -> assert.equal $("*").filter("td").filter(".none").length, 0
		it "filters DOM nodes by CSS selector", -> assert.deepEqual $("*").filter("td").length, 8
		it "supports an optional limit", -> assert.deepEqual $(["foo","bar","baz"]).filter(/^b/, 0), []
		it "supports an optional limit", -> assert.deepEqual $(["foo","bar","baz"]).filter(/^b/, 1), ["bar"]
		it "supports an optional limit", -> assert.deepEqual $(["foo","bar","baz"]).filter(/^b/, 2), ["bar","baz"]
		it "supports an optional inversion", ->
			assert.deepEqual $(["foo", "bar", "baz"]).filter(/^b/, false), ["foo"]
		it "accepts the limit and inversion in either order", ->
			a = $("foo", "bar", "baz")
			assert.deepEqual a.filter(/^b/, true, 1), a.filter(/^b/, 1, true)

	describe ".matches()", ->
		describe "supports", ->
			it "CSS selectors", ->
				assert.deepEqual $("td").matches(".d"), [false,false,false,false,false,true,false,false]
			it "regular expressions", ->
				assert.deepEqual $(["one","two","three"]).matches(/o/), [true, true, false]

	describe ".weave()", ->
		it "interleaves items from two sets", ->
			assert.deepEqual($([1,1,1]).weave([2,2,2]), [2,1,2,1,2,1])
		it "supports blinged arguments", ->
			assert.deepEqual($([1,1,1]).weave($([2,2,2])), [2,1,2,1,2,1])

	describe ".querySelectorAll()", ->
		it "queries children for DOM nodes", ->
			assert.deepEqual($("tr").querySelectorAll("td.d")[0].className, "d")

	describe ".fold()", ->
		it "is like a partial reduce", ->
			assert.deepEqual $([1,1,1]).weave([2,2,2]).fold( (a,b) -> a+b ), [3,3,3]
		it "returns half the items", ->
			assert.deepEqual $([1,2,3,4,5,6]).fold( (a,b) -> a+b ).length, 3

	describe ".flatten()", ->
		it "combines subsets", ->
			assert.deepEqual $([[1,2],[3,4]]).flatten(), [1,2,3,4]
		it "allows duplicates (unlike union)", ->
			assert.deepEqual $([[1,2],[1,2]]).flatten(), [1,2,1,2]

	describe "delay", ->
		describe ".delay(ms, f)", ->
			it "runs f after a delay of ms", (done) ->
				t = $.now
				$.delay 100, ->
					delta = Math.abs(($.now - t) - 100)
					assert delta < 25
					done()
			it "can be cancelled", (done) ->
				pass = true
				d = $.delay 300, -> pass = false
				$.delay 100, -> d.cancel()
				$.delay 500, ->
					assert pass
					done()
			it "accepts multiple timeouts at once", (done) ->
				count = 0
				$.delay
					50: -> count += 1
					100: -> count += 2
					200: -> count += 3
					300: ->
						assert.equal count, 6
						done()
				
		describe ".immediate(f)", ->
			it "runs f on the next tick", (done) ->
				pass = false
				$.immediate ->
					assert pass = true
					done()
		describe ".interval(ms, f)", ->
			it "runs f repeatedly", (done) ->
				count = 0
				i = $.interval 100, -> count += 1
				$.delay 1000, ->
					assert 9 <= count <= 11, "Count: #{count} is not between 9 and 11"
					i.cancel()
					done()
			it "can be paused/resumed", (done) ->
				count = 0
				i = $.interval 100, -> count += 1
				$.delay 300, -> i.pause()
				$.delay 700, -> i.resume()
				$.delay 1000, ->
					assert 5 <= count <= 7, "Count: #{count} is not between 5 and 7"
					i.cancel()
					done()

