require 'eventmachine'
require 'em-websocket'

# Load in Rails
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

EventMachine.run {

	EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
		
		# Load in websockets
		Dir.glob(File.expand_path(File.join(File.dirname(__FILE__), 'websocket')) + "/*.{rb}").each do |file|
			require file
		end

		ws.onopen {
		  puts "WebSocket connection open"

		  # publish message to the client
		  ws.send "Hello Client"
		}

		ws.onclose { puts "Connection closed" }
		ws.onmessage { |msg|
		  puts "Recieved message: #{msg}"
		  ws.send "Pong: #{msg}"
		}

	end

}