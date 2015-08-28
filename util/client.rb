#!/usr/bin/env ruby

=begin
	This class provides an easy way of tracking information about a connected
	user and their terminal. This is useful for tracking sockets needed for
	reading and writing, centering text on someone elses terminal, and so on.

	It also provides some utilities for writing to the user and writing without
	buffering (to allow partial lines like prompts to be sent).
=end

class Client
	attr_reader :in
	attr_reader :out
	attr_reader :cols
	attr_reader :width
	attr_reader :lines
	attr_reader :height
	attr_accessor :name

	def initialize(read, write, cols, lines, name)
		@in = read
		@out = write
		@cols = cols
		@width = cols
		@lines = lines
		@height = lines
		@name = name
	end

	# Shorthand for client.in.gets
	def gets
		return @in.gets
	end

	# Shorthand for client.out.puts
	def puts(msg)
		@out.puts(msg)
	end

	# Disable buffering, print, then re-enable it (if needed)
	def putsNow(msg)
		printState = @out.sync
		@out.sync = true
		@out.print(msg)
		@out.sync = printState
	end

	def clearScreen
		# We don't want to make the game unplayable for people with tall
		# terminals. To that end we're going to fib the screen delay and say
		# clearing the screen always takes four seconds.
		clearDelay = 4.0 / @height
		for x in (0 .. @height - 1)
			sleep(clearDelay)
			@out.puts("")
		end
		@out.puts("\033[0;0H")
	end
end
