$.plugin ->
	$:
		histogram: (data, bucket_width=1, output_width=80) ->
			buckets = $()
			len = 0
			for x in data
				i = Math.floor( x / bucket_width )
				buckets[i] ?= 0
				buckets[i] += 1
				len = Math.max(len, i+1)
			buckets.length = len

			max = buckets.max()
			buckets = buckets.map((x) -> x or 0)
				.scale(1/max)
				.scale(output_width)
			sum = buckets.sum()

			ret = ""
			pct_sum = 0
			for n in [0...len] by 1
				end = (n+1) * bucket_width
				pct = (buckets[n]*100/sum)
				pct_sum += pct
				ret += $.padLeft(pct_sum.toFixed(2)+"%",7) + $.padRight(" < #{end.toFixed(2)}", 10) + ": " + $.repeat("#", buckets[n]) + "\n"
			ret
	histogram: -> $.histogram @
