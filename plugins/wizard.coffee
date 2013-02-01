$.plugin
	depends: 'dialog'
	provides: 'wizard'
, ->
	
	$: wizard: (slides) ->
		currentSlide = 0
		slideChanger = (delta) -> ->
			newSlide = (currentSlide + delta) % slides.length
			modal.find('.dialog').skip(newSlide).take(1).show()
		modal = $.dialog slides[0]
		modal.delegate '.dialog', 'show', (evt) ->
			modal.find('.dialog').hide().removeClass('wiz-active')
			$(evt.target).addClass('wiz-active')
		modal.delegate '.wiz-next', 'click', slideChanger(+1)
		modal.delegate '.wiz-back', 'click', slideChanger(-1)

		modal.find('.dialog').first(1).show()
		for slide in slides.slice(1)
			d = $.synth('div.dialog div.title + div.content').appendTo("modal").hide()
			slide = $.extend $.dialog.getDefaultOptions(), slide
			d.find('.title').append $.dialog.getContent slide.titleType, slide.title
			d.find('.content').append $.dialog.getContent slide.contentType, slide.content




