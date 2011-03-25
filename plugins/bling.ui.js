;(function ($) {

$.plugin(function UI() {

	function Dialog(selector, opts) {
		// $.UI.Dialog(selector, opts) - make a dialog
		var dialog = $(selector)
			.addClass("dialog")
			.center()
			.draggable()
		dialog
			.find("button.close, .close-button")
			.bind("click, touchstart", function () {
				dialog.hide()
				return false
			})
		opts = Object.Extend({
			autoOpen: false
		}, opts)
		if( opts.autoOpen ) dialog.show()
		return dialog
	}
	
	function Draggable(selector, opts) {
		// $.UI.Dialog(selector, opts) - make an object draggable
		opts = Object.Extend({
			handleLayout: {},
		}, opts)

		opts.handleLayout = Object.Extend({
			position: "absolute",
			top: "0px",
			left: "0px",
			width: "100%",
			height: "5px"
		}, opts.handleLayout)

		var dragObject = $(selector),
			moving = false,
			originX = 0,
			originY = 0,
			originPOS = dragObject.position(),
			// create a handle
			handle = $.synth("div.handle")
				// set the default appearance of the handle
				.defaultCss({
					background: "-webkit-gradient(linear, 50% 0%, 50% 100%, from(#eee), color-stop(0.25, #bbb), color-stop(0.3, #eee), color-stop(0.5, #eee), to(#bbb))",
					height: "6px",
					"border-radius": "3px",
					cursor: "move",
				})
				// force the handle's position
				.css(opts.handleLayout)
				// activate the handle with events for starting the drag
				.bind('mousedown, touchstart', function (evt) {
					moving = true
					originX = originX || evt.pageX
					originY = originY || evt.pageY
					console.log("origin:", [originX, originY])
					return false
				})
		$(document).bind('mousemove, touchmove', function (evt) {
			if( moving ) {
				var deltaX = (evt.pageX - originX),
					deltaY = (evt.pageY - originY)
				dragObject.transform({
					// position: "absolute", 
					translate: [ deltaX, deltaY ] 
				}, 0)
				.trigger('drag',{
					dragObject: dragObject
				})
				console.log("delta:", [ deltaX, deltaY ])
				return false
			}
		})
		.bind('mouseup, touchend', function (evt) {
			if( moving ) {
				moving = false
				var pos = handle.position()[0]
				$(document.elementFromPoint(pos.left, pos.top - 1))
					.trigger('drop', {
						dropObject: dragObject
					})
			}
		})

		return dragObject.addClass("draggable")
			// make room for the handle
			.css({
				position: "relative",
				"padding-top": dragObject.css("padding-top").map(Number.AtLeast(5)).px().first(),
			})
			// attach the handle
			.append(handle)
	}

	function ProgressBar(selector, opts) {
		// $.UI.ProgressBar - make a progress bar
		opts = Object.Extend({
			change: Function.Empty,
			// the color of the 'incomplete' part of the bar
			backgroundColor: "#fff",
			// the color of 'complete'
			barColor: "rgba(0,128,0,0.5)",
			// the color of text when on top of the 'barColor'
			textColor: "white",
			// whether to reset to the original style when the progress is complete
			reset: false 
		}, opts)

		var node = $(selector)
				.addClass('progress-bar'),
			_progress = 0.0
		if( opts.reset ) {
			var _bg = node.css("background").first(),
				_color = node.css("color").first()
		}

		node.zap('update', function(pct) {
			while( pct > 1 ) pct /= 100;
			_progress = pct
			if( pct == 1 && opts.reset )
				node.css("background", _bg)
					.css("color", _color)
			else
				node.css("background", 
					"-webkit-gradient(linear, 0 0, "+parseInt(pct * 100)+"% 0, "
					+ "color-stop(0, "+opts.barColor+"), "
					+ "color-stop(0.98, "+opts.barColor+"), "
					+ "color-stop(1.0, "+opts.backgroundColor+"))")
					.css("color", opts.textColor)
			if( Object.IsFunc(opts.change) )
				opts.change()
		})

		node.zap('progress', function() {
			return _progress
		})

		return node
	}

	function Accordion(selector, opts) {
		// $.UI.Accordion - make an accordion
		opts = Object.Extend({
			exclusive: false,
			sticky: false
		}, opts)
		var $node = $(selector).addClass("accordion"),
			selectedChild = null

		function initRow(n) {
			var t = $(n).children().first().filter("*"),
				title = t.eq(0)
					.addClass("title"),
				body = t.eq(1)
					.addClass("body")
					.hide(),
				bodyVisible = false
			title.unbind('click').click(function () {
				if( opts.exclusive ) {
					$node.find(".body")
						.hide()
				}
				if( bodyVisible ) {
					if( ! opts.sticky ) {
						body.hide().removeClass("visible")
						title.removeClass("selected").trigger("deselect")
						bodyVisible = false
					}
					else {
						body.show().addClass("visible")
						title.addClass("selected").trigger("select")
						bodyVisible = true
					}
				} else {
					body.show().addClass("visible")
					title.addClass("selected").trigger("select")
					bodyVisible = true
				}
			})
		}

		// dynamically added rows should auto-init themselves 
		$node.bind("DOMNodeInserted", function (evt) {
			// find the parent of the new node
			// that is a direct child of the accordion
			var t = $(evt.target).parents().first()
				.intersect($node.children().first().filter("*"))
			if( t ) 
				initRow(t)
		})

		$node.children().first()
			.filter("*") // only Nodes
			.map(initRow)

		return $node
	}

	function ViewStack(selector, opts) {
		// $.UI.ViewStack - make a set visually exclusive
		var items = $(selector)
			.css({
				position: "relative",
				top: "0px",
				left: "0px",
			})
			.hide()
			.map($),
			active = 0, j = 0, 
			nn = items.len()
		items[0].show()
		items.next = function() {
			items[active].hide()
			active = (++active % nn)
			items[active].show()
		}
		items.activate = function activate_one(k) {
			items[active].hide()
			items[k].show()
			active = k
		}
		for(; j < nn; j++) {
			items[j]
			.zap("_viewIndex", j)
			.zap("activate", function activate() {
				items.activate(this._viewIndex)
			})
		}
		return items
	}

	function Tabs(selector, views) {
		// $.UI.Tabs - make items control a viewstack
		var tabs = $(selector),
			views = $(views).viewStack(),
			nn = tabs.len(),
			i = 0
		while( i < nn )
			tabs[i]._tabIndex = i++
		$(tabs[0]).addClass("active")
		tabs.click(function tab_click() {
			tabs.removeClass("active")
			views.activate(this._tabIndex)
			$(this).addClass("active")
		})
		return tabs
	}

	return {

		$UI: {
			Draggable: Draggable,
			ProgressBar: ProgressBar,
			ViewStack: ViewStack,
			Tabs: Tabs,
			Accordion: Accordion
		},

		dialog: function (opts) {
			// .dialog([opts]) - create a dialog from each node
			return Dialog(this, opts)
		},
		progressBar: function (opts) {
			// .progressBar([opts]) - create a progress bar from each node
			return ProgressBar(this, opts)
		},
		viewStack: function (opts) {
			// .viewStack([opts]) - make a set of nodes visually exclusive
			return ViewStack(this, opts)
		},
		tabs: function (views) {
			// .tabs([views]) - make a set of nodes control a viewstack
			return Tabs(this, views)
		},
		accordion: function (opts) {
			// .accordion([opts]) - make this an accordion
			return Accordion(this, opts)
		},
		draggable: function (opts) {
			// .draggable([opts]) - make this draggable
			return Draggable(this, opts)
		}

	}
})

})(Bling)
