#!/usr/bin/env ruby

require 'socket'
require 'thread'

require_relative 'user'
require_relative 'config'
require_relative 'currency'
require_relative 'bbs'
require_relative '../util/client'
require_relative '../util/log'
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
			[["BBS", proc{ BBS.menu(client) }],
			["Messages", proc{ alert }],
			["Logout", proc{ client.logout }]])
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

	def Central.initializeState()
		BBS.testFill(20) # Hack to test the BBS system
	end

	def Central.saveState()
		Log.log(Log::Info, "Saving state information to disk...")
		begin
			saveUsersToFile(Configuration::UserPath, $users, $userLock)
			Currency.saveManifest(Configuration::CurrencyPath)
			BBS.saveBoard(Configuration::BBSPath)
		rescue => e
			Log.log(Log::Error, "Problem saving state!")
			Log.log(Log::Error, e.message)
			Log.log(Log::Error, e.backtrace)
			exit(1) # Don't try to continue if we'll fry the state
		end
		Log.log(Log::Info, "Done saving state.")
	end

	def Central.loadState()
		Log.log(Log::Info, "Loading state from disk...")
		begin
			readUsersFromFile(Configuration::UserPath, $users, $userLock)
			Currency.loadManifest(Configuration::CurrencyPath)
			BBS.loadBoard(Configuration::BBSPath)
		rescue => e
			Log.log(Log::Error, "Problem loading state!")
			Log.log(Log::Error, e.message)
			Log.log(Log::Error, e.backtrace)
			exit(1) # Don't try to continue if we'll fry the state
		end
		Log.log(Log::Info, "Done loading state.")
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
	Central.saveState
	Log.log(Log::Info, "Quitting...")
	exit(0)
end

if $0 == __FILE__
	Log.log(Log::Info, "Starting up...")
	if( Configuration.stateExists )
		Central.loadState
		Configuration.clearState
	else
		Central.initializeState
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
