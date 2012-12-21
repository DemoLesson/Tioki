sse = (model, connect, message) ->
	$.eventsource
		label: 'json-event-source'
		url: '/cramp/' + model
		dataType: 'json'
		open: connect
		message: message

sse_connect = ->
	true

sse 'notifications', sse_connect, (data) ->
	for i, note of data

		string = """
		<li href="#{note.url}">
			#{note.message}
			<span>#{note.since}</span>
		</li>
		"""

		$(string).prependTo $('#notifications ul')
		$('a[href="#notifications"]').addClass 'unread'
