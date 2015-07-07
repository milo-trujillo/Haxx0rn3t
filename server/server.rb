#!/usr/bin/env ruby

require 'socket'
require 'thread'
require_relative 'user'
require_relative 'shiny'

Port = 1234

def sockManager( client )
	col = client.gets
	row = client.gets
	usr = User.new(client, col, row)
	establishingConnection(5, "SuitCorp", usr) 
	client.close
end

if __FILE__ == $0
	sock = TCPServer.open(Port)
	while(true)
		Thread.start(sock.accept) do |client|
			sockManager(client)
		end
	end
end
