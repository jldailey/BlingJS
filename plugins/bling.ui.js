;(function ($) {

$.plugin(function UI() {

	function Dialog(selector, opts) {
		var dialog = $(selector)
			.addClass("dialog")
			.center()
		opts = Object.Extend({
			autoOpen: false
		}, opts)
		dialog.open = dialog.show
		dialog.close = dialog.hide
		if( opts.autoOpen ) dialog.open()
		return dialog
	}
	
	function Draggable(selector, opts) {
		opts = Object.Extend({
			handlePosition: {}
		}, opts)

		opts.handlePosition = Object.Extend({
			position: "absolute",
			top: "0px",
			left: "0px",
			width: "100%",
			height: "5px"
		}, opts.handlePosition)

		var dragObject = $(selector),
			moving = false,
			originX = 0,
			originY = 0,
			originPOS = dragObject.position(),
			handle = $.synth("div.handle")
				.defaultCss({
					background: "-webkit-gradient(linear, 50% 0%, 50% 100%, from(#eee), color-stop(0.25, #bbb), color-stop(0.3, #eee), color-stop(0.5, #eee), to(#bbb))",
					"height": "5px",
					"border-radius": "1px",
					cursor: "move",
				})
				.css(opts.handlePosition)
				.bind('mousedown, touchstart', function (evt) {
					moving = true
					originX = originX || evt.pageX
					originY = originY || evt.pageY
					evt.preventDefault()
					evt.stopPropagation()
				})
			$(document).bind('mousemove, touchmove', function (evt) {
				if( moving ) {
					evt.preventDefault()
					evt.stopPropagation()
					var deltaX = (evt.pageX - originX),
						deltaY = (evt.pageY - originY)
					dragObject.transform({
						position: "absolute", 
						translate: [ deltaX, deltaY ] 
					}, 0)
					.trigger('drag',{
						dragObject: dragObject
					})
				}
			})
			.bind('mouseup, touchend', function (evt) {
				if( moving ) {
					moving = false
					var pos = handle.position()[0]
					$(document.elementFromPoint(pos.left, pos.top - 1))
						.log("pre-trigger")
						.trigger('drop', {
							dropObject: dragObject
						})
				}
			})

		return dragObject.css({
				position: "relative",
				"padding-top": dragObject.css("padding-top").map(Number.AtLeast(5)).px().first(),
			})
			.addClass("draggable")
			.append(handle)
	}

	function ProgressBar(selector, opts) {
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
		opts = Object.Extend({
			exclusive: false,
			sticky: false
		}, opts)
		var $node = $(selector),
			selectedChild = null

		function initRow(n) {
			var t = $(n),
				title = t.child(0),
				body = t.child(1),
				bodyVisible = false
			body.hide()
			title.unbind('click').click(function accordion_click() {
				if( opts.exclusive ) {
					$node.children().first()
						.find("*:first-child, *:first-child + *")
						.removeClass("selected")
						.filter("*:first-child + *")
						.hide()
				}
				if( bodyVisible ) {
					bodyVisible = false
					if( ! opts.sticky ) {
						body.hide()
						title.removeClass("selected")
					}
					else {
						body.show()
						title.addClass("selected")
					}
				} else {
					body.show()
					title.addClass("selected")
					bodyVisible = true
				}
			})
		}

		$node.bind("DOMNodeInserted", function _inserted(evt) {
			var t = $(evt.target).parents().first().intersect($node.children().first())
			if( t ) initRow(t)
		})

		$node.children().first().filter("*").map(initRow)

		return $node
	}

	function ViewStack(selector, opts) {
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

	return {

		$UI: {
			Draggable: Draggable,
			ProgressBar: ProgressBar,
			ViewStack: ViewStack
		},

		dialog: function dialog(opts) {
			// .dialog([opts]) - create a dialog from each node
			return Dialog(this, opts)
		},
		progressBar: function progressBar(opts) {
			// .progressBar([opts]) - create a progress bar from each node
			return ProgressBar(this, opts)
		},
		viewStack: function viewStack(opts) {
			return ViewStack(this, opts)
		}

	}
})

})(Bling)