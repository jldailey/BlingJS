#!/usr/bin/env coffee

[ Bling, Fs, Path, Proc, Extra, Optimist ] = [
	'./dist/bling.js','fs',
	'path','child_process',
	'extra', 'optimist'
].map require

opts = Optimist.options('t', {
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
	.options('x', {
		alias: 'exclude'
		default: 'node_modules'
		describe: "Pattern for directories to avoid watching"
	})
	.demand(1)
	.usage("Usage: $0 [options...] -- 'pattern' -- [ENV=val] command [args...]")
	.argv

log = $.logger "[watch]"

log "Options:"
log " Run immediately: #{opts.immediate}"
log " Restart throttle: #{opts.throttle} sec"
log " Exclude pattern: /#{opts.exclude}/"
log " Restart exit code: #{opts.r}"

log "Initializing..."

if opts.x
	exc_re = new RegExp(opts.x)
exclude = (dir) ->
	opts.x and exc_re.test dir

pattern = opts._[0]

pattern = (try new RegExp pattern) or $.log 'bad pattern, using', /^[^.]/

launch = $.throttle +opts.throttle * 1000, $.trace 'launch', ->
	p = Extra.spawn( stdio: 'inherit' )
	p.on 'close', (code) ->
		log "Exit Code:", code
		if code is +opts.r
			log "Respawning..."
			$.immediate launch

if opts.immediate then $.immediate launch

recurseDir = (path, cb) ->
	cb(path)
	Fs.readdir path, (err, files) ->
		$(files).filter(/^[^.]/).each (file) ->
			Fs.stat dir = Path.join(path, file), (err, stat) ->
				if stat?.isDirectory() and not exclude(dir)
					recurseDir dir, cb
recurseDir '.', (dir) ->
	Fs.watch dir, (op, file) ->
		if pattern.test(file) then launch()
log "Listening for changes..."
