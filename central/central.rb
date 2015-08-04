#!/usr/bin/env ruby

require 'socket'
require 'thread'

require_relative 'user'
require_relative 'currency'

Thread.abort_on_exception = true

ListenPort = 1234

$users = Hash.new
$userLock = Mutex.new

def handleClient(client)
	puts "Starting handle"
	loggedIn = login(client, $users, $userLock)
	if( loggedIn )
		client.puts("Login successful.")
	else
		client.puts("Login failed.")
	end
	client.close
end

if $0 == __FILE__
	server = TCPServer.open(ListenPort)
	while(true)
		Thread.start(server.accept) do |client|
			puts "Client connected"
			handleClient(client)
		end
	end
end
