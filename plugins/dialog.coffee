$.plugin
	depends: 'hook,synth,delay'
	provides: 'dialog'
, ->

	# inject css
	$('head style.dialog').remove()
	$.synth('style.dialog "
		.dialog {
				position: absolute;
				background: white;
				border: 4px solid blue;
				border-radius: 10px;
				padding: 6px;
		}
		.dialog > .title {
				padding: 6px 0 4px 0;
				margin: 0 0 6px 0;
				font-size: 22px;
				line-height: 32px;
				text-align: center;
				border-bottom: 1px solid #eaeaea;
		}
		.dialog > .title > .cancel {
				float: right;
				width: 32px;
				height: 32px;
				border: 1px solid red;
				font-size: 22px;
				font-weight: bold;
				font-family: arial, helvetica;
		}
		.dialog > .content {
			text-align: center;
		}
		.modal {
			position: absolute;
			background: rgba(0,0,0,0.4);
		}
	"').appendTo("head")

	getContent = (type, stuff) ->
		switch type
			when "synth" then $.synth(stuff)
			when "html" then $.HTML.parse(stuff)
			when "text" then document.createTextNode(stuff)
	
	createDialog = (opts) ->
		modal = $.synth("div.modal##{opts.id} div.dialog h1.title button.cancel 'X' ++ div.content")
			.appendTo("body") # append ourselves to the DOM so we start functioning as nodes
			.click((evt) -> opts.cancel(modal))
			.delegate(".cancel", "click", (evt) -> opts.cancel(modal)) # all class='cancel' and class='ok' nodes are bound to
			.delegate(".ok", "click", (evt) -> opts.ok(modal))

		# fill in the content
		contentNode = modal.find('.dialog > .content')
		contentNode.append getContent opts.contentType, opts.content

		# fill in the title
		titleNode = modal.find('.dialog > .title')
		titleNode.append getContent opts.titleType, opts.title

		modal.fitOver(opts.parent) # position the modal to mask the parent
			.show()
			.select('childNodes.0') # select the dialog itself
			.centerOn(modal) # center it on the new modal position

	return {
		$:
			dialog: (opts) ->
				defaults = {
					id: "dialog-" + $.random.string 4
					parent: "body"
					title: "Untitled Dialog"
					titleType: "text"
					content: "span 'Dialog Content'"
					contentType: "synth"
					ok: (modal) -> modal.remove()
					cancel: (modal) -> modal.remove()
				}
				createDialog $.extend defaults, opts

		fitOver: (elem = window) ->
			if elem is window
				rect =
					width: window.innerWidth
					height: window.innerHeight
					top: 0
					left: 0
			else
				rect = $(elem).rect().first()
			@css
				position: 'absolute'
				width: $.px rect.width
				height: $.px rect.height
				top: $.px rect.top
				left: $.px rect.left

		centerOn: (elem = window) ->
			if elem is window
				target =
					width: window.innerWidth
					height: window.innerHeight
					top: 0
					left: 0
			else
				target = $(elem).rect().first()
			top = target.height / 2
			left = target.width / 2
			@each ->
				dialog = $ @
				rect = dialog.rect().first()
				dialog.css
					top: $.px top - (rect.height / 2)
					left: $.px left - (rect.width / 2)
	}


