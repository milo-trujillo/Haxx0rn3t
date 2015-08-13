#!/usr/bin/env ruby

require 'socket'
require 'thread'
require_relative 'util'

$screenLock = Mutex.new
NetworkPrint = true

def readFromServer(sock)
	begin
		while( char = sock.recv(1) )
			break if char.empty?
			# This is probably really inefficient, but since it's the client
			# we don't particularly care.
			$screenLock.synchronize {
				if( NetworkPrint )
					print char
				end
			}
		end
	rescue
	end
	puts "=== Server has closed connection ==="
end

def writeToServer(sock)
	begin
		while( line = gets )
			sock.puts(line)
		end
	rescue
	end
end

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
	recv = Thread.new { readFromServer(sock) }
	send = Thread.new { writeToServer(sock) }
	recv.join
	send.join
	STDOUT.sync = state
end
