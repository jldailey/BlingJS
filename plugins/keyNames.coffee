$.plugin
	provides: 'keyName,keyNames'
	depends: "math"
, ->
	keyCode =
		"Backspace": 8
		"BS": 8
		"Tab": 9
		'\t': 9
		"Enter": 13
		'\n': 12
		"Shift": 16
		"Ctrl": 17
		"Alt": 18
		"Pause": 19
		"Break": 19
		"Caps": 20
		"Caps Lock": 20
		"Esc": 27
		"Escape": 27
		"Space": 32
		" ": 32
		"PgUp": 33
		"Page Up": 33
		"PgDn": 34
		"End": 35
		"Home": 36
		"Left": 37
		"Up": 38
		"Right": 39
		"Down": 40
		"Insert": 45
		"Del": 46
		"Delete": 46
		"Times": 106
		"*": 106
		"Plus": 107
		"+": 107
		"Minus": 109
		"-": 109
		"Div": 111
		"Divide": 111
		"/": 111
		"Semi-Colon": 186
		";": 187
		"Equal": 187
		"=": 187
		"Comma": 188
		",": 188
		"Dash": 189
		"-": 189
		"Dot": 190
		"Period": 190
		".": 190
		"Forward Slash": 191
		"/": 191
		"Back Slash": 220
		"\\": 220
		"Single Quote": 222
		"'": 222

	# The main body of the keyboard (overlaps with ASCII)
	for a in "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		keyCode[a] = keyCode[a.toLowerCase()] = a.charCodeAt(0)

	# The F-keys
	for a in $.range(1,13)
		keyCode["F"+a] = keyCode["f"+a] = 111 + a

	keyName = {}
	for name, code of keyCode
		keyName[code] or= name
	
	return $:
		keyCode: (name) -> keyCode[name] ? name
		keyName: (code) -> keyName[code] ? code

