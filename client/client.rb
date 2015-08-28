#!/usr/bin/env ruby

require_relative 'network'
require_relative 'config'

$hosts = Hash.new

def handleInput(input)
	case input
		when /^dial .+/
			dial, dest = input.split(" ")
			if( $hosts.has_key?(dest) )
				connect($hosts[dest][0], $hosts[dest][1])
			else
				puts "Hostname not known."
			end
		when /^resume$/
			resumeConnection
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
	while( true )
		print Prompt
		input = gets
		if( input == nil ) # Allow ^D to end the game
			puts "" # Clear the line in case the terminal printed a '^D'
			exit(0)
		end
		input = input.chomp
		handleInput(input)
	end
end
