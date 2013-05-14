#!/usr/bin/env coffee

[Bling,Fs,Path,Proc] = ['./dist/bling.js','fs','path','child_process'].map require

if process.argv.length < 4
	`return $.log("Usage: watch.coffee 'regex' 'shell command'")`

console.log "Initializing..."
execCount = 0
exec = $.throttle 3000, $.trace 'exec', (file, cmd) ->
	execCount += 1
	p = Proc.exec cmd, (err, stdout, stderr) ->
		if err then throw "Proc.exec error: #{err}"
	if execCount > 0 or process.platform isnt 'darwin'
		p.stdout.on 'data', (data) -> console.log data.replace(/[\r\n]+$/,'')
		p.stderr.on 'data', (data) -> console.error data.replace(/[\r\n]+$/,'')
	return p


recurseDir = (path, cb) ->
	cb(path)
	Fs.readdir path, (err, files) ->
		$(files).filter(/^[^.]/).each (file) ->
			Fs.stat dir = Path.join(path, file), (err, stat) ->
				if stat?.isDirectory()
					recurseDir dir, cb

[pattern, command] = $(process.argv).last(2)
console.log "Listening for changes..."

pattern = (try new RegExp pattern) or $.log 'bad pattern, using', /^[^.]/

recurseDir '.', (dir) ->
	Fs.watch dir, (op, file) ->
		console.log op, file
		pattern.test(file) and exec file, command
