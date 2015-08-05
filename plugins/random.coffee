$.plugin
	provides: 'random'
	depends: 'type'
, ->
	# the set that $.randomString chooses from:
	englishAlphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".split ""
	uuidAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

	$: random: do -> # Mersenne Twister algorithm, from the psuedocode on wikipedia
		MT = new Array(624)
		index = 0
		init_generator = (seed) ->
			index = 0
			MT[0] = seed
			for i in [1..623]
				MT[i] = 0xFFFFFFFF & (1812433253 * (MT[i-1] ^ (MT[i-1] >>> 30)) + i)

		generate_numbers = ->
			for i in [0..623]
				y = ((MT[i] & 0x80000000) >>> 31) + (0x7FFFFFFF & MT[ (i+1) % 624 ])
				MT[i] = MT[ (i+397) % 624 ] ^ (y >>> 1)
				if (y%2) is 1
					MT[i] = MT[i] ^ 2567483615

		a = Math.pow(2,31)
		b = a * 2
		next = ->
			if index is 0
				generate_numbers()
			y = MT[index] ^
				(y >>> 11) ^
				((y << 7) and 2636928640) ^
				((y << 15) and 4022730752) ^
				(y >>> 18)

			index = (index + 1) % 624
			# return a number between 0 and 1
			(y + a) / b

		$.defineProperty next, "seed",
			set: (v) -> init_generator(v)

		next.seed = +new Date()

		return $.extend next,
			real: real = (min, max) ->
				if not min?
					[min,max] = [0,1.0]
				if not max?
					[min,max] = [0,min]
				($.random() * (max - min)) + min
			integer: integer = (min, max) -> Math.floor $.random.real(min,max)
			string: string = (len, prefix="", alphabet=englishAlphabet) ->
				prefix += $.random.element(alphabet) while prefix.length < len
				prefix
			coin: coin = (balance=.5) -> $.random() <= balance
			element: (arr, weights) ->
				if weights?
					# force the weights to sum to 1.0
					w = $(weights)
					sum_w = 1.0/w.sum()
					if sum_w isnt 1
						w = w.scale(sum_w)
					# sort all the items by their weight (desc order)
					i = 0
					sorted = $(arr).map((x) -> {v: x, w: w[i++] }).sortBy (x) -> -x.w
					# then pick a threshold between 0..1
					r = $.random.real(0.00001,.999999) # never exactly 0.0 or 1.0
					# scan forward until we hit the threshold
					sum = 0
					for item in sorted
						return item.v if (sum += item.w) >= r
				return arr[$.random.integer 0, arr.length]
			gaussian: gaussian = (mean=0.5, ssig=0.12) -> # paraphrased from Wikipedia
				log = Math.log
				abs = Math.abs
				while true
					u = $.random()
					v = 1.7156 * ($.random() - 0.5)
					x = u - 0.449871
					y = abs(v) + 0.386595
					q = (x*x) + y*(0.19600*y-0.25472*x)
					break unless q > 0.27597 and (q > 0.27846 or (v*v) > (-4*log(u)*u*u))
				return mean + ssig*v/u
			dice: dice = (n, faces) -> # a 2d8 is dice(2,8)
				$( die(faces) for _ in [0...n] by 1 )
			die: die = (faces) ->
				$.random.integer(1,faces+1)
			uuid: ->
				$(8,4,4,4,12).map(-> $.random.string @,'',uuidAlphabet).join '-'

