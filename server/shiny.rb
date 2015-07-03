#!/usr/bin/env ruby

require_relative 'user'

def getRandomSymbol
	return (32 + rand(94)).chr
end

def matrix(duration, width, user)
	cols = user.cols
	space = (cols - width) / 2
	for x in (1 .. 100)
		string = ""
		for y in (1 .. width)
			if( rand(100) % 3 != 0 )
				string += getRandomSymbol
			else
				string += " "
			end
		end
		user.out.puts (" " * space) + string
		sleep(0.3)
	end
end

def establishingConnection(duration, destination, user)
	printState = user.out.sync
	user.out.sync = true
	for i in (1 .. ((duration / 3) * 10))
		user.out.print "      Connecting to " + destination + "      "
		sleep(0.2)
		user.out.print "\r"
		user.out.print ".     Connecting to " + destination + "   .  "
		sleep(0.2)
		user.out.print "\r"
		user.out.print "..    Connecting to " + destination + "   .. "
		sleep(0.2)
		user.out.print "\r"
		user.out.print "...   Connecting to " + destination + "   ..."
		sleep(0.2)
		user.out.print "\r"
	end
	user.out.print "\r=== Uplink established to " + destination + " ===\n"
	user.out.sync = printState
end

