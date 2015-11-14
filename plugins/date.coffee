$.plugin
	provides: 'date,midnight,stamp,unstamp,dateFormat,dateParse'
	depends: 'type'
, ->
	# the basic units of time, and their relation to milliseconds
	[ms,s,m,h,d] = [1,1000,1000*60,1000*60*60,1000*60*60*24]

	units = {
		ms, s, m, h, d,
		# aliases:
		sec: s
		second: s
		seconds: s
		min: m
		minute: m
		minutes: m
		hr: h
		hour: h
		hours: h
		day: d
		days: d
	}

	shortDays = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
	longDays = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]

	formats =
		yyyy: Date.prototype.getUTCFullYear
		YY: fYY = -> String(@getUTCFullYear()).substr(2)
		yy: fYY
		mm: -> @getUTCMonth() + 1
		dd: Date.prototype.getUTCDate
		dw: Date.prototype.getUTCDay # day of the week, 1=monday
		dW: -> shortDays[parseInt(@getUTCDay(), 10) - 1]
		DW: -> longDays[parseInt(@getUTCDay(), 10) - 1]
		HH: Date.prototype.getUTCHours
		MM: Date.prototype.getUTCMinutes
		SS: Date.prototype.getUTCSeconds
		MS: Date.prototype.getUTCMilliseconds
		_MS: ->
			$.padLeft Date.prototype.getUTCMilliseconds.apply(@), 3, "0"
	format_keys = Object.keys(formats).sort().reverse()

	parsers =
		YYYY: pYYYY = Date.prototype.setUTCFullYear
		yyyy: pYYYY
		YY: pYY = (x) -> @setUTCFullYear (if x > 50 then 1900 else 2000) + x
		yy: pYY
		mm: (x) -> @setUTCMonth(x - 1)
		dd: Date.prototype.setUTCDate
		HH: Date.prototype.setUTCHours
		MM: Date.prototype.setUTCMinutes
		SS: Date.prototype.setUTCSeconds
		_MS: (s) -> @setUTCMilliseconds parseInt s, 10
		MS: Date.prototype.setUTCMilliseconds
	parser_keys = Object.keys(parsers).sort().reverse()

	floor = Math.floor

	$.type.register "date",
		is: (o) -> $.isType Date, o
		array: (o) -> [o]
		string: (o, fmt, unit) -> $.date.format o, fmt, unit
		number: (o, unit) -> $.date.stamp o, unit

	$.type.extend 'string', date: (s, fmt = $.date.defaultFormat) -> new Date $.date.parse s, fmt, "ms"
	$.type.extend 'number', date: (n, unit = $.date.defaultUnit) -> $.date.unstamp n, unit

	adder = (key) ->
		(stamp, delta, stamp_unit = $.date.defaultUnit) ->
			date = $.date.unstamp(stamp, stamp_unit)
			parsers[key].call date, (formats[key].call date) + delta
			$.date.stamp date, stamp_unit

	$:
		date:
			defaultUnit: "s"
			defaultFormat: "yyyy-mm-dd HH:MM:SS"
			stamp: (date = new Date, unit = $.date.defaultUnit) ->
				floor (date / units[unit])
			unstamp: (stamp, unit = $.date.defaultUnit) ->
				new Date floor stamp * units[unit]
			convert: (stamp, from = $.date.defaultUnit, to = $.date.defaultUnit) ->
				if $.is "date", stamp then stamp = $.date.stamp(stamp, from)
				(floor stamp * units[from] / units[to])
			midnight: (stamp, unit = $.date.defaultUnit) ->
				$.date.convert ($.date.convert stamp, unit, "d"), "d", unit
			format: (stamp, fmt = $.date.defaultFormat, unit = $.date.defaultUnit) ->
				if $.is "date", stamp then stamp = $.date.stamp(stamp, unit)
				date = $.date.unstamp stamp, unit
				for k in format_keys
					fmt = fmt.replace k, ($.padLeft ""+formats[k].call(date), k.length, "0")
				fmt
			parse: (dateString, fmt = $.date.defaultFormat, to = $.date.defaultUnit) ->
				date = new Date(0)
				i = 0
				while i < fmt.length
					for k in parser_keys
						if fmt.indexOf(k, i) is i
							try
								parsers[k].call date,
									parseInt dateString[i...i+k.length], 10
							catch err
								throw new Error("Invalid date ('#{dateString}') given format mask: #{fmt} (failed at position #{i})")
							i += k.length - 1
							break
					i += 1
				$.date.stamp date, to
			addMilliseconds: adder("MS")
			addSeconds:      adder("SS")
			addMinutes:      adder("MM")
			addHours:        adder("HH")
			addDays:         adder("dd")
			addMonths:       adder("mm")
			addYears:        adder("yyyy")
			range: (from, to, interval=1, interval_unit="dd", stamp_unit = $.date.defaultUnit) ->
				add = adder(interval_unit)
				ret = [from]
				while (cur = ret[ret.length-1]) < to
					ret.push add(cur, interval, stamp_unit)
				ret

	midnight: (unit = $.date.defaultUnit) -> @map(-> $.date.midnight @, unit)
	unstamp: (unit = $.date.defaultUnit) -> @map(-> $.date.unstamp @, unit)
	stamp: (unit = $.date.defaultUnit) -> @map(-> $.date.stamp @, unit)
	dateFormat: (fmt = $.date.defaultFormat, unit = $.date.defaultUnit) -> @map(-> $.date.format @, fmt, unit)
	dateParse: (fmt = $.date.defaultFormat, unit = $.date.defaultUnit) -> @map(-> $.date.parse @, fmt, unit)

