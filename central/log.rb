#!/usr/bin/env ruby

=begin
	This file defines how messages should be logged. At present it's just a
	wrapper around 'puts', but later when the central server daemonizes we'll
	have to port this to use files or syslog.
=end

require_relative 'config'

module Log
	# Define some constants for log messages
	# All messages must come with a log level to be printed
	Debug   = 1
	Info    = 2
	Warning = 3
	Error   = 4

	def Log.log(level, msg)
		case level
			when Debug
				if( Configuration::DebugMode == true )
					puts "Debug: " + msg
				end
			when Info
				puts "Info: " + msg
			when Warning
				puts "WARNING: " + msg
			when Error
				puts "ERROR: " + msg
			else
				Log.log(Warning, "Malformed log message has improper log level")
		end
	end
end	
