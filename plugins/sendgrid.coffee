$.plugin
	provides: "sendgrid"
	depends: "config"
, ->
	try
		nodemailer = require 'nodemailer'
	catch err
		`return`
	transport = null
	openTransport = ->
		transport or= nodemailer.createTransport 'SMTP',
			service: 'SendGrid'
			auth:
				user: $.config.get 'SENDGRID_USERNAME'
				pass: $.config.get 'SENDGRID_PASSWORD' # this should be set manually by 'heroku config:add SENDGRID_PASSWORD=xyz123'
	closeTransport = ->
		transport?.close()
		transport = null

	$:
		sendMail: (mail, callback) ->
			# mail is expected to be an object with (at least) .to, .subject, .text
			# let's fill out other needed stuff needed for sending here
			mail.transport ?= openTransport()
			mail.from ?= $.config.get 'EMAILS_FROM'
			mail.bcc ?= $.config.get 'EMAILS_BCC'

			if $.config.get('SENDGRID_ENABLED', 'true') is 'true'
				nodemailer.sendMail mail, (err) ->
					if mail.close
						closeTransport()
					callback(err)
			else
				if mail.close
					closeTransport()
				callback(false) # Reply as if an email was sent
