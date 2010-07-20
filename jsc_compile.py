#!/usr/bin/env python3.1
import sys
from http.client import HTTPConnection
from urllib.parse import urlencode


infile = sys.argv[1]
outfile = sys.argv[2]

with open(infile, 'r') as i:
	data = i.read()
	params = urlencode([
		# ('compilation_level', 'WHITESPACE_ONLY'),
		('compilation_level', 'SIMPLE_OPTIMIZATIONS'), # only changes local names
		# ('compilation_level', 'ADANCED_OPTIMIZATIONS'), # changes names of everything
		('output_info', 'compiled_code'),
		('output_format', 'text'),
		('js_code', data),
	])
	headers = {'Content-type': 'application/x-www-form-urlencoded'}
	conn = HTTPConnection('closure-compiler.appspot.com')
	conn.request('POST', '/compile', params, headers)
	resp = conn.getresponse()
	print("Status: %d" % resp.status)
	print(resp.getheaders())
	data = resp.read()
	with open(outfile, "wb") as o:
		o.write(data)
	conn.close()


