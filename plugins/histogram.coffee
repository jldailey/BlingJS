$.plugin ->
	$:
		histogram: (data, bucket_width=1, output_width=60) ->
			buckets = $()
			len = 0
			min = Infinity
			mean = 0
			max = 0
			total = 0
			for x in data
				min = Math.min x, min
				max = Math.max x, max
				total += x
				i = Math.floor( x / bucket_width )
				if i of buckets
					buckets[i] += 1
				else
					buckets[i] = 1
				len = Math.max(len, i+1)
			buckets.length = len
			mean = total / data.length

			m = buckets.max()
			buckets = buckets.or(0)
				.scale(1/m)
				.scale(output_width)
			sum = buckets.sum()

			ret = ""
			pct_sum = 0
			for n in [0...len] by 1
				end = (n+1) * bucket_width
				pct = (buckets[n]*100/sum)
				pct_sum += pct
				ret += $.padLeft(pct_sum.toFixed(2)+"%",7) +
					$.padRight(" < #{end.toFixed(2)}", 10) +
					": " + $.repeat("#", buckets[n]) + "\n"
			ret + "N: #{data.length} Min: #{min.toFixed(2)} Max: #{max.toFixed(2)} Mean: #{mean.toFixed(2)}"
	histogram: -> $.histogram @
