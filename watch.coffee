#!/usr/bin/env coffee

[Bling,Fs,Path,Proc] = ['./dist/bling.js','fs','path','child_process'].map require

if process.argv.length < 4
	`return $.log("Usage: watch.coffee 'regex' 'shell command'")`

log = $.logger "[watch]"

log "Initializing..."

recurseDir = (path, cb) ->
	cb(path)
	Fs.readdir path, (err, files) ->
		$(files).filter(/^[^.]/).each (file) ->
			Fs.stat dir = Path.join(path, file), (err, stat) ->
				if stat?.isDirectory()
					recurseDir dir, cb

[pattern, command, args] = do ->
	pattern = null
	command = null
	args = []
	started = false
	for arg in process.argv
		if (not started) and /watch.coffee/.test arg
			started = true
		else if started
			if pattern is null
				pattern = arg.replace(/^\//,'').replace(/\/$/,'')
			else if command is null
				command = arg
			else
				args.push arg
	[ pattern, command, args ]
pattern = (try new RegExp pattern) or $.log 'bad pattern, using', /^[^.]/
log "Pattern:", pattern
log "Command:", command
log "Args:", args

launch = $.throttle 5000, $.trace 'launch', ->
	log "Spawning:", command, args
	Proc.spawn(command, args, stdio: 'inherit')

recurseDir '.', (dir) ->
	Fs.watch dir, (op, file) ->
		if pattern.test(file) then launch()
log "Listening for changes..."
