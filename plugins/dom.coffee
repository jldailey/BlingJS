# DOM Plugin
# ----------
# Only works if there is a global document.
if $.global.document?
	$.plugin
		depends: "function,type,string"
		provides: "dom"
	, ->
		bNodelistsAreSpecial = false
		$.type.register "nodelist",
			is:  (o) -> o? and $.isType "NodeList", o
			hash:   (o) -> $($.hash(i) for i in x).sum()
			array:  do ->
				try # probe to see if this browsers allows direct modification of a nodelist's prototype
					document.querySelectorAll("xxx").__proto__ = {}
					return $.identity
				catch err # if we can't patch directly, we have to copy into a real array :(
					bNodelistsAreSpecial = true
					return (o) -> (node for node in o)
			string: (o) -> "{Nodelist:["+$(o).select('nodeName').join(",")+"]}"
			node:   (o) -> $(o).toFragment()
		$.type.register "node",
			is:  (o) -> o?.nodeType > 0
			hash:   (o) -> $.checksum(o.nodeName) + $.hash(o.attributes) + $.checksum(o.innerHTML)
			string: (o) -> o.toString()
			node:   $.identity
		$.type.register "fragment",
			is:  (o) -> o?.nodeType is 11
			hash:   (o) -> $($.hash(x) for x in o.childNodes).sum()
			string: (o) -> o.toString()
			node:   $.identity
		$.type.register "html",
			is:  (o) -> typeof o is "string" and (s=o.trimLeft())[0] == "<" and s[s.length-1] == ">"
			# Convert html to node.
			node:   (h) ->
				# Put the html into a new div.
				(node = document.createElement('div')).innerHTML = h
				# If there's only one resulting child, return that Node.
				if (n = (childNodes = node.childNodes).length) is 1
					return node.removeChild(childNodes[0])
				# Otherwise, copy all the div's children into a new
				# fragment.
				df = document.createDocumentFragment()
				df.appendChild(node.removeChild(childNodes[0])) for i in [0...n] by 1
				df
			array:  (o) -> $.type.lookup(h = $.HTML.parse o).array h
			string: (o) -> "'#{o}'"
			repr:   (o) -> '"' + o + '"'
		$.type.extend
			unknown:  { node: -> null }
			bling:    { node: (o) -> o.toFragment() }
			# Convert a node to an html string.
			node:     { html: (n) ->
				d = document.createElement "div"
				d.appendChild (n = n.cloneNode true)
				# Uses .innerHTML to render the HTML.
				ret = d.innerHTML
				d.removeChild n # break links to prevent leaks
				ret
			}
			string:
				node:  (o) -> $(o).toFragment()
				array: do ->
					if bNodelistsAreSpecial
						(o) -> $.type.lookup(nl = document.querySelectorAll o).array(nl)
					else
						(o) -> document.querySelectorAll o
			function: { node: (o) -> $(o.toString()).toFragment() }

		toFrag = (a) ->
			if not a.parentNode?
				df = document.createDocumentFragment()
				df.appendChild a
			a
		before = (a,b) -> toFrag(a).parentNode.insertBefore b, a
		after = (a,b) -> toFrag(a).parentNode.insertBefore b, a.nextSibling
		toNode = (x) -> $.type.lookup(x).node x
		escaper = false
		parser = false

		# window.getComputedStyle is not a normal function
		# (it doesnt support .call() so we can't use it with .map())
		# so define something that does work properly for use in .css
		$.computeCSSProperty = computeCSSProperty = (k) -> -> $.global.getComputedStyle(@, null).getPropertyValue k

		getOrSetRect = (p) -> (x) -> if x? then @css(p, x) else @rect().select p

		selectChain = (prop) -> -> @map (p) -> $( p while p = p[prop] )

		return {
			$:

				# `$.HTML` provides methods similar to the global JSON
				# object, for parsing from and to HTML.
				HTML:
					# Parse the html in string h into a node or fragment.
					parse: (h) -> $.type.lookup(h).node h
					# Convert a node or fragment to an HTML string.
					stringify: (n) -> $.type.lookup(n).html n
					# Escape html characters in _h_, so "<" becomes `&lt;`, etc.
					escape: (h) ->
						# Create a singleton div with a text node within it.
						escaper or= $("<div>&nbsp;</div>").child 0
						# Insert _h_ using the text node's .data property,
						# then get escaped html from the _parent's_ innerHTML.
						ret = escaper.zap('data', h).select("parentNode.innerHTML").first()
						# Clean up so content doesn't litter.
						escaper.zap('data', '')
						ret

			# Get [or set] innerHTML for each node.
			html: (h) ->
				return switch $.type h
					when "undefined","null" then @select 'innerHTML'
					when "string","html" then @zap 'innerHTML', h
					when "bling" then @html h.toFragment()
					when "node"
						@each -> # replace all our children with the new child
							@replaceChild @childNodes[0], h
							while @childNodes.length > 1
								@removeChild @childNodes[1]

			append: (x) -> # .append(/n/) - insert /n/ [or a clone] as the last child of each node
				x = toNode(x) # parse, cast, do whatever it takes to get a Node or Fragment
				@each (n) -> n?.appendChild? x.cloneNode true

			appendText: (text) ->
				node = document.createTextNode(text)
				@each -> @appendChild node.cloneNode true

			appendTo: (x) -> # .appendTo(/n/) - each node [or fragment] will become the last child of x
				clones = @map( -> @cloneNode true)
				i = 0
				$(x).each -> @appendChild clones[i++]
				clones

			prepend: (x) -> # .prepend(/n/) - insert n [or a clone] as the first child of each node
				if x?
					x = toNode x
					@take(1).each -> switch
						when @childNodes.length > 0 then before @childNodes[0], x
						else @appendChild x
					# if we are inserting into multiple places, we insert clones into the latter slots
					@skip(1).each -> switch
						when @childNodes.length then before @childNodes[0], x.cloneNode true
						else @appendChild x.cloneNode true
				@

			prependTo: (x) -> # .prependTo(/n/) - each node [or a fragment] will become the first child of x
				if x?
					$(x).prepend(@)
				@

			before: (x) -> # .before(/x/) - insert content x before each node
				if x?
					x = toNode x
					@take(1).each -> before @, x
					@skip(1).each -> before @, x.cloneNode true
				@

			after: (x) -> # .after(/n/) - insert content n after each node
				if x?
					x = toNode x
					@take(1).each -> after @, x
					@skip(1).each -> after @, x.cloneNode true
				@

			wrap: (parent) -> # .wrap(/parent/) - parent becomes the new .parentNode of each node
				parent = toNode parent
				if $.is "fragment", parent
					throw new Error("cannot call .wrap() with a fragment as the parent")
				@each (child) ->
					if ($.is "fragment", child) or not child.parentNode
						return parent.appendChild child
					grandpa = child.parentNode
					# swap out the DOM nodes using a placeholder element
					marker = document.createElement "dummy"
					# put a marker in the DOM, put removed node in new parent
					parent.appendChild grandpa.replaceChild marker, child
					# replace marker with new parent
					grandpa.replaceChild parent, marker

			unwrap: -> # .unwrap() - replace each node's parent with itself
				@each ->
					if @parentNode and @parentNode.parentNode
						@parentNode.parentNode.replaceChild(@, @parentNode)
					else if @parentNode
						@parentNode.removeChild(@)

			replace: (n) -> # .replace(/n/) - replace each node with a clone of n
				if $.is 'regexp', n
					r = arguments[1]
					return @map (s) -> s.replace(n, r)
				n = toNode n
				clones = @map(-> n.cloneNode true)
				for i in [0...clones.length] by 1
					@[i].parentNode?.replaceChild clones[i], @[i]
				clones

			attr: (a,v) -> # .attr(a, [v]) - get [or set] an /a/ttribute [/v/alue]
				if $.is 'object', a
					@attr(k,v) for k,v of a
				else switch v
					when undefined
						return @select("getAttribute").call(a, v)
					when null
						@select("removeAttribute").call(a, v)
					else
						@select("setAttribute").call(a, v)
				@

			data: (k, v) -> @attr "data-#{$.dashize(k)}", v

			addClass: (x) -> # .addClass(/x/) - add x to each node's .className
				notempty = (y) -> y isnt ""
				@removeClass(x).each ->
					c = @className.split(" ").filter notempty
					c.push x
					@className = c.join " "

			removeClass: (x) -> # .removeClass(/x/) - remove class x from each node's .className
				notx = (y) -> y != x
				@each ->
					c = @className.split(" ").filter(notx).join(" ")
					if c.length is 0
						@removeAttribute('class')

			toggleClass: (x) -> # .toggleClass(/x/) - add, or remove if present, class x from each node
				notx = (y) -> y isnt x
				@each ->
					cls = @className.split(" ")
					filter = $.not $.isEmpty
					if( cls.indexOf(x) > -1 )
						filter = $.and notx, filter
					else
						cls.push x
					c = cls.filter(filter).join(" ")
					@className = c
					if c.length is 0
						@removeAttribute('class')

			hasClass: (x) -> # .hasClass(/x/) - true/false for each node: whether .className contains x
				@select('className.split').call(" ").select('indexOf').call(x).map (x) -> x > -1

			text: (t) -> # .text([t]) - get [or set] each node's .textContent
				return @zap('textContent', t) if t?
				return @select('textContent')

			val: (v) -> # .val([v]) - get [or set] each node's .value
				return @zap('value', v) if v?
				return @select('value')

			# Get [or set] css properties.
			css: (key,v) ->
				# If we are doing assignment.
				if v? or $.is('object', key)
					# Use a bound-method to do the assignment for us.
					setters = @select 'style.setProperty'
					# If you give an object as a key, then use every k:v pair.
					if $.is "object", key then setters.call k, v, "" for k,v of key
					# If the value was actually an array of values, then
					# stripe the values across each item.
					else if $.is "array", v
						for i in [0...n = Math.max v.length, nn = setters.length] by 1
							setters[i%nn](key, v[i%n], "")
					else if $.is 'function', v
						values = @select("style.#{key}") \
							.weave(@map computeCSSProperty key) \
							.fold($.coalesce) \
							.weave(setters) \
							.fold (setter, value) -> setter(key, v.call value, value)
					# So, the key is simple, and if the value is a string,
					# just do simple assignment (using setProperty).
					else setters.call key, v, ""
					return @
				# Else, we are reading CSS properties.
				else @select("style.#{key}") \
					.weave(@map computeCSSProperty key) \
					.fold($.coalesce)

			# Set css properties by injecting a style element in the the
			# head. If _k_ is an object of k:v pairs, then no second argument is needed.
			defaultCss: (k, v) ->
				# @selector need not match any nodes at the time of the call.
				sel = @selector
				style = ""
				if $.is "string", k
					if $.is "string", v
						style += "#{sel} { #{k}: #{v} } "
					else throw Error("defaultCss requires a value with a string key")
				else if $.is "object", k
					style += "#{sel} { " +
						"#{i}: #{k[i]}; " for i of k +
					"} "
				$("<style></style>").text(style).appendTo("head")
				@

			# Get a bounding-box for each item.
			rect: -> @map (item) -> switch item
				when window then {
					width: window.innerWidth
					height: window.innerHeight
					top: 0
					left: 0
					right: window.innerWidth
					bottom: window.innerHeight
				}
				else item.getBoundingClientRect()

			# Get [or set] each item's width.
			width: getOrSetRect("width")

			# Get [or set] each item's height.
			height: getOrSetRect("height")

			# Get [or set] each item's top.
			top: getOrSetRect("top")

			# Get [or set] each item's left.
			left: getOrSetRect("left")

			# Get [or set] each item's bottom.
			bottom: getOrSetRect("bottom")

			# Get [or set] each item's right.
			right: getOrSetRect("right")

			# Get [or set] each item's position.
			position: (left, top) ->
				switch
					# If called with no arguments, just return the position.
					when not left? then @rect()
					# If called with only one argument, only set "left".
					when not top? then @css("left", $.px(left))
					# If called with both arguments, set "top" and "left".
					else @css({top: $.px(top), left: $.px(left)})

			# Adjust the document's scroll position so the first node in
			# _this_ is centered in the viewport.
			scrollToCenter: ->
				document.body.scrollTop = @[0].offsetTop - ($.global.innerHeight / 2)
				@

			# Get the _n-th_ child from each node in _this_.
			child: (n) -> @select('childNodes').map -> @[ if n < 0 then (n+@length) else n ]

			# Collect the full ancestry of each node, including the owner document.
			parents: selectChain('parentNode')

			# Collect the full chain of previous siblings.
			prev: selectChain('previousSibling')

			# Collect the full chain of next siblings.
			next: selectChain('nextSibling')

			# Remove each node from the DOM.
			remove: -> @each -> @parentNode?.removeChild(@)

			# Collect sub-nodes that match _css_, using **querySelectorAll**.
			find: (css, limit = 0) ->
				# Filter the input set to only DOM nodes.
				@filter("*")
					# Use each node as the context for creation of a new bling.
					.map(
						switch limit
							when 0 then (-> @querySelectorAll css)
							when 1 then (-> $ @querySelector css)
							else (-> $(@querySelectorAll css).take(limit) )
					)
					# Flatten all the nodelists into a single set.
					.flatten()

			# Each node in _this_ contributes all children matching the
			# CSS expression to a new set.
			querySelectorAll: (expr) ->
				@filter("*")
				.reduce (a, i) ->
					a.extend i.querySelectorAll expr
				, $()

			# Collect a new set, full of clones of the DOM Nodes in the input set.
			clone: (deep=true) -> @map -> (@cloneNode deep) if $.is "node", @

			# Get a single DocumentFragment that contains all the nodes in _this_.
			toFragment: ->
				if @length > 1
					df = document.createDocumentFragment()
					# Convert every item in _this_ to a DOM node, and then append it to the Fragment.
					(@map toNode).map (node) -> df.appendChild(node)
					return df
				return toNode @[0]
		}
