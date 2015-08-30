#!/usr/bin/env ruby

=begin
	This file defines how messages should be logged. At present it's just a
	wrapper around 'puts', but later when the central server daemonizes we'll
	have to port this to use files or syslog.

	Note: DebugMode *MUST* be declared here if the logging system is going
	to be used by both central and node servers!
=end

module Log
	$debugMode = true

	# Define some constants for log messages
	# All messages must come with a log level to be printed
	Debug   = 1
	Info    = 2
	Warning = 3
	Error   = 4

	def Log.log(level, msg)
		case level
			when Debug
				if( $debugMode == true )
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

	def Log.setDebugMode(bool)
		# Sometimes ruby's typing system is a bit silly
		if( bool == true )
			$debugMode = true
		elsif( bool == false )
			$debugMode = false
		end
	end
end	
