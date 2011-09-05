require('./common')
require('../plugins/pprint')

testGroup("PrettyPrint",
	symbol: () -> ui.output $.prettyPrint("")
)

testReport()
