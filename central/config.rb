#!/usr/bin/env ruby

=begin
	This file stores hardcoded configuration such as the paths to important
	files. It also provides utilities for creating necessary directories.
=end

Thread.abort_on_exception = true

# Would have named it 'config', but that appears to be reserved by ruby
module Configuration
	StateDir = "./state" # Later this might be /usr/games/lib/Haxx0rn3t
	UserPath = StateDir + "/users.db"
	CurrencyPath = StateDir + "/currency.db"
	ListenPort = 1234

	# Later we may add variables for max users, max connections,
	# reserved usernames, locations for log files, etc

	# Makes the state directory if it doesn't already exist
	def Configuration.prepareState
		unless( File.directory?(StateDir) )
			Dir.mkdir(StateDir)
		end
	end
end
