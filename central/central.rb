#!/usr/bin/env ruby

require 'socket'
require 'thread'

require_relative 'user'
require_relative 'config'
require_relative 'currency'
require_relative 'log'
require_relative '../util/client'
require_relative '../util/menu'

module Central
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
			Log.log(Log::Debug, "Client disconnected during login process")
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
			if( client != nil && client.name != nil && client.name.length > 0 )
				Log.log(Log::Debug, "'" + client.name + "' exited uncleanly")
			else
				Log.log(Log::Debug, "Unauthorized user exited uncleanly")
			end
		end
	end

	def Central.alert()
		Log.log(Log::Debug, "Alert called!")
	end

	def Central.saveState()
		saveUsersToFile(Configuration::UserPath, $users, $userLock)
		Currency.saveManifest(Configuration::CurrencyPath)
	end

	def Central.loadState()
		readUsersFromFile(Configuration::UserPath, $users, $userLock)
		Currency.loadManifest(Configuration::CurrencyPath)
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
	Configuration.prepareState
	puts("") # My terminal prints '^C', so I'd like to throw in a newline
	Log.log(Log::Info, "Saving state information to disk...")
	Central.saveState
	Log.log(Log::Info, "Quitting...")
	exit(0)
end

if $0 == __FILE__
	if( Configuration.stateExists )
		Central.loadState
		Configuration.clearState
	end
	server = TCPServer.open(Configuration::ListenPort)
	while(true)
		case SIGNAL_QUEUE.pop
		when :INT
			handleInt
		else
			begin
				client = server.accept_nonblock
				Thread.start do
					Log.log(Log::Debug, "Client connected")
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
