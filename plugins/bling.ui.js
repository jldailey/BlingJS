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
	
	function Movable(selector, opts) {
		opts = Object.Extend({
			handlePosition: {}
		}, opts)
		opts.handlePosition = Object.Extend({
			top: "0px",
			left: "0px",
			width: "100%",
			height: "4px"
		}, opts.handlePosition)

		var target = $(selector),
			moving = false,
			origin = [0, 0],
			handle = $.synth("div.handle")
				.css(Object.Extend({
					border: "1px solid red",
					cursor: "pointer",
					position: "absolute"
				}, opts.handlePosition))
				.bind('mousedown, touchstart', function mousedown(evt) {
					moving = true
				})
				.bind('mousemove, touchmove', function mousemove(evt) {
					if( moving ) {
						console.log("moving!")
					}
				})
				.bind('mouseup, touchend', function mouseup(evt) {
					moving = false
				})
		target.append(handle)
		return target
	}

	Movable.test = function() {
		if( $("body").find("div#movable-test").len() == 0 )
			$("body").append(
				$.synth("div#movable-test 'Hello'")
					.css({
						width: "200px", 
						height: "100px", 
						"line-height": "100px", 
						"text-align": "center"
					}))
		$.UI.Movable($("div#movable-test").center())
	}



	/*

	var sides = {
		n: 
	function applyAnchor(side, target) {
		var d = "div.anchor."+side
		if( target.find(d).len() === 0 ) {
			d = $.synth(d)
				.bind('mousedown, touchstart', function(evt) {
				})
				.bind('mousemove, touchmove', function(evt) {
				})
				.bind('mouseup, touchend', function(evt) {
				})
			node = target.prepend($.synth(d))
			switch (side) {
				case 'n':
		}
	}

	function Resizable(selector, opts) {
		opts = Object.Extend({
			anchors: "n ne e se s sw w nw"
		}, opts)
		opts.anchors = opts.anchors.split(/,* /)
		var $node = $(selector)
		for(var i = 0, n = opts.anchors.length; i < n; i++) {
			applyAnchor(opts.anchors[i], $node)
		}

	}
	*/

	function ProgressBar(selector, opts) {
		opts = Object.Extend({
			change: Function.Empty,
			backgroundColor: "#fff",
			barColor: "rgba(0,128,0,0.5)",
			textColor: "white"
		}, opts)

		var _progress = 0.0,
			node = $(selector)
				.addClass('progress-bar'),
			orig_bg = node.css("background").first(),
			orig_color = node.css("color").first()

		node.zap('update', function(pct) {
			while( pct > 1 ) pct /= 100;
			_progress = pct
			if( pct == 1 )
				node.css("background", orig_bg)
					.css("color", orig_color)
			else
				node.css("background", 
					"-webkit-gradient(linear, 0 0, "+parseInt(pct * 100)+"% 0, "
					+ "color-stop(0, "+opts.barColor+"), "
					+ "color-stop(0.93, "+opts.barColor+"), "
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

	function Tabs(tabs, bodies, opts) {
		opts = Object.Extend({
		}, opts)
		var $tabs = $(tabs),
			$bodies = $(bodies),
			i = 0, n = $tabs.len()
		while( i < n ) {
			$tabs.index(i).click(function(){
				$bodies.index(i).toggle()
			})
		}
	}

	function ViewStack(bodies, opts) {
		opts = Object.Extend({
			width: "auto",
			height: "auto"
		}, opts)
		var $bodies = $(bodies),
			$box = $.synth("div.box")

		$box.css({width: opts.width, height: opts.height})
	}

	return {

		$UI: {
			Movable: Movable,
			ProgressBar: ProgressBar,
		},

		dialog: function dialog(opts) {
			// .dialog([opts]) - create a dialog from each node
			return Dialog(this, opts)
		},
		progressBar: function progressBar(opts) {
			// .progressBar([opts]) - create a progress bar in each node
			return ProgressBar(this, opts)
		},

	}
})

})(Bling)
