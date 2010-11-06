#!/usr/bin/env python3.1
import sys
from http.client import HTTPConnection
from urllib.parse import urlencode


infile = sys.argv[1]
codefile = sys.argv[2]
errfile = infile + ".errors"
warnfile = infile + ".warnings"

with open(infile, 'r') as i:
	source = i.read()
	def once(output_info, output_file, data):
		print("Compiling %s to %s..." % (output_info, output_file))
		params = urlencode([
			# ('compilation_level', 'WHITESPACE_ONLY'),
			('compilation_level', 'SIMPLE_OPTIMIZATIONS'), # only changes local names
			# ('compilation_level', 'ADVANCED_OPTIMIZATIONS'), # changes names of everything
			('output_info', output_info),
			('output_format', 'text'),
			('js_code', data),
		])
		headers = {'Content-type': 'application/x-www-form-urlencoded'}
		conn = HTTPConnection('closure-compiler.appspot.com')
		conn.request('POST', '/compile', params, headers)
		resp = conn.getresponse()
		# print("Status: %d" % resp.status)
		# print(resp.getheaders())
		data = resp.read()
		with open(output_file, "wb") as o:
			o.write(data)
		conn.close()
		return data
	
	warns = once("warnings", warnfile, source)
	if warns:
		print("WARNINGS: see .warnings file")
		print(warns)

	errs = once("errors", errfile, source)
	if errs:
		print("ERRORS: see .errors file")
		print("%s" % errs)
		sys.exit(1)
	else:
		z = once("compiled_code", codefile, source)
		print("Compressed %d to %d bytes (%.2f%% of original)" % (len(source), len(z), 100*(1.0 - (len(z)/len(source)))))

