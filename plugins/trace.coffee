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
		object:  { trace: (label, o, tracer) -> (o[k] = $.trace(o[k], "#{label}.#{k}", tracer) for k in Object.keys(o)); o }
		array:   { trace: (label, o, tracer) -> (o[i] = $.trace(o[i], "#{label}[#{i}]", tracer) for i in [0...o.length] by 1); o }
		function:
			trace: (label, f, tracer) ->
				label or= f.name
				r = (a...) ->
					start = +new Date
					f.apply @, a
					tracer "#{@name or $.type(@)}.#{label}(#{$(a).map($.toRepr).join ','}): #{(+new Date - start).toFixed 0}ms"
				# tracer "Trace: #{label} created."
				r.toString = -> "{Trace '#{label}' of #{f.toString()}"
				r

	time = (label, f, logger) ->
		unless $.is "string", label
			[f, logger, label] = [label, f, "trace"]
		unless $.is "function", logger
			logger = $.log
		start = +new Date
		do f
		logger "[#{label}] #{(+new Date - start).toFixed 0}ms"
		
	return $:
		time: time
		trace: (label, o, tracer) ->
			unless $.is "string", label
				[tracer, o] = [o, label]
			tracer or= $.log
			label or= ""
			$.type.lookup(o).trace(label, o, tracer)
