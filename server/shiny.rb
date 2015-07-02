#!/usr/bin/env ruby

require_relative 'util'

def getRandomSymbol
	return (32 + rand(94)).chr
end

def matrix(duration, width)
	(lines, cols) = getScreenDimensions
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
		puts (" " * space) + string
		sleep(0.3)
	end
end

def establishingConnection(duration, destination)
	printState = STDOUT.sync
	STDOUT.sync = true
	for i in (1 .. ((duration / 3) * 10))
		print "      Connecting to " + destination + "      "
		sleep(0.2)
		print "\r"
		print ".     Connecting to " + destination + "   .  "
		sleep(0.2)
		print "\r"
		print "..    Connecting to " + destination + "   .. "
		sleep(0.2)
		print "\r"
		print "...   Connecting to " + destination + "   ..."
		sleep(0.2)
		print "\r"
	end
	print "\r=== Uplink established to " + destination + " ===\n"
	STDOUT.sync = printState
end

matrix(3, 50)
#establishingConnection(5, "Massive Dynamic")
