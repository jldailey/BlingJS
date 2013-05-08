#!/usr/bin/env coffee

[Bling,Fs,Path,Proc] = ['./dist/bling.js','fs','path','child_process'].map require

if process.argv.length < 4
	`return $.log("Usage: watch.coffee 'regex' 'shell command'")`

console.log "Initializing..."
exec = $.throttle 3000, $.trace 'exec', (file, cmd) ->
	p = Proc.exec cmd, (err, stdout, stderr) ->
		if err then throw "Proc.exec error: #{err}"
	unless process.platform is 'darwin'
		p.stdout.on 'data', (data) -> $.log "[stdout]", data
		p.stderr.on 'data', (data) -> $.log "[stderr]", data
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
