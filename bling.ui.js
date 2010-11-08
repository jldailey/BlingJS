
Bling.module('UI', function() {
	Bling.UI = {}

	Bling.UI.Dialog = function Dialog(selector, opts) {
		var dialog = Bling(selector)
			.addClass("dialog")
			.center()
		opts = Bling.extend({
			autoOpen: false
		}, opts)
		dialog.open = dialog.show
		dialog.close = dialog.hide
		if( opts.autoOpen ) dialog.open()
		return dialog
	}

	Bling.UI.ProgressBar = function ProgressBar(selector, opts) {
		opts = Bling.extend({
			change: Function.Empty,
			showPercent: "center",
			barColor: "green",
			textColor: "black"
		}, opts)
		opts.invertedTextColor = Bling.Color.toCss(Bling.Color.invert(Bling.Color.fromCss))
		var node = Bling(selector)
				.addClass('progress-bar')
				.css({
					position: "relative",
					overflow: "hidden"
				}),
			slide = $("<div>").appendTo(node)
				.css({
					"background-color": opts.barColor,
					position: "absolute",
					width: "100%",
					height: "100%"
				}),
			label = $("<span>").appendTo(node)
				.css({
					display: opts.showPercent ? "block" : "none",
					"text-align": opts.showPercent,
					width: "100%",
					height: "100%"
				})

		node.update = function update(percent, speed) {
			speed = speed || "instant"
			if( percent < 0.0 ) percent *= -1.0
			while( percent > 1.0 ) percent /= 100.0
			label.text((percent * 100).toFixed(0) + "%")
				.css("color", percent > 0.5 ? opts.invertedTextColor : opts.textColor)
			percent = (1.0 - percent)
			slide.transform({translateX: node.width().scale(-percent).px().first()}, speed)
		}
		node.update(0.0, "instant")

		return node
	}

	Bling.UI.Accordion = function Accordion(selector, opts) {
		opts = Bling.extend({
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

	Bling.UI.Tabs = function Tabs(selector, opts) {
		opts = Bling.extend({
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

		dialog: function dialog(opts) {
			// .dialog([opts]) - create a dialog from each node
			return Bling.UI.Dialog(this, opts)
		},
		progressBar: function progressBar(opts) {
			// .progressBar([opts]) - create a progress bar in each node
			return Bling.UI.ProgressBar(this, opts)
		},
		tabs: function tabs(opts) {
			// .tabs([opts]) - create a tab set from this collection
			// (one tab per node in the set?)
			return Bling.UI.Tabs(this, opts)
		},
		accordion: function accordion(opts) {
			this.filter("*").map(function _accordion() {
				return Bling.UI.Accordion(this, opts)
			})
		},
		listSet: function listSet(opts) {
			// .listSet([opts]) - create a list set from this collection
			// list sets are like iPhone interfaces, ol's or li's and
			// when you click on an item it either moves to a new list
			// back to the previous list, or launches some action
			return Bling.UI.ListSet(this, opts)
		}

	}
})

		
