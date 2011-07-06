
try
	$(document).ready () ->
		# find unsupported fraction markup
		# and insert fall-back text
		num_re = /&frac(\d)(\d);/
		initial_tab = /(^|\n)\t/g
		all_tabs = /\t/g
		$("p").each () ->
			p = $(this)
			text = p.text()[0]
			if num_re.test(text)
				p.text(text.replace(num_re, "$1/$2"))

		# replace tabs with spaces in <pre>'s
		# make all <pre>'s pretty-printable
		$("pre").each () ->
			this.innerHTML = Function.PrettyPrint($.HTML.escape(this.innerHTML.replace(initial_tab,'$1').replace(all_tabs,"  ")))
		# clean up textarea's also
		$("textarea").each () ->
			this.value = this.value
				.replace(initial_tab,'$1')
				.replace(all_tabs, "  ")
		# all documentation links are made active
		# collect the links
		a = $("a[href^='#doc:']")
		# modify their hrefs
		a.zap 'href', a.map () ->
			'html/doc.html#' + this.href.split(/#doc:/)[1]
catch err
	alert "JavaScript error: #{err}"

# vim: ft=coffee
