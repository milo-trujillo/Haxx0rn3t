#!/usr/bin/env ruby

require_relative 'network'

if __FILE__ == $0
	puts "=== Client Started ==="
	connect("localhost", 1234)
end
