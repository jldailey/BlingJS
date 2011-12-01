(($) ->

	$.plugin () -> # LazyLoader plugin, depends on PubSub
		create = (elementName, props) ->
			Object.Extend document.createElement(elementName), props

		lazy_load = (elementName, props) ->
			depends = provides = null
			n = create elementName, Object.Extend(props, {
				onload: () ->
					if provides?
						$.publish(provides)
			})
			$("head").delay 10, () ->
				if depends?
					$.subscribe depends, () => @append(n)
				else
					@append(n)
			n = $(n)
			Object.Extend n, {
				depends: (tag) -> depends = elementName+"-"+tag; n
				provides: (tag) -> provides = elementName+"-"+tag; n
			}

		return {
			name: "LazyLoader"
			$:
				script: (src) ->
					lazy_load "script", { src: src }
				style: (src) ->
					lazy_load "link", { href: src, rel: "stylesheet" }
		}

)(Bling)
