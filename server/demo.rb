#!/usr/bin/env ruby

require_relative 'user'
require_relative 'shiny'
require_relative 'announce'

demouser = User.new($stdout, 80, 24)
puts "Demoing matrix"
matrix(3, 50, demouser)
puts "Demoing establishing connections"
establishingConnection(5, "Massive Dynamic", demouser)

puts "Demoing site art"
banner("../sites/arl", demouser)
puts ""
puts ""
puts ""
banner("../sites/yoyodyne", demouser)
puts ""
puts ""
puts ""
banner("../sites/md", demouser)
puts ""
puts ""
puts ""
banner("../sites/veridian", demouser)
puts ""
puts ""
puts ""
banner("../sites/uber-braun", demouser)
puts ""
puts ""
puts ""
banner("../sites/minacon", demouser)
