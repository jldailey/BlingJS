
$.plugin
	depends: "request-queue"
	provides: "chat-bot"
, ->
	class ChatBot
		request_queue = new $.RequestQueue().start(3,1017)
		sender_aliases = Object.create null
		channels = Object.create null
		channelRegister: (name, url) ->
			channels[name] = url
		channelJoin: (name) ->
			@url = channels[name] ? name
		senderAlias: (hostname, alias) ->
			sender_aliases[hostname] = alias
		say: (text) ->
			request_queue.post {
				@url,
				body: JSON.stringify { @from, text }
			}
	class LechatBot extends ChatBot
		channelRegister: (name, id) ->
			super name, "https://api.lechat.im/rooms/#{id}/simple"
		constructor: ->
			@channelRegister "Conductrics", "84d270af17f95e6f2026b17ec6159e84d3ea4c554b61fb932f88bb9c488b8fa"
			@channelRegister "Integration Test", "b77929a98c7c2a94467aba838969abdad547e186c38ab8b2bb40203981cb53ab"
			@senderAlias "JAIR.local", "Jesse's MacBook"
			@senderAlias "ip-10-194-102-16", "dev-api.conductrics.com"
			@senderAlias "ip-10-116-99-23", "api.conductrics.com"
			@channelJoin "Integration Test"
	
	return { $: { ChatBot, LechatBot }}

