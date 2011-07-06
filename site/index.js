
try {
	$(document)
	.ready(function () {
		// find unsupported fraction markup
		// and insert fall-back text
		var num_re = /&frac(\d)(\d);/
		$("p").each(function() {
			var p = $(this),
			text = p.text()[0]
			if( num_re.test(text) )
			p.text(text.replace(num_re, "$1/$2"))
		})
	})
	.ready(function () {
		var initial_tab = /(^|\n)\t/g,
			all_tabs = /\t/g

		// replace tabs with spaces in <pre>'s
		// make all <pre>'s pretty-printable
		$("pre").zipzapmap('innerHTML', function(html) {
			return Function.PrettyPrint($.HTML.escape(html)
				.replace(all_tabs, "  "));
		})
		// clean up textarea's also
		$("textarea").zipzapmap('value', function (value) {
			return value.replace(initial_tab,'$1').replace(all_tabs, "  ")
		})
		// all documentation links are made active
		var a = $("a[href^='#doc:']").zipzap('href', function(href) {
			return 'html/doc.html#' + href.split(/#doc:/)[1]
		})
	})
} catch ( err ) {
	alert("JavaScript error:" + err)
}
