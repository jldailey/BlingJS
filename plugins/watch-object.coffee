
$.plugin
	provides: "watchProperty"
	depends: "type"
, ->

	OP_CHANGE = 'change' # gets (key, value)
	OP_INSERT = 'insert' # gets (key, value)
	OP_DELETE = 'delete' # gets (key, length)

	#define MAKE_KEY(p, k) ((p?.length and p+'.'+k) or k)

	watchProperty = (obj, key, cb, prefix="") -> # call back everytime the value changes
		if typeof key is 'string' and (i = key.indexOf ".") > -1
			first = key.substr 0,i
			return watchProperty obj[first], (key.substr i+1), cb, MAKE_KEY(prefix, first)
		if $.is 'array', obj[key]
			return watchArray obj[key], cb, MAKE_KEY(prefix, key)
		prop = Object.getOwnPropertyDescriptor(obj, key)
		$.defineProperty obj, key,
			get: get = (prop.get ? -> prop.value)
			set: $.compose ($.partial cb, OP_CHANGE, MAKE_KEY(prefix, key)), \
				(prop.set or (prop.writable and (v) -> prop.value = v) or get)


	watchArray = (arr, cb, prefix="") ->
		pcb = (op, key, value) ->
			cb op, MAKE_KEY(prefix, key), value
		_watch = (method, _cb) ->
			supr = arr[method]
			arr[method] = (a...) ->
				try return supr.apply arr, a
				finally _cb.apply arr, a
		
		do rebindAll = ->
			for i in [0...arr.length] by 1
				watchProperty arr, i, pcb
		
		_watch 'push', (item) ->
			i = @length - 1
			watchProperty @, i, pcb
			pcb OP_INSERT, i, item
		_watch 'unshift', (item) ->
			rebindAll()
			pcb OP_INSERT, 0, item
		_watch 'pop', ->
			pcb OP_DELETE, @length, 1
		_watch 'shift', ->
			rebindAll()
			pcb OP_DELETE, 0, 1
		_watch 'splice', (i, n, v) ->
			if v isnt undefined
				i += 1
				n -= 1
			else if n > 0
				i = @length
			if n > 0
				pcb OP_DELETE, i, n

		arr

	return { $: { watchProperty } }

