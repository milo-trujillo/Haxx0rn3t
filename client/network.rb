#!/usr/bin/env ruby

require 'socket'
require_relative 'util'

def connect(serveraddr, portno)
	(lines, cols) = getScreenDimensions
	sock = ""
	begin
		sock = TCPSocket.open(serveraddr, portno)
	rescue
		puts "=== Unable to connect ==="
		return
	end
	puts "=== Connected to Server ==="
	sock.puts(cols.to_s)
	sock.puts(lines.to_s)
	sock.puts("Hai server!")
	while( msg = sock.gets )
		puts msg
	end
	puts "=== Server has closed connection ==="
end


