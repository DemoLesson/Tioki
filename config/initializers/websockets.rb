require 'em-websocket'

# Set up a websocket server in a thread
WS = Thread.new() do
	EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 7777) do |ws|
	  ws.onopen    { ws.send "Hello Client!"}
	  ws.onmessage { |msg| ws.send "Pong: #{msg}" }
	  ws.onclose   { puts "WebSocket closed" }
	end
end
