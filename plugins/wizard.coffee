$.plugin
	depends: 'dialog'
	provides: 'wizard'
, ->
	$: wizard: (slides...) ->
		if slides.length is 1 and $.type(slides[0]) in ['array','bling']
			slides = slides[0]
		currentSlide = 0
		modal = $.dialog(slides[0]).select('parentNode')
		dialogs = []
		slideChanger = (delta) ->
			return $.identity unless slides.length
			->
				newSlide = (currentSlide + delta) % slides.length
				while newSlide < 0
					newSlide += slides.length
				return if newSlide is currentSlide
				currentDialog = $ dialogs[currentSlide]
				newDialog = $ dialogs[newSlide]
				# adjust style.left to transition the old slide out of the way
				newLeft = if delta < 0 then window.innerWidth else -currentDialog.width()[0] * 1.5
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
			d.find('.title').append $.dialog.getContent slide.titleType, slide.title
			d.find('.content').append $.dialog.getContent slide.contentType, slide.content

		dialogs = modal.find('.dialog')
		modal


