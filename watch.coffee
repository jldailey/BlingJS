#!/usr/bin/env coffee

[ $, Fs, Path, Extra, Optimist ] = [
	'./dist/bling.js','fs',
	'path', 'extra', 'optimist'
].map require

opts = Optimist.options('t', {
	alias: 'throttle'
	default: 7
	describe: "Seconds to wait between restart attempts."
})
.options('r', {
	alias: 'restart-code'
	default: 1
	describe: "Restart any watched process that exits with this exit code. [0-255]."
})
.options('i', {
	alias: 'immediate'
	default: false
	describe: "Spawn 'command [args...]' immediately."
})
.boolean('i')
.options('x', {
	alias: 'exclude'
	default: 'node_modules'
	describe: "Pattern for directories to avoid watching"
})
.options('v', {
	alias: 'verbose'
	default: false
	describe: 'Verbose output'
})
.boolean('v')
.demand(1)
.usage("Usage: $0 [options...] -- 'pattern' -- [ENV=val] command [args...]")
.argv

log = $.logger "[watch]"

log "Options:"
log " Run immediately: #{opts.immediate}"
log " Restart throttle: #{opts.throttle} sec"
log " Exclude pattern: /#{opts.exclude}/"
log " Restart on exit code: #{opts.r}"
log " Verbose: #{opts.v}"

if opts.x
	exc_re = new RegExp(opts.x)
exclude = (dir) ->
	opts.x and exc_re.test dir

pattern = opts._[0]

pattern = (try new RegExp pattern) or $.log 'bad pattern, using', /^[^.]/

process = null
force_restart = false

relaunch = (reason) ->
	if opts.v then log "Spawning (reason: #{reason})"
	if process?
		if opts.v then log "Killing..."
		force_restart = true
		process.kill()
	else do launch

on_exit = (code) ->
	log "Exit Code:", code
	process = null
	if code is +opts.r or force_restart
		force_restart = false
		if opts.v then log "Respawning..."
		$.immediate -> relaunch( if code is +opts.r then "respawn option -r" else "forced" )

launch = $.throttle +opts.throttle * 1000, ->
	process = Extra.spawn( stdio: 'inherit', stderr: 'inherit' )
	process.on 'close', on_exit

if opts.immediate then $.immediate -> launch "immediate option -i"

recurseDir = (path, cb) ->
	done = $.Progress(1)
	Fs.readdir path, (err, files) ->
		cb(path)
		$(files)
			# Set the maximum progress to the number of files we will stat
			.tap(-> done.progress 0, @length; @ )
			.each (file) ->
				Fs.stat dir = Path.join(path, file), (err, stat) ->
					if stat?.isDirectory() and not exclude(dir)
						# If we recurse, include it's progress as part of ours
						done.include recurseDir dir, cb
					# Mark this file as complete
					done.resolve(1)
	done

dirsWatched = 0
recurseDir('.', (dir) ->
	dirsWatched += 1
	if opts.verbose then log "Watching", dir, "(#{dirsWatched})"
	Fs.watch dir, (op, file) ->
		if pattern.test(file) then relaunch file
).wait (err) ->
	log "Watching #{dirsWatched} folders for changes."
	if err then log "Error:", err
