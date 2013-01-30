$.plugin
	depends: 'dialog'
	provides: 'wizard'
, ->
	
	$: wizard: (slides) ->
		currentSlide = 0
		slideNext = ->
		slideBack = ->

