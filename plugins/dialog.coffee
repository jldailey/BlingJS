$.plugin
	depends: 'hook,synth,delay'
	provides: 'dialog'
, ->

	# inject css
	injectCSS = ->
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

	createDialog = (opts) ->
		opts = $.extend createDialog.getDefaultOptions(), opts
		injectCSS()
		modal = $.synth("div.modal##{opts.id} div.dialog div.title + div.content") # h1.title button.cancel 'X' ++ div.content")
			.appendTo("body") # append ourselves to the DOM so we start functioning as nodes
			.click((evt) -> opts.cancel(modal))
			.delegate(".cancel", "click", (evt) -> opts.cancel(modal)) # all class='cancel' and class='ok' nodes are bound to
			.delegate(".ok", "click", (evt) -> opts.ok(modal))

		# fill in the content
		contentNode = modal.find('.dialog > .content').take(1)
		contentNode.append createDialog.getContent opts.contentType, opts.content

		# fill in the title
		titleNode = modal.find('.dialog > .title').take(1)
		titleNode.append createDialog.getContent opts.titleType, opts.title

		# position the modal and the dialog
		modal.fitOver(opts.parent) # position the modal to mask the parent
			.show()
			.find('.dialog') # select the dialog itself
			.centerOn(modal) # center it on the new modal position
			.hide()
			.take(1)
			.show()
	
	createDialog.getDefaultOptions = ->
		id: "dialog-" + $.random.string 4
		parent: "body"
		title: "Untitled Dialog"
		titleType: "text"
		content: "span 'Dialog Content'"
		contentType: "synth"
		ok: (modal) -> modal.remove()
		cancel: (modal) -> modal.remove()
	
	createDialog.getContent = (type, stuff) ->
		switch type
			when "synth" then $.synth(stuff)
			when "html" then $.HTML.parse(stuff)
			when "text" then document.createTextNode(stuff)
	

	return {
		$:
			dialog: createDialog

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


