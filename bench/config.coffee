[ $, _, Fs ] = require './setup'

$.bench 'config.get (found)', -> $.config.get "PATH", "1234"
$.bench 'config.get (not found)', -> $.config.get "ASDLKJASLDJK", "1234"

