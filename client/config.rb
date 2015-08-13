#!/usr/bin/env ruby

=begin
	This file contains both hardcoded configuration for the client, and
	functions for reading from and writing to config files on the system.
=end

require 'thread' # Just so we can set thread config

ClientDir = ENV['HOME'] + "/.haxxornetdir"
Hosts = ClientDir + "/hosts"
Config = ClientDir + "/config"

DebugMode = true
Prompt = "Local Gateway# "
GameName = "HaxxorNet"
CentralServer = "central"
ConfigFiles = [Hosts, Config]

Thread.abort_on_exception = true

def readConfig(hosts)
	unless( File.directory?(ClientDir) )
		puts "Configuration directory does not exist, creating " + ClientDir
		Dir.mkdir(ClientDir)
		for file in ConfigFiles
			f = File.open(file, 'w')
			f.close
		end
	end
	hostFile = File.open(Hosts, 'r')
	while( line = hostFile.gets )
		shortname, hostname, port = line.split(':')
		if( shortname.length == 0 || hostname.length == 0 || port.length == 0 )
			puts "Error: '" + Hosts + "' is corrupted!"
			exit(1)
		end
		hosts[shortname] = [hostname, port]
	end
	hostFile.close
	unless( hosts.has_key?(CentralServer) )
		puts "You have no central server defined."
		puts "Please enter a central server address to play " + GameName + "."
		print "Hostname: "
		hostname = gets.chomp
		print "Port Number: "
		port = gets.chomp.to_i
		hosts[CentralServer] = [hostname, port]
	end
end
