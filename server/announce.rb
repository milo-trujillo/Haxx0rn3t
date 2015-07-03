#!/usr/bin/env ruby

require_relative 'user'

def banner(fname, user)
	cols = user.cols
	max_width = 0
	File.open(fname, "r") do |f|
		f.each_line do |line|
			l = line.chomp.length
			if( l > max_width )
				max_width = l
			end
		end

		space = (cols - max_width) / 2
		if( space < 0 )
			user.out.puts "ERROR: Screen not wide enough for banner!"
			return
		end

		f.rewind

		f.each_line do |line|
			user.out.puts((" " * space) + line.chomp)
		end
	end
end
