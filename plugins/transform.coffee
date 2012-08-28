# Transform plugin
# ----------------
# For accelerated animations.
$.plugin
	depends: "dom"
, ->
	COMMASEP = ", "
	speeds = # constant speed names
		"slow": 700
		"medium": 500
		"normal": 300
		"fast": 100
		"instant": 0
		"now": 0
	# matches all the accelerated css property names
	accel_props_re = /(?:scale(?:3d)*|translate(?:[XYZ]|3d)*|rotate(?:[XYZ]|3d)*)/
	updateDelay = 30 # ms to wait for DOM changes to apply
	testStyle = document.createElement("div").style

	transformProperty = "transform"
	transitionProperty = "transition-property"
	transitionDuration = "transition-duration"
	transitionTiming = "transition-timing-function"

	# detect which browser's transform properties to use
	if "WebkitTransform" of testStyle
		transformProperty = "-webkit-transform"
		transitionProperty = "-webkit-transition-property"
		transitionDuration = "-webkit-transition-duration"
		transitionTiming = "-webkit-transition-timing-function"
	else if "MozTransform" of testStyle
		transformProperty = "-moz-transform"
		transitionProperty = "-moz-transition-property"
		transitionDuration = "-moz-transition-duration"
		transitionTiming = "-moz-transition-timing-function"
	else if "OTransform" of testStyle
		transformProperty = "-o-transform"
		transitionProperty = "-o-transition-property"
		transitionDuration = "-o-transition-duration"
		transitionTiming = "-o-transition-timing-function"

	return {
		$:
			# $.duration(/s/) - given a speed description (string|number), return a number in milliseconds
			duration: (speed) ->
				d = speeds[speed]
				return d if d?
				return parseFloat speed

		# .transform(css, [/speed/], [/callback/]) - animate css properties on each node
		transform: (end_css, speed, easing, callback) ->
			# animate css properties over a duration
			# accelerated: scale, translate, rotate, scale3d,
			# ... translateX, translateY, translateZ, translate3d,
			# ... rotateX, rotateY, rotateZ, rotate3d
			# easing values (strings): ease | linear | ease-in | ease-out
			# | ease-in-out | step-start | step-end | steps(number[, start | end ])
			# | cubic-bezier(number, number, number, number)

			if $.is("function",speed)
				callback = speed
				speed = easing = null
			else if $.is("function",easing)
				callback = easing
				easing = null
			speed ?= "normal"
			easing or= "ease"
			# duration is always in milliseconds
			duration = $.duration(speed) + "ms"
			props = []
			# `trans` is what will be assigned to -webkit-transform
			trans = ""
			# real css values to be set (end_css without the transform values)
			css = {}
			for i of end_css
				# pull all the accelerated values out of end_css
				if accel_props_re.test(i)
					ii = end_css[i]
					if ii.join
						ii = $(ii).px().join COMMASEP
					else if ii.toString
						ii = ii.toString()
					trans += " " + i + "(" + ii + ")"
				# stick real css values in the css dict
				else css[i] = end_css[i]
			# make a list of the properties to be modified
			(props.push i) for i of css
			# and include -webkit-transform if we have transform values to set
			if trans
				props.push transformProperty

			# sets a list of properties to apply a duration to
			css[transitionProperty] = props.join COMMASEP
			# apply the same duration to each property
			css[transitionDuration] = props.map(-> duration).join COMMASEP
			# apply an easing function to each property
			css[transitionTiming] = props.map(-> easing).join COMMASEP

			# apply the transformation
			if trans
				css[transformProperty] = trans
			# apply the css to the actual node
			@css css
			# queue the callback to be executed at the end of the animation
			# WARNING: NOT EXACT!
			@delay duration, callback

		hide: (callback) -> # .hide() - each node gets display:none
			@each ->
				if @style
					@_display = "" # stash the old display
					if @style.display is not "none"
						@_display = @syle.display
					@style.display = "none"
			.trigger "hide"
			.delay updateDelay, callback

		show: (callback) -> # .show() - show each node
			@each ->
				if @style
					@style.display = @_display
					delete @_display
			.trigger "show"
			.delay updateDelay, callback

		toggle: (callback) -> # .toggle() - show each hidden node, hide each visible one
			@weave(@css("display"))
				.fold (display, node) ->
					if display is "none"
						node.style.display = node._display or ""
						delete node._display
						$(node).trigger "show"
					else
						node._display = display
						node.style.display = "none"
						$(node).trigger "hide"
					node
				.delay(updateDelay, callback)

		fadeIn: (speed, callback) -> # .fadeIn() - fade each node to opacity 1.0
			@.css('opacity','0.0')
				.show ->
					@transform {
						opacity:"1.0",
						translate3d: [0,0,0]
					}, speed, callback
		fadeOut: (speed, callback, x = 0.0, y = 0.0) -> # .fadeOut() - fade each node to opacity:0.0
			@transform {
				opacity:"0.0",
				translate3d:[x,y,0.0]
			}, speed, -> @hide(callback)
		fadeLeft: (speed, callback) -> @fadeOut speed, callback, "-"+@width().first(), 0.0
		fadeRight: (speed, callback) -> @fadeOut speed, callback, @width().first(), 0.0
		fadeUp: (speed, callback) -> @fadeOut speed, callback, 0.0, "-"+@height().first()
		fadeDown: (speed, callback)  -> @fadeOut speed, callback, 0.0, @height().first()
	}
