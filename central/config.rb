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

	# For looping over all config files
	StateFiles = [UserPath, CurrencyPath]

	# Later we may add variables for max users, max connections,
	# reserved usernames, locations for log files, etc

	# Makes the state directory if it doesn't already exist
	def Configuration.prepareState
		unless( File.directory?(StateDir) )
			begin
				Dir.mkdir(StateDir)
			rescue
				puts "Error making state directory!"
				return false
			end	
			return true
		end
		return true
	end

	# Returns true if all state files exist, false otherwise.
	# We do not support restoring from partial state.
	def Configuration.stateExists
		for f in StateFiles
			unless( File.exists?(f) )
				return false
			end
		end
		return true
	end

	# Deletes all files storing program state
	def Configuration.clearState
		for f in StateFiles
			if( File.exists?(f) )
				begin
					File.delete(f)
				rescue
					puts "Warning: Unable to delete file '" + f + "'!"
				end
			end
		end
	end
end
