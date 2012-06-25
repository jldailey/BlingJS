(($) ->

	# Trace Plugin
	# ------------
	# A very useful debugging tool, `$(o).trace() or $.trace(o)` will deep-walk all
	# properties and wrap all functions with new functions that call the
	# originals but log the calls (and use the property names from the
	# deep walk as labels).
	$.plugin
		provides: "trace"
		depends: "function,type"
	, ->
		# This is perhaps the cleanest use of the type system so far...
		$.type.extend
			unknown: { trace: $.identity }
			object:  { trace: (o, label, tracer) -> (o[k] = $.trace(o[k], "#{label}.#{k}", tracer) for k in Object.keys(o)); o }
			array:   { trace: (o, label, tracer) -> (o[i] = $.trace(o[i], "#{label}[#{i}]", tracer) for i in [0...o.length] by 1); o }
			function:
				trace: (f, label, tracer) ->
					r = (a...) ->
						tracer "#{@name or $.type(@)}.#{label or f.name}(", a, ")"
						f.apply @, a
					tracer "Trace: #{label or f.name} created."
					r.toString = f.toString
					r
		return $: trace: (o, label, tracer = $.log) -> $.type.lookup(o).trace(o, label, tracer)

)(Bling)
