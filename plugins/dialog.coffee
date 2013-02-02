$.plugin
	depends: 'hook,synth,delay'
	provides: 'dialog'
, ->

	# inject css
	injectCSS = ->
		$('head style.dialog').remove()
		$.synth('style.dialog "
			.modal {
				position: absolute;
				background: rgba(0,0,0,.3);
			}
			.dialog {
				position: absolute;
				box-shadow: 8px 8px 4px rgba(0,0,0,.4);
				border-radius: 8px;
				background: white;
				padding: 6px;
				-webkit-transition-property: left;
				-webkit-transition-duration: .15s;
				-moz-transition-property: left;
				-moz-transition-duration: .15s;
			}
			.dialog > .title {
				text-align: center;
				width: 100%;
			}
			.dialog > .content {
				width: 100%;
			}
		"'.replace(/\t+/g,' ')).prependTo("head")

	createDialog = (opts) ->
		opts = $.extend createDialog.getDefaultOptions(), opts
		injectCSS()
		dialogSynth = "div.dialog##{opts.id} div.title + div.content"
		modal = $.synth("div.modal #{dialogSynth}")
			.appendTo("body")
			.click (evt) ->
				if evt.target is modal[0]
					$.log 'dialog: Closing because the modal was clicked.'
					opts.cancel(modal)
		dialog = modal.find('.dialog')

		modal
			.delegate(".cancel", "click", (evt) -> opts.cancel(modal))
			.delegate(".ok", "click", (evt) -> opts.ok(modal))

		# fill in the content
		contentNode = dialog.find('.content').take(1)
		contentNode.append createDialog.getContent opts.contentType, opts.content

		# fill in the title
		titleNode = dialog.find('.title').take(1)
		titleNode.append createDialog.getContent opts.titleType, opts.title

		# position the modal and the dialog
		modal.fitOver(opts.target) # position the modal to mask the target
			.show()
			.find('.dialog')
			.centerOn(modal)
			.show()
	
	createDialog.getDefaultOptions = ->
		id: "dialog-" + $.random.string 4
		target: "body"
		title: "Untitled Dialog"
		titleType: "text"
		content: "span 'Dialog Content'"
		contentType: "synth"
		ok: (modal) ->
			$.log "dialog: Closing from default ok"
			modal.remove()
		cancel: (modal) ->
			$.log "dialog: Closign from default cancel"
			modal.remove()
	
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


