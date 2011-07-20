
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
	// replace tabs with spaces in <pre>'s
	// make all <pre>'s pretty-printable
	.ready(function () {
		var initial_tab = /(^|\n)\t/g,
			all_tabs = /\t/g
		$("pre").zipzapmap('innerHTML', function(html) {
			return Function.PrettyPrint($.HTML.escape(html)
				.replace(all_tabs, "  "));
		})
		// clean up textarea's also
		$("textarea").zipzapmap('value', function (value) {
			return value.replace(initial_tab,'$1').replace(all_tabs, "  ")
		})
	})
} catch ( err ) {
	alert("JavaScript error:" + err)
}
