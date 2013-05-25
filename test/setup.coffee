
dom = require('jldom')
dom.registerGlobals(global)
global.document = dom.createDocument()
global.window = global
window.innerWidth = 1234
window.innerHeight = 321

module.exports = [
	'../dist/min.bling.js',
	'assert'
].map require
