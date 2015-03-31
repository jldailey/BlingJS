
dom = require('jldom')
dom.registerGlobals(global)
global.document = dom.createDocument()
global.window = global
window.innerWidth = 1234
window.innerHeight = 321
# set up a test document, to run DOM tests against
document.body.innerHTML = """
	<table>
		<tr><td>1,1</td><td>1,2</td></tr>
		<tr><td>2,1</td><td>2,2</td></tr>
		<tr><td>3,1</td><td class='d'>3,2</td></tr>
		<tr><td>4,1</td><td>4,2</td></tr>
	</table>
	<div class='c'>C</div>
	<p><span>foobar</span></p>
	<div id='empty'></div>
"""


module.exports = [
	'../dist/bling.js',
	'assert'
].map require
