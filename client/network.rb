#!/usr/bin/env ruby

require 'socket'
require_relative 'util'

def connect(serveraddr, portno)
	state = STDOUT.sync
	STDOUT.sync = true
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
	begin
		while( char = sock.recv(1) )
			break if char.empty?
			print char
		end
	rescue
	end
	puts "=== Server has closed connection ==="
	STDOUT.sync = state
end


