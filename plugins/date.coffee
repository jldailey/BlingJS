(($) ->
	$.plugin
		provides: "date"
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

		formats =
			yyyy: Date::getUTCFullYear
			mm: -> @getUTCMonth() + 1
			dd: Date::getUTCDate
			HH: Date::getUTCHours
			MM: Date::getUTCMinutes
			SS: Date::getUTCSeconds
			MS: Date::getUTCMilliseconds
		format_keys = Object.keys(formats).sort().reverse()

		parsers =
			yyyy: Date::setUTCFullYear
			mm: (x) -> @setUTCMonth(x - 1)
			dd: Date::setUTCDate
			HH: Date::setUTCHours
			MM: Date::setUTCMinutes
			SS: Date::setUTCSeconds
			MS: Date::setUTCMilliseconds
		parser_keys = Object.keys(parsers).sort().reverse()

		floor = Math.floor

		unit_re = new RegExp("(\\d+\\.*\\d*)\\s*(" + Object.keys(units).join("|") + ")")
		unpackUnits = (str) ->
			ret = switch $.type str
				when "date" then unpackUnits $.date.convert(str.getTime() + "ms", $.date.defaultUnit)
				else (str?.match(unit_re) ? [ str, parseFloat(str), $.date.defaultUnit ])[1..2]
			return ret

		$.type.register "date",
			match: (o) -> $.isType Date, o
			array: (o) -> [o]

		$:
			date:
				defaultUnit: "ms"
				defaultFormat: "yyyy-mm-dd HH:MM:SS"
				stamp: (date = new Date, unit = $.date.defaultUnit) ->
					(floor (date / units[unit])) + unit
				unstamp: (stamp) ->
					[stamp, unit] = unpackUnits(stamp)
					new Date floor(stamp * units[unit])
				midnight: (stamp) ->
					[_, unit] = unpackUnits(stamp)
					$.date.convert ($.date.convert stamp, "d"), unit
				convert: (stamp, to = "ms") ->
					[stamp, from] = unpackUnits(stamp)
					(floor stamp * units[from] / units[to]) + to
				format: (stamp, fmt = $.date.defaultFormat) ->
					date = $.date.unstamp(stamp)
					for k in format_keys
						fmt = fmt.replace k, ($.padLeft ""+formats[k].call(date), k.length, "0")
					fmt
				parse: (dateString, fmt = $.date.defaultFormat, to = $.date.defaultUnit) ->
					date = new Date(0)
					for i in [0...fmt.length] by 1
						for k in parser_keys
							if fmt.indexOf(k, i) is i
								try
									parsers[k].call date,
										parseInt dateString[i...i+k.length], 10
								catch err
									throw new Error("Invalid date ('#{dateString}') given format mask: #{fmt} (failed at position #{i})")
					$.date.stamp date, to
				add: (stamp, delta) ->
					[stamp, stamp_unit] = unpackUnits(stamp)
					(+ stamp) + (parseInt $.date.convert(delta, stamp_unit), 10) + stamp_unit
		midnight: -> @map(-> $.date.midnight @)
		unstamp: -> @map(-> $.date.unstamp @)
		stamp: -> @map(-> $.date.stamp @)
		dateConvert: (to = $.date.defaultUnit) -> @map(-> $.date.convert @, to)
		dateFormat: (fmt = $.date.defaultFormat) -> @map(-> $.date.format @, fmt)
		dateParse: (fmt = $.date.defaultFormat) -> @map(-> $.date.parse @, fmt)
		dateAdd: (delta) -> @map(-> $.date.add @, delta)

	if require.main is module
		require "../bling"
		$.date.defaultUnit = "s"
		$($.date.stamp())
			.log('current time')
			.unstamp()
			.log('current date')
			.dateFormat()
			.log('formatted')
			.dateParse()
			.log('parsed')
			.dateConvert('days')
			.log('as days')
			.midnight()
			.log('midnight raw')
			.unstamp().log('midnight UTC').stamp()
			.dateAdd('3h')
			.unstamp().log('3 hours later').stamp()
			.dateAdd('30d')
			.unstamp().log('30 days later').stamp()
		$($.date.parse "06/20/2012 12:24:42", "mm/dd/yyyy HH:MM:SS")
			.unstamp().log('parsed')
)(Bling)

