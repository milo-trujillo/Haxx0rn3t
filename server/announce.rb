#!/usr/bin/env ruby

require_relative 'util'

def banner(fname, dest)
	(lines, cols) = getScreenDimensions
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
			dest.puts "ERROR: Screen not wide enough for banner!"
			exit
		end

		f.rewind

		f.each_line do |line|
			dest.puts (" " * space) + line.chomp
		end
	end
end

banner("sites/arl", $stdout)
puts ""
puts ""
puts ""
banner("sites/yoyodyne", $stdout)
puts ""
puts ""
puts ""
banner("sites/md", $stdout)
puts ""
puts ""
puts ""
banner("sites/veridian", $stdout)
puts ""
puts ""
puts ""
banner("sites/uber-braun", $stdout)
puts ""
puts ""
puts ""
banner("sites/minacon", $stdout)
