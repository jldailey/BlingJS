$.plugin
	provides: 'random'
	depends: 'type'
, ->
	# the set that $.randomString chooses from:
	englishAlphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".split ""
	uuidAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

	{ floor, abs, log } = Math

	max_int = 0xFFFFFFFF
	s = new Uint32Array(2)
	next = ->
		s0 = s[0]
		s1 = s[1]
		result = (s0 + s1) % max_int
		s1 ^= s0
		s[0] = (s0 << 27) | (s0 >>> 5) ^ s1 ^ (s1 << 7)
		s[1] = (s1 << 18) | (s1 >>> 14)
		return result
	random = -> next() / max_int
	$.defineProperty random, 'seed',
		set: (n) ->
			s[0] = n
			s[1] = 1
			next(); next(); next();
			n
	random.seed = $.now

	$: random: $.extend random,
			real: real = (min, max) ->
				if not min?
					[min,max] = [0,1.0]
				if not max?
					[min,max] = [0,min]
				(random() * (max - min)) + min
			integer: integer = (min, max) -> floor real min, max
			string: string = (len, prefix="", alphabet=englishAlphabet) ->
				prefix += element(alphabet) while prefix.length < len
				prefix
			coin: (balance=.5) -> random() <= balance
			element: element = (arr, weights) ->
				if weights?
					# force the weights to sum to 1.0
					w = $(weights)
					w = w.scale 1.0/w.sum()
					# sort all the items by their weight (desc order)
					i = 0
					sorted = $(arr).map((x) ->
						v: x
						w: w[i++]
					).sortBy (x) -> -x.w
					# pick a threshold between 0..1
					r = random()
					# scan forward until we hit the threshold
					sum = 0
					for item in sorted
						return item.v if (sum += item.w) >= r
				return arr[integer 0, arr.length]
			gaussian: (mean=0.5, ssig=0.12) -> # paraphrased from Wikipedia
				while true
					u = random()
					v = 1.7156 * (random() - 0.5)
					x = u - 0.449871
					y = abs(v) + 0.386595
					q = (x*x) + y*(0.19600*y-0.25472*x)
					break unless q > 0.27597 and (q > 0.27846 or (v*v) > (-4*log(u)*u*u))
				return mean + ssig*v/u
			die: die = (faces) -> # die(6) is like a 1d6
				integer 1, faces+1
			dice: (n, faces) -> # a 2d8 is dice(2,8)
				$( die(faces) for [0...n] by 1 )
			uuid: ->
				$(8,4,4,4,12).map(-> string @,'',uuidAlphabet).join '-'

