#!/usr/bin/env coffee

[ Bling, Fs, Path, Proc, Optimist ] = [
	'./dist/bling.js','fs',
	'path','child_process',
	'optimist'
].map require

$.log opts = Optimist.options('t', {
		alias: 'throttle'
		default: 7
		describe: "Seconds to wait between restart attempts."
	})
	.options('r', {
		alias: 'restart-code'
		default: 1
		describe: "Process exit code to request a restart [0-255]."
	})
	.options('i', {
		alias: 'immediate'
		default: false
		describe: "Execute 'command [args...]' immediately."
	})
	.boolean('i')
	.demand(2)
	.usage("Usage: $0 [options...] 'pattern' command [args...]")
	.argv

log = $.logger "[watch]"

log "Initializing..."

recurseDir = (path, cb) ->
	cb(path)
	Fs.readdir path, (err, files) ->
		$(files).filter(/^[^.]/).each (file) ->
			Fs.stat dir = Path.join(path, file), (err, stat) ->
				if stat?.isDirectory()
					recurseDir dir, cb
pattern = opts._[0]
command = opts._[1]
args = opts._[2..]

pattern = (try new RegExp pattern) or $.log 'bad pattern, using', /^[^.]/
log "Pattern:", pattern
log "Command:", command
log "Args:", args

launch = $.throttle +opts.throttle * 1000, $.trace 'launch', ->
	log "Spawning:", command, args
	p = Proc.spawn(command, args, stdio: 'inherit')
	p.on 'close', (code) ->
		if code is +opts.r
			log "Respawning..."
			$.immediate launch

if opts.immediate then $.immediate launch

recurseDir '.', (dir) ->
	Fs.watch dir, (op, file) ->
		if pattern.test(file) then launch()
log "Listening for changes..."
