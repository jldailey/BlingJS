[$, assert] = require './setup'

describe "Sort plugin:", ->

	describe "$.sortedIndex()", ->
		it "returns the index to insert at", ->
			assert.equal $.sortedIndex([1,2,4], 3), 2
		it "will insert at end", ->
			assert.equal $.sortedIndex([1,2,3], 4), 3
		it "will insert at beginning", ->
			assert.equal $.sortedIndex([2,3,4], 1), 0
		it "can use a field for comparison", ->
			assert.equal $.sortedIndex([{a:1},{a:2},{a:4}], {a:3}, 'a'), 2
		it "can use a comparison function", ->
			assert.equal $.sortedIndex([1,2,4], 3, null, (x)->Math.pow(x,2)), 2

	describe ".sortBy(field,cmp)", ->
		it "can sort", ->
			assert.deepEqual $(3,1,2).sortBy(), [1,2,3]
		it "can sort by a field", ->
			assert.deepEqual $( {a:2}, {a:1}, {a:3} ).sortBy('a').select('a'), [1,2,3]
		it "does NOT sort in-place", ->
			a = $(2,3,1)
			b = a.sortBy()
			assert.deepEqual b, [1,2,3]
			assert a isnt b
		it "sorts strings correctly", ->
			assert.deepEqual $(
				{ code: "a" },
				{ code: "c" },
				{ code: "b" }
			).sortBy('code').select('code'), ["a","b","c"]
		it "can do complex sorts (such as case-less)", ->
			assert.deepEqual $(
				{ code: "a" },
				{ code: "c" },
				{ code: "B" }
			).sortBy((item)-> item.code.toLowerCase()).select('code'), ["a","B","c"]
	
	describe ".sortedInsert(item,iterator)", ->
		it "inserts in sorted order", ->
			assert.deepEqual $(1,2,4).sortedInsert(3), [1,2,3,4]
		it "can be chained", ->
			assert.deepEqual $().sortedInsert(3).sortedInsert(1).sortedInsert(2), [1,2,3]
		it "works on fields", ->
			assert.deepEqual $().sortedInsert({x:1,y:2}, 'y').sortedInsert({x:2,y:1}, 'y'), [{x:2,y:1},{x:1,y:2}]
	
