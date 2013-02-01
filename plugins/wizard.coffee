$.plugin
	depends: 'dialog'
	provides: 'wizard'
, ->
	
	$: wizard: (slides) ->
		currentSlide = 0
		modal = $.dialog(slides[0]).select('parentNode')
		slideChanger = (delta) -> ->
			$.log "changing slide:", delta
			newSlide = (currentSlide + delta) % slides.length
			if newSlide < 0
				newSlide += slides.length
			$.log "new slide:", newSlide, "old slide:", currentSlide
			return if newSlide is currentSlide
			dialogs = modal.find('.dialog').log("dialogs")
			currentDialog = $ dialogs[currentSlide]
			newDialog = $ dialogs[newSlide]
			# adjust style.left to transition the old slide out of the way
			newLeft = 0
			if delta < 0
				newLeft = window.innerWidth
			else
				newLeft = -currentDialog.width().first()
			currentDialog.removeClass('wiz-active')
				.css left: $.px newLeft
			newDialog.addClass('wiz-active')
				.centerOn(modal)
				.show()
			currentSlide = newSlide
		modal.delegate '.wiz-next', 'click', slideChanger(+1)
		modal.delegate '.wiz-back', 'click', slideChanger(-1)

		for slide in slides.slice(1)
			d = $.synth('div.dialog div.title + div.content')
				.css( left: $.px window.innerWidth + 100 )
				.appendTo(modal)
			slide = $.extend $.dialog.getDefaultOptions(), slide
			$.log "adding slide:",slide
			d.find('.title').append $.dialog.getContent slide.titleType, slide.title
			d.find('.content').append $.dialog.getContent slide.contentType, slide.content


