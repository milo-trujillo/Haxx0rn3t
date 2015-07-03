#!/usr/bin/env ruby

=begin
	This class provides an easy way of tracking information about a connected
	user and their terminal.
=end

class User
	attr_reader :out
	attr_reader :cols
	attr_reader :lines

	def initialize(out, cols, lines)
		@out = out
		@cols = cols
		@lines = lines
	end
end
