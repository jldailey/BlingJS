[$, assert] = require './setup'

describe "Diff plugin:", ->
	describe ".stringDistance()", ->
		it "equal strings are zero distance", ->
			assert.equal $.stringDistance("a","a"), 0
			assert.equal $.stringDistance("ab","ab"), 0
		it "inserts are one distance", ->
			assert.equal $.stringDistance('a','ab'), 1
		it "deletes are one distance", ->
			assert.equal $.stringDistance('ab', 'a'), 1
		it "replaces are one distance", ->
			assert.equal $.stringDistance('a','b'), 1
		it "can mix inserts/deletes/replaces", ->
			assert.equal $.stringDistance('Hoy','aHi'), 3
		it "memoizes without corrupting results", ->
			assert.equal $.stringDistance('Hoy','aHi'), 3

	describe ".stringDiff()", ->
		it "handles all inserts", ->
			assert.deepEqual $.stringDiff("", "abc"), [{op:'ins',v:'abc'}]
		it "handles all deletes", ->
			assert.deepEqual $.stringDiff("abc", ""), [{op:'del',v:'abc'}]
		it "handles replaces", ->
			assert.deepEqual $.stringDiff("a", "b"), [{op:'sub',v:'a',w:'b'}]
		it "handles all replaces", ->
			assert.deepEqual $.stringDiff("aaa", "bbb"), [{op:'sub',v:'aaa',w:'bbb'}]
		it "handles saves", ->
			assert.deepEqual $.stringDiff('a','a'), [{op:'sav',v:'a'}]
		it "handles all saves", ->
			assert.deepEqual $.stringDiff('aaa','aaa'), [{op:'sav',v:'aaa'}]
		it "handles mixed operations", ->
			assert.deepEqual $.stringDiff("ab", "bbd"), [{op:'sub',v:'a',w:'b'},{op:'sav',v:'b'},{op:'ins',v:'d'}]
		it "renders HTML", ->
			assert.deepEqual $.stringDiff("Hello", "Hi").toHTML(), "H<del>e</del><ins>i</ins><del>llo</del>"
