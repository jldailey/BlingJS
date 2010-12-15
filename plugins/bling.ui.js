
Bling.plugin(function UI() {

	function Dialog(selector, opts) {
		var dialog = Bling(selector)
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

	function ProgressBar(selector, opts) {
		opts = Object.Extend({
			change: Function.Empty,
			backgroundColor: "#fff",
			barColor: "rgba(0,128,0,0.5)",
			textColor: "white"
		}, opts)

		var _progress = 0.0,
			node = Bling(selector)
				.addClass('progress-bar'),
			orig_bg = node.css("background").first(),
			orig_color = node.css("color").first()

		node.update = function(pct) {
			while( pct > 1 ) pct /= 100;
			_progress = pct
			if( pct == 1 )
				node.css("background", orig_bg)
					.css("color", orig_color)
			else
				node.css("background", 
					"-webkit-gradient(linear, 0 0, "+parseInt(pct * 100)+"% 0, "
					+ "color-stop(0, "+opts.barColor+"), "
					+ "color-stop(0.92, "+opts.barColor+"), "
					+ "color-stop(1.0, "+opts.backgroundColor+"))")
					.css("color", opts.textColor)
		}

		node.progress = function() {
			return _progress
		}

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

	function Tabs(selector, opts) {
		opts = Object.Extend({
		}, opts)
		var node = Bling.UI.Accordion(selector, {sticky: true, exclusive: true})

		// force things into tab-like orientation
		node.css({position: "relative" })
			.children().first()
			.css({position: "static", 'float': "left" })
			.find("*:first-child + *")
			.css({position: "absolute", 
				'top': node.children().first().filter("*").take(1).height().px(+2).first(), 
				left: "2px"})

		return node
	}

	return {

		$UI: {
			Dialog: Dialog,
			ProgressBar: ProgressBar,
			Accordion: Accordion,
			Tabs: Tabs
		},

		dialog: function dialog(opts) {
			// .dialog([opts]) - create a dialog from each node
			return Dialog(this, opts)
		},
		progressBar: function progressBar(opts) {
			// .progressBar([opts]) - create a progress bar in each node
			return ProgressBar(this, opts)
		},
		accordion: function accordion(opts) {
			this.filter("*").map(function () {
				return Accordion(this, opts)
			})
		},
		tabs: function tabs(opts) {
			// .tabs([opts]) - create a tab set from this collection
			// (one tab per node in the set?)
			return Tabs(this, opts)
		}

	}
})
