#!/usr/bin/env ruby

=begin
	This file contains all of the code that's run whenever we 'dial in' to a
	server. That means all the networking code and some inter-thread stuff.
=end

require 'socket'
require 'thread'
require_relative 'util'

$screenLock = Mutex.new

class Connection
	def initialize(sock, lines, cols)
		@sock = sock
		@networkPrint = true
		@sock.puts(cols.to_s)
		@sock.puts(lines.to_s)
		recv = Thread.new { readFromServer() }
		send = Thread.new { writeToServer() }
		send.join
		recv.kill
	end

	# Stub function, but will later allow us to resume a connection if it's
	# been suspended to go run some local shell stuff.
	def resume
		return
	end

	def readFromServer()
		begin
			while( char = @sock.recv(1) )
				break if char.empty?
				# This is probably really inefficient, but since it's the client
				# we don't particularly care.
				$screenLock.synchronize {
					if( @networkPrint )
						print char
					end
				}
			end
		rescue
		end
		puts "=== Server has closed connection ==="
	end

	def writeToServer()
		begin
			while( line = gets )
				if( line.chomp == "!quit" )
					return
				else
					@sock.puts(line)
				end
			end
		rescue
		end
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
	conn = Connection.new(sock, lines, cols)
	STDOUT.sync = state
end
