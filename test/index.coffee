[$, assert] = require './setup'

describe "Index/Query plugin:", ->
	describe ".index(keyMaker)", ->
		keyMaker = (obj) -> obj.a
		it "creates a private index", ->
			$([{a:1,b:2}, {a:2,b:3}]).index keyMaker
		it "cannot query until index has been built", ->
			assert.equal $([1,2,3]).query(a:1), null
		it "can .query() after indexing", ->
			a = $([{a:1,b:'b'},{a:2},{a:3}]).index keyMaker
			assert.equal a.query(a:1).b, 'b'
		it "can use compound keys", ->
			compoundKeyMaker = (obj) -> obj.a + "-" + obj.b
			a = $([{a:1,b:'b'},{a:2,b:1},{a:3,b:2,c:'c'}]).index compoundKeyMaker
			assert.equal a.query(a:3,b:2).c, 'c'
		describe "using more than one key maker", ->
			keyMakerOne = (obj) -> obj.a
			keyMakerTwo = (obj) -> obj.b
			keyMakerThree = (obj) -> obj.a + '-' + obj.b
			a = $([{a:1,b:'b'},{a:2,b:1},{a:3,b:2,c:'c'}])
			it "wont hurt if you re-index by the same keyMaker", ->
				a.index keyMakerOne
				a.index keyMakerOne
				assert.equal a.query(a:3).b, 2
			it "will allow querying against a second keyMaker", ->
				a.index keyMakerTwo
				assert.equal a.query(a:3).b, 2
				assert.equal a.query(b:2).a, 3
			it "will allow querying against N keyMakers", ->
				a.index keyMakerOne
				a.index keyMakerTwo
				a.index keyMakerThree
				assert.equal a.query(a:3).b, 2
				assert.equal a.query(b:'b').a, 1
				assert.equal a.query({a:3,b:2}).c, 'c'

	describe ".groupBy(key)", ->
		objs = $([
			{name: "a", k: 1, val: 1},
			{name: "a", k: 1, val: 2},
			{name: "a", k: 2, val: 3},
			{name: "b", k: 1, val: 4},
			{name: "c", k: 1, val: 5},
			{ val: 6 }

		])
		it "groups objects by the key", ->
			assert.deepEqual objs.groupBy('name'), [
				[ {name: "a", k:1, val: 1},
					{name: "a", k:1, val: 2},
					{name: "a", k:2, val: 3} ],
				[ {name: "b", k:1, val: 4} ],
				[ {name: "c", k:1, val: 5} ],
				[ { val: 6 } ]
			]
		it "can group by multiple keys", ->
			assert.deepEqual objs.groupBy(['name','k']), [
				[ {name: "a", k:1, val: 1},
					{name: "a", k:1, val: 2}
				],
				[ {name: "a", k:2, val: 3} ], # this 'a' gets its own group
				[ {name: "b", k:1, val: 4} ],
				[ {name: "c", k:1, val: 5} ],
				[ { val: 6 } ]
			]

		it "is mappable", ->
			assert.deepEqual objs.groupBy('name').map(-> @select('val').sum()),
				[ 6, 4, 5, 6 ]

		it "is mappable to a new object", ->
			assert.deepEqual objs.groupBy(['name','k']).map(->
				name: @select('name').first()
				sum: @select('val').sum()
				k: @select('k').first()
			),
				[ { name: "a", sum: 3, k:1 },
					{ name: "a", sum: 3, k:2 },
				  { name: "b", sum: 4, k:1 },
					{ name: "c", sum: 5, k:1 }
					{ name: undefined, sum: 6, k:undefined }
				]

