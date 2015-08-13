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
end

if $0 == __FILE__
	server = TCPServer.open(Central::ListenPort)
	while(true)
		Thread.start(server.accept) do |client|
			puts "Client connected"
			Central.handleClient(client)
		end
	end
end
