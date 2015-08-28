#!/usr/bin/env ruby

=begin
	This file contains all of the code that's run whenever we 'dial in' to a
	server. That means all the networking code and some inter-thread stuff.
=end

require 'socket'
require 'thread'
require_relative 'util'

$screenLock = Mutex.new
$conn = nil

class Connection
	def initialize(sock, lines, cols)
		@sock = sock
		@networkPrint = true
		@connOpen = true
		begin
			@sock.puts(cols.to_s)
			@sock.puts(lines.to_s)
			return true
		rescue
			puts "=== Network Handshake Failed ==="
			@connOpen = false
			return false
		end
	end

	# Attempt to open a new or restore an existing network connection
	# Returns true if it's possibly okay to restore the connection again
	# Returns false if the connection is definitely dead
	def start
		if( @connOpen )
			recv = Thread.new { readFromServer() }
			send = Thread.new { writeToServer() }
			send.join
			recv.kill
			if( @connOpen )
				return true
			else
				return false
			end
		else
			return false
		end
	end

	# Will close the network connection and clear all data
	# This renders the class safe to destroy
	def close
		begin
			@connOpen = false
			@sock.close
		rescue
		end
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
			@connOpen = false
		end
		puts "=== Server has closed connection ==="
	end

	def writeToServer()
		begin
			while( line = gets )
				if( line.chomp == "!suspend" )
					return
				elsif( line.chomp == "!quit" )
					puts "=== Terminated connection to remote host ==="
					close
					return
				else
					@sock.puts(line)
				end
			end
		rescue
			@connOpen = false
		end
	end
end

def connect(serveraddr, portno)
	state = STDOUT.sync
	STDOUT.sync = true
	if( $conn != nil )
		decision = nil
		while( decision == nil )
			print "You have an open network connection, override it? [Y/N] "
			choice = gets.chomp.upcase
			if( choice == "N" )
				return
			elsif( choice == "Y" )
				$conn.close
				$conn = nil
				break
			end
		end
	end
	(lines, cols) = getScreenDimensions
	sock = ""
	begin
		sock = TCPSocket.open(serveraddr, portno)
	rescue
		puts "=== Unable to connect ==="
		return
	end
	puts "=== Connected to Server ==="
	$conn = Connection.new(sock, lines, cols)
	$conn.start
	STDOUT.sync = state
end

def resumeConnection
	if( $conn != nil )
		if( ! $conn.start ) # If connection closes, nuke it
			$conn = nil
		end
	else
		puts "You have no network connection to resume!"
	end
end
