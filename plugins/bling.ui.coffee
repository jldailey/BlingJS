(($) ->

	$.plugin () ->

		Dialog(selector, opts) ->
			# $.UI.Dialog(selector, opts) - make a dialog
			opts = Object.Extend({
				autoOpen: false
				draggable: true
			}, opts)
			dialog = $(selector)
				.addClass("dialog")
			if opts.draggable
				dialog.draggable()
			if opts.autoOpen
				dialog.show().center()
			dialog
				.find("button.close, .close-button")
				.bind "click touchstart", () ->
					dialog.hide()
					false
			dialog
		
		Draggable(selector, opts) ->
			# $.UI.Dialog(selector, opts) - make an object draggable
			opts = Object.Extend({
				handleCSS: {}
			}, opts)

			opts.handleCSS = Object.Extend({
				position: "absolute"
				top: "0px"
				left: "0px"
				width: "100%"
				height: "6px"
			}, opts.handleCSS)

			dragObject = $(selector)
			moving = false
			oX = oY = 0
			handle = $
				# create a handle
				.synth("div.handle")
				# set the default appearance of the handle
				.defaultCss {
					background: "-webkit-gradient(linear, 50% 0%, 50% 100%, from(#eee), color-stop(0.25, #bbb), color-stop(0.3, #eee), color-stop(0.5, #eee), to(#bbb))"
					height: "6px"
					"border-radius": "3px"
					cursor: "move"
				}
				# force the handle's position, and any display overrides passed in as an option
				.css opts.handleCSS
				# activate the handle with events for starting the drag
				.bind 'mousedown, touchstart', (evt) ->
					moving = true
					oX or= evt.pageX
					oY or= evt.pageY
					false
			$ document
			.bind 'mousemove, touchmove', (evt) ->
				if moving
					dX = (evt.pageX - oX)
					dY = (evt.pageY - oY)
					dragObject.transform({
						# position: "absolute", 
						translate: [ dX, dY ]
					}, 0)
					.trigger 'drag', {
						dragObject: dragObject
					}
					false
			.bind 'mouseup, touchend', (evt) ->
				if moving
					moving = false
					pos = handle.position()[0]
					$ document.elementFromPoint(pos.left, pos.top - 1)
					.trigger 'drop', {
						dropObject: dragObject
					}

			dragObject
				.addClass("draggable")
				# make room for the handle
				.css {
					position: "relative"
					"padding-top": dragObject.css("padding-top")
						.map(Number.AtLeast(parseInt(opts.handleCSS.height,10)))
						.px().first()
				}
				# attach the handle
				.append(handle)

		ProgressBar(selector, opts) ->
			# $.UI.ProgressBar - make a progress bar
			opts = Object.Extend({
				change: Function.Empty
				# the color of the 'incomplete' part of the bar
				backgroundColor: "#fff"
				# the color of 'complete'
				barColor: "rgba(0,128,0,0.5)"
				# the color of text when on top of the 'barColor'
				textColor: "white"
				# whether to reset to the original style when the progress is complete
				reset: false
			}, opts)

			node = $(selector)
				.addClass('progress-bar')
			_progress = 0.0
			if( opts.reset ) # save the original styles
				_bg = node.css("background").first()
				_color = node.css("color").first()

			node.zap 'updateProgress', (pct) ->
				while pct > 1
					pct /= 100
				_progress = pct
				if pct == 1 and opts.reset # restore original styles
					node.css("background", _bg)
						.css("color", _color)
				else
					node.css {
						background:
							"-webkit-gradient(linear, 0 0, "+parseInt(pct * 100)+"% 0, " +
							"color-stop(0, "+opts.barColor+"), " +
							"color-stop(0.98, "+opts.barColor+"), " +
							"color-stop(1.0, "+opts.backgroundColor+"))"
						color: opts.textColor
					}
				if Object.IsFunc(opts.change)
					opts.change(_progress)

		Accordion(selector, opts) ->
			# $.UI.Accordion - make an accordion
			opts = Object.Extend({
				exclusive: false
				sticky: false
			}, opts)
			node = $(selector).addClass("accordion")
			selectedChild = null

			initRow = (n) ->
				t = $(n).children().first().filter("*")
				if( t.len() isnt 2 )
					throw Exception("accordion row requires 2 elements, not #{t.len()}")
				title = t.eq(0).addClass("title")
				body = t.eq(1).addClass("body").hide()
				bodyVisible = false
				title.click () ->
					if opts.exclusive
						node.find(".body").hide()
					if bodyVisible
						if not opts.sticky
							body.hide().removeClass("visible")
							title.removeClass("selected").trigger("deselect")
							bodyVisible = false
						else
							body.show().addClass("visible")
							title.addClass("selected").trigger("select")
							bodyVisible = true
					else
						body.show().addClass("visible")
						title.addClass("selected").trigger("select")
						bodyVisible = true

			# set up dynamically added rows so they auto-init themselves 
			node.bind "DOMNodeInserted", (evt) ->
				# find the parent of the new node
				# that is a direct child of the accordion
				directChildren = node.children().first().filter("*")
				parentsOfInserted = $(evt.target).parents().first()
				initRow(parentsOfInserted.intersect(directChildren))

			node.children().first()
				.filter("*") # only Nodes
				.map(initRow)

			return node

		ViewStack(selector, opts) ->
			# $.UI.ViewStack - make a set visually exclusive
			items = $(selector)
				.css {
					position: "relative"
					top: "0px"
					left: "0px"
				}
				.hide()
				.map($)
			active = 0
			items[active].show()
			items.next = () ->
				items[active].hide()
				active = (++active % nn)
				items[active].show()
			items.activate = (k) ->
				items[active].hide()
				active = k
				items[k].show()
			for j in [0...items.len()]
				items[j]
				.zap "_viewIndex", j
				.zap "activate", () ->
					items.activate(this._viewIndex)
			items

		Tabs(selector, views) ->
			# $.UI.Tabs - make tab items control a viewstack
			tabs = $(selector)
			views = $(views).viewStack()
			nn = tabs.len()
			tabs._tabIndex = i for i in [0..nn]
			$(tabs[0]).addClass("active")
			tabs.click () ->
				tabs.removeClass("active")
				views.activate(this._tabIndex)
				$(this).addClass("active")

		return {
			name: 'UI'
			$: {
				UI: {
					Draggable: Draggable
					ProgressBar: ProgressBar
					ViewStack: ViewStack
					Tabs: Tabs
					Accordion: Accordion
				}
			}

			dialog: (opts) ->
				# .dialog([opts]) - create a dialog from each node
				return Dialog(this, opts)
			progressBar: (opts) ->
				# .progressBar([opts]) - create a progress bar from each node
				return ProgressBar(this, opts)
			viewStack: (opts) ->
				# .viewStack([opts]) - make this set of nodes visually exclusive
				return ViewStack(this, opts)
			tabs: (views) ->
				# .tabs([views]) - make this set of nodes control the views
				return Tabs(this, views)
			accordion: (opts) ->
				# .accordion([opts]) - make this an accordion
				return Accordion(this, opts)
			draggable: (opts) ->
				# .draggable([opts]) - make this draggable
				return Draggable(this, opts)
		}

)(Bling)

# vim: ft=coffee
