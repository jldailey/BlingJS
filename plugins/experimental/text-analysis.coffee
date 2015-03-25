
do ($ = require "../../dist/bling") ->

	$.plugin
		provides: "text-analysis"
	, ->
		indices = $.memoize (str, substr) ->
			switch substr.length
				when 0 then $.range 0, str.length
				when 1
					i = -1
					i while (i = str.indexOf substr, i+1) > -1
				else
					subsub = substr[0...substr.length-1]
					indices(str, subsub).filter (x) -> str.indexOf(substr,x) is x

		commonSubstrings = (a,b,min_length=1,limit=1) ->
			a = a.toLowerCase()
			b = b.toLowerCase()
			ret = {}
			for i in [0...b.length]
				for j in [0...b.length]
					if (j - i) < min_length-1 then continue
					c = b[i..j]
					if (indices a,c).length > 0
						ret[c] = 1
			$(Object.keys ret)
				.sort((x,y) -> y.length - x.length)
				.take(limit)

		safeSet = (o, k, v) ->
			safeMod o, k, (_o,_k) -> _o[_k] = v

		safeInc = (o, k, v) ->
			safeMod o, k, (_o,_k) ->
				unless _k of _o then _o[_k] = 0
				_o[_k] += v

		safeMod = (o, k, f) ->
			if k.length > 1
				o[k[0]] ?= {}
				return safeMod o[k[0]], k.slice(1), f
			else f o, k

		normalize = (m, n) ->
			for k of m
				if $.is 'object', m[k]
					normalize m[k], n
				else if $.is 'number', m[k]
					m[k] /= n
			m



		$:
			stringsInCommon: commonSubstrings
			nGrams: (str, n=2, lower=false) ->
				data = {}
				if lower then str = str.toLowerCase()
				for i in [0...str.length] by 1
					safeInc data, str.substr(i,n), 1
				return normalize data, str.length
			wordGrams: (str, sep=/[ \r\n.,'":;{}\[\]|\\\/?<>!@#$%^&*()`~=+-]/, lower=false) ->
				if lower then str = str.toLowerCase()
				ends = /[.?!][\r\n\t ]+/g
				str = "SENTENCE_BEGIN " + (str.replace ends, " SENTENCE_END SENTENCE_BEGIN ") + "SENTENCE_END"
				str = str.replace /[\r\n\t ]+/g, ' '
				words = $(str.split sep).filterMap (w) ->
					if w != '' then w else null
				data = {}
				for i in [0...words.length-1] by 1
					w = words[i]
					x = words[i+1]
					if w.length > 0 and x.length > 0
						safeInc data, [w, x], 1
				return normalize data, str.length

			generateWord: (digram, n) ->
				word = $.random.element('abcdefghijklmnopqrstuvwxyz')
				getNext = (c,limit=10) ->
					row = digram[c]
					d = $.random.element $.keysOf(row), $.valuesOf(row)
					unless limit < 0 or /\w/.test d
						return getNext(c, limit-1)
					d
				while word.length < n
					word += getNext word[word.length - 1]
				word

			generateSentence: (wordgram, n=6) ->
				sent = [ ]
				getNext = (w, limit=10) ->
					row = wordgram[w]
					x = $.random.element $.keysOf(row), $.valuesOf(row)
				last = "SENTENCE_BEGIN"
				while last? and last != "SENTENCE_END"
					sent.push last = getNext last
				sent.join(' ').replace(/SENTENCE_\w+/g,'')


if require.main is module
	data = require('fs').readFileSync('plugins/experimental/hamlet.txt').toString()
	wordgram = $.wordGrams data, null, true
	console.log $.generateSentence wordgram


