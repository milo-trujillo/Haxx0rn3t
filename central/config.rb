#!/usr/bin/env ruby

=begin
	This file stores hardcoded configuration such as the paths to important
	files. It also provides utilities for creating necessary directories.
=end

require_relative '../util/log'

Thread.abort_on_exception = true

# Would have named it 'config', but that appears to be reserved by ruby
module Configuration
	# Paths
	StateDir = "./state" # Later this might be /usr/games/lib/Haxx0rn3t
	UserPath = StateDir + "/users.db"
	CurrencyPath = StateDir + "/currency.db"
	BBSPath = StateDir + "/bbs.db"
	StateFiles = [UserPath, CurrencyPath, BBSPath]

	# Strings, prompts, and other UI
	ContinuePrompt = "- Press Return -"

	# Networking
	# TODO: Add support for binding to specific interfaces? Max connections?
	ListenPort = 1234

	# BBS
	MaxPosts = 500

	# User configuration
	# Later we may add variables for max users,
	# reserved usernames, etc
	MaxUsernameLength = 20

	# Makes the state directory if it doesn't already exist
	def Configuration.prepareState
		unless( File.directory?(StateDir) )
			begin
				Dir.mkdir(StateDir)
			rescue
				Log.log(Log::Error, "Error making state directory!")
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
					Log.log(Log::Warning, 
						"Warning: Unable to delete file '" + f + "'!")
				end
			end
		end
	end
end
