$.plugin
	provides: 'prompt,confirm',
	depends: 'synth,keyName'
, ->

	_prompt_css = ->
		unless $("head .prompt").length
			$("head").append "<style class='prompt'>" + $.CSS.stringify(
				".prompt":
					position: "absolute"
					top: 0, left: 0
					width: "100%", height: "100%"
					zIndex: "999999"
					background: "rgba(0,0,0,.4)"
					fontSize: "12px"
					" input":
						padding: "2px"
						margin: "0px 0px 4px -4px"
						width: "100%"
					" button":
						fontSize: "13px"
						".done":
							fontSize: "14px"
					" > center":
						width: "200px"
						height: "44px"
						margin: "20px auto"
						padding: "16px"
						background: "#ffc"
						borderRadius: "5px"
			) + "</style>"

	_prompt = (label, type, cb) ->
		_prompt_css()

		dialog = $.synth("""
			div.prompt center
				input[type=#{type}][placeholder=#{label}] + br +
				button.cancel 'Cancel' +
				button.done 'Done'
		""").appendTo("body").first()

		input = dialog.querySelector("input")
		input.onkeydown = (evt) ->
			switch $.keyName evt.keyCode
				when "Enter"
					done input.value
				when "Esc"
					done null
		doneButton = dialog.querySelector "button.done"
		cancelButton = dialog.querySelector "button.cancel"
		done = (value) ->
			delete doneButton.onclick
			delete cancelButton.onclick
			dialog.parentNode.removeChild(dialog)
			cb value
		doneButton.onclick = -> done input.value
		cancelButton.onclick = -> done null
		null

	_confirm = (args...) ->
		cb = args.pop()
		label = args.shift()
		if args.length > 0
			buttons = args
		else
			buttons = { Yes: true, No: false }
		_prompt_css()

		dialog = $.synth("""
			div.prompt center
				span '#{label}' + br
		""").appendTo("body")

		center = dialog.find('center')
		switch $.type(buttons)
			when 'array','bling'
				for label in buttons
					$.synth("button[value=#{label}] '#{label}'").appendTo center
			when 'object'
				for label,value of buttons
					$.synth("button[value=#{value}] '#{label}'").appendTo center
		dialog.find("button").bind "click", (evt) ->
			dialog.remove()
			cb evt.target.getAttribute('value')
		null

	return $: { prompt: _prompt, confirm: _confirm }
