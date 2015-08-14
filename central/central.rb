#!/usr/bin/env ruby

require 'socket'
require 'thread'

require_relative 'user'
require_relative 'currency'
require_relative '../util/client'
require_relative '../util/menu'

Thread.abort_on_exception = true

module Central
	ListenPort = 1234

	$users = Hash.new
	$userLock = Mutex.new

	def Central.loginClient(client)
		loggedIn = login(client, $users, $userLock)
		if( loggedIn )
			client.puts("Login successful.")
			return true
		else
			client.puts("Login failed.")
			client.out.close
			return false
		end
	end

	def Central.handleClient(sock)
		begin
			col = sock.gets.chomp.to_i
			row = sock.gets.chomp.to_i
			if( col == 0 || row == 0 )
				sock.puts("Syntax error connecting, are you using the client?")
				sock.close
				return
			end
			client = Client.new(sock, sock, col, row, "")
			unless loginClient(client)
				return
			end
		rescue
			puts "Client disconnected during login process"
		end
		m = Menu.new("Central Server", 
			[["BBS", proc{ alert }],
			["Messages", proc{ alert }],
			["Logout", proc{ alert }]])
		begin
			while(true)
				m.print(client)
				m.prompt(client)
			end
		rescue
			puts "'" + client.name + "' exited uncleanly"
		end
	end

	def Central.alert()
		puts "Alert called!"
	end

	def Central.saveState()
		saveUsersToFile("userdump.txt", $users, $userLock)
		Currency.saveManifest("currencydump.db")
	end
end

=begin
	This is the main for the central server. We start by registering a handler
	for saving our state, then kick off TCP and start handling incoming clients.
=end

# This is a hack for handling repeated signals, as described here:
# http://www.sitepoint.com/the-self-pipe-trick-explained/
SIGNAL_QUEUE = []
[:INT, :QUIT, :TERM].each do |signal|
	Signal.trap(signal) do
		SIGNAL_QUEUE << signal
	end
end

def handleInt
	puts("") # My terminal prints '^C', so I'd like to throw in a newline
	puts "Saving state information to disk..."
	Central.saveState
	puts "Quitting..."
	exit(0)
end

if $0 == __FILE__
	server = TCPServer.open(Central::ListenPort)
	while(true)
		case SIGNAL_QUEUE.pop
		when :INT
			handleInt
		else
			begin
				client = server.accept_nonblock
				Thread.start do
					puts "Client connected"
					Central.handleClient(client)
				end
			rescue
				# Accept_nonblock throws an exception if we didn't get a socket
				# to accept. All we need to do in that case is pause and try
				# again.
				sleep(1)
			end
		end
	end
end
