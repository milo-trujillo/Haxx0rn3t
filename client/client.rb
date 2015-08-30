#!/usr/bin/env ruby

require 'readline'
require_relative 'network'
require_relative 'config'

$hosts = Hash.new

Commands = ["dial", "resume", "help", "quit"]

def handleInput(input)
	case input
		when /^dial .+/
			dial, dest = input.split(" ")
			if( $hosts.has_key?(dest) )
				connect($hosts[dest][0], $hosts[dest][1])
			else
				puts "Hostname not known."
			end
		when /^dial$/
			puts "USAGE: dial <hostname>"
		when /^resume$/
			resumeConnection
		when /^help$/
			puts "Available commands:"
			for c in Commands.sort
				puts "\t" + c
			end
		when /^quit$/
			exit(0)
		else
			if( DebugMode && input.length > 0 )
				puts "Unknown command: " + input
			end
	end
end

if __FILE__ == $0
	puts "=== Client Started ==="
	puts "Welcome to " + GameName + "!"
	readConfig($hosts)
	if( $hosts.length == 1 )
		puts "If this is your first time playing, type 'dial central'"
	end
	while( input = Readline.readline(Prompt, true) )
		if( input == nil ) # Allow ^D to end the game
			puts "" # Clear the line in case the terminal printed a '^D'
			exit(0)
		end
		Readline::HISTORY.pop if /^\s*$/ =~ input # Don't add blank history
		input = input.chomp
		handleInput(input)
	end
end
