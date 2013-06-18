$.plugin
	depends: 'hook,synth,delay'
	provides: 'dialog'
, ->
	
	transition = (props, duration) ->
		props = props.split /, */
		["-webkit","-moz"].map((prefix) ->
			"#{prefix}-transition-property: #{props.join ', '}; #{prefix}-transition-duration: #{props.map(-> duration).join ", "};"
		).join ' '
	
	# inject css
	injectCSS = ->
		$('head style.dialog').remove()
		$.synth("style.dialog '
			.dialog, .modal { position: absolute; }
			.modal { background: rgba(0,0,0,.3); opacity: 0; }
			.dialog { box-shadow: 8px 8px 4px rgba(0,0,0,.4); border-radius: 8px; background: white; padding: 6px; #{transition "left", ".15s"} }
			.dialog > .title { text-align: center; width: 100%; }
			.dialog > .content { width: 100%; }
		'".replace(/\t+|\n+/g,' ')).prependTo("head")

	createDialog = (opts) ->
		opts = $.extend createDialog.getDefaultOptions(), opts
		injectCSS()
		dialogSynth = ""
		modal = $.synth("div.modal div.dialog##{opts.id} div.title + div.content")
			.appendTo("body")
			.click (evt) ->
				if evt.target is modal[0]
					$.log 'dialog: Cancelling because the modal was clicked.'
					opts.cancel(modal)
		dialog = modal.find('.dialog', 1)

		modal
			.delegate(".cancel", "click", (evt) -> opts.cancel(modal))
			.delegate(".ok", "click", (evt) -> opts.ok(modal))

		# fill in the content
		contentNode = dialog.find('.content', 1)
		contentNode.append createDialog.getContent opts.contentType, opts.content

		# fill in the title
		titleNode = dialog.find('.title', 1)
		titleNode.append createDialog.getContent opts.titleType, opts.title

		$(opts.target).bind('resize', (evt) ->
			modal.fitOver(opts.target).fadeIn(200)
			dialog.centerOn(modal).show()
		).trigger('resize')

		dialog
	
	createDialog.getDefaultOptions = ->
		id: "dialog-" + $.random.string 4
		target: "body"
		title: "Untitled Dialog"
		titleType: "text"
		content: "span 'Dialog Content'"
		contentType: "synth"
		ok: (modal) ->
			$.log "dialog: Closing from default ok"
			modal.emit('ok')
				.fadeOut(200, -> modal.remove())
		cancel: (modal) ->
			$.log "dialog: Closing from default cancel"
			modal.emit('cancel')
				.fadeOut(200, -> modal.remove())
				.find(".dialog", 1).css left: 0
	
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


