[$, assert] = require './setup'

describe "Date plugin:", ->
	it "adds the 'date' type", ->
		assert $.is 'date', new Date(0)
	describe "the 'date' type converts", ->
		it "date to string", ->
			assert.equal ($.as "string", new Date Date.UTC 1,2,3,4,5,6), "1901-03-03 04:05:06"
		it "string to date", ->
			assert.equal ($.as "date", "1901-03-03 04:05:06").toUTCString(), new Date(Date.UTC 1,2,3,4,5,6).toUTCString()
		it "date to number", ->
			assert.equal ($.as "number", new Date Date.UTC 1,2,3,4,5,6), -2172167694
		it "number to date", ->
			assert.equal ($.as "date", -2172167694).toString(), (new Date Date.UTC 1,2,3,4,5,6).toString()
	describe "$.date", ->
		describe ".stamp()", ->
			describe "converts date objects to numbers (with units)", ->
				it "ms", -> assert $.date.stamp(new Date(1000000), "ms") is 1000000
				it "seconds", -> assert $.date.stamp(new Date(1000000), "s") is 1000
		describe ".unstamp()", ->
			it "converts a number to a real date", ->
				assert $.is 'date', $.date.unstamp 0
			it "is the reverse of stamp", ->
				d1 = new Date(1000000)
				d2 = $.date.unstamp $.date.stamp d1
				assert d1.toString() is d2.toString()
			it "supports chaining as .unstamp()", ->
				assert $.is 'date', $([1000000]).unstamp().first()
		describe ".convert()", ->
			assert $.date.convert(1000000, "ms", "s") is 1000
		describe ".midnight()", ->
			it "returns a stamp", ->
				assert $.is 'number', $.date.midnight new Date 0
			it "shifts a date to midnight of that day", ->
				assert.notEqual -1,
					$.date.unstamp($.date.midnight new Date 1000000000).toUTCString().indexOf("00:00:00 GMT")
			it "supports chaining", ->
				assert.equal $($.date.range 1000, 1000000, 3) \
					.midnight() \
					.dateFormat("HHMMSS") \
					.ints().sum(), 0
		describe ".format()", ->
			d1 = new Date(1000000000)
			describe "supports fields", ->
				it "yyyy", -> assert.equal $.date.format(d1, "yyyy"), "1970"
				it "YY", -> assert.equal $.date.format(d1, "YY"), "70"
				it "mm", -> assert.equal $.date.format(d1, "mm"), "01"
				it "dd", -> assert.equal $.date.format(d1, "dd"), "12"
				it "dw", -> assert.equal $.date.format(d1, "dw"), "01"
				it "dW", -> assert.equal $.date.format(d1, "dW"), "Mon"
				it "DW", -> assert.equal $.date.format(d1, "DW"), "Monday"
				it "HH", -> assert.equal $.date.format(d1, "HH"), "13"
				it "MM", -> assert.equal $.date.format(d1, "MM"), "46"
				it "SS", -> assert.equal $.date.format(d1, "SS"), "40"
			it "supports spacing and punctuation", ->
				assert.equal $.date.format(d1, "yyyy-mm-dd HH:MM:SS"), "1970-01-12 13:46:40"
			it "supports chaining as .dateFormat()", ->
				assert.equal $($.date.range 1000, 1000000, 3) \
					.dateFormat("dd") \
					.ints().sum(), 35
		describe ".parse()", ->
			it "supports the same formats as .format()", ->
				assert $.date.parse("1970-01-12 13:46:40", "yyyy-mm-dd HH:MM:SS", "ms"), 1000000000
			it "supports chaining as .dateParse()", ->
				assert.equal $(["1970-01-12 13:46:40"]).dateParse("yyyy-mm-dd HH:MM:SS", "ms").first(), 1000000000
			it "follow the +50/-50 rule for 2-digit years", ->
				assert.equal $.date.parse("16/09/14", "dd/mm/yy", "s"), 1410825600
				assert.equal $.date.parse("16/09/94", "dd/mm/yy", "s"), 779673600
		describe ".range()", ->
			it "generates a range of date stamps", ->
				assert.equal $($.date.range(1000, 1000000, 3)) \
					.unstamp() \
					.select("getUTCDate").call() \
					.ints().sum(), 35 # == 1 + 4 + 7 + 10 + 13 (every 3 days from Jan 1 1970 for 2 weeks)
