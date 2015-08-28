#!/usr/bin/env ruby

=begin
	This class is for tracking all central server information about a user.
	This mainly includes each user's handle, an ID associated with them (so
	lookups can be done without revealing the handle), and the capabilities
	the user has.
=end

require 'base64'
require 'digest/sha2'

require_relative 'config'
require_relative 'log'

# We aren't expecting hard cryptographic security, but this way people
# can't Google the ID strings and trivially get the real handles.
UserIDSalt = "w4ULxGgA5smsTT1h"
UserPassSalt = "2@nNW)$12+FQs\Si"

class User
	attr_reader :handle
	attr_reader :ID

	def initialize(handle, password, restoreFromFile)
		if( handle.class != String )
			raise TypeError, "Handle must be a string!"
		end
		if( password.class != String )
			raise TypeError, "Password must be a string!"
		end
		if( restoreFromFile != true && restoreFromFile != false )
			raise TypeError, "restoreFromFile must be a bool!"
		end
		if( restoreFromFile == false )
			@handle = handle
			@password = (Digest::SHA2.new << (password + UserPassSalt)).to_s
		else
			@handle = Base64.strict_decode64(handle)
			@password = Base64.strict_decode64(password)
		end
		@ID = (Digest::SHA2.new << (handle + UserIDSalt)).to_s
	end

	# Note: Not cryptographically secure, this is vulnerable to timing attacks
	# and uses no cryptography for password storage. Don't really care for a
	# tiny game.
	def isCorrectPassword?(password)
		if( @password == (Digest::SHA2.new << (password + UserPassSalt)).to_s )
			return true
		else
			return false
		end
	end

	# Update account password, returns success / failure
	def updatePassword(oldpass, newpass)
		if( isCorrectPassword?(oldpass) )
			if( newpass.class != String )
				raise TypeError, "Password must be a string!"
			end
			@password = (Digest::SHA2.new << (newpass + UserPassSalt)).to_s
			return true
		else
			return false
		end
	end

	def writeToString()
		handleEncoded = Base64.strict_encode64(@handle)
		passEncoded = Base64.strict_encode64(@password)
		return (handleEncoded + ":" + passEncoded)
	end
end

def testAccountSystem
	u = User.new("neo", "ch0zen 0n3", false)
	Log.log(Log::Debug, "User #{u.handle} has id #{u.ID}")
end

# Reverses the user.writeToString() method, for restoring from disk
def createUserFromString(str)
	handle = str.match(/(.*):.*/)
	pass = str.match(/.*:(.*)/)
	return User.new(handle, pass, true)
end

# This writes every user as a string to a file, hopefully allowing restoration
# at a later time.
def saveUsersToFile(filename, users, userlock)
	success = true
	userlock.synchronize {
		begin
			f = File.open(filename, "w")
			for u in users.keys
				Log.log(Log::Info, "Saving user '" + u + "'")
				f.puts(users[u].writeToString)
			end
		rescue => e
			Log.log(Log::Error, "Problem saving users to file!")
			Log.log(Log::Error, e.message)
			Log.log(Log::Error, e.backtrace)
			success = false
		ensure
			f.close
		end
	}
	return success
end

# This reads state data from a file and attempts to convert it back into user
# accounts in our hash table.
def readUsersFromFile(filename, users, userlock)
	begin
		f = File.open(filename, "r")
		userlock.synchronize {
			while( line = f.gets )
				line = line.chomp
				username, password = line.split(":")
				user = User.new(username, password, true)
				users[user.handle] = user
			end
		}
	rescue => e
		Log.log(Log::Error, "Problem reading users from file!")
		Log.log(Log::Error, e.message)
		Log.log(Log::Error, e.backtrace)
		return false
	ensure
		f.close
	end
	return true
end

def login(client, users, userlock)
	Log.log(Log::Debug, "Starting login process")
	# Get a username and password out of them first
	client.putsNow("Username: ")
	username = client.gets.chomp
	client.putsNow("Password: ")
	password = client.gets.chomp

	if( username.length > Configuration::MaxUsernameLength )
		max = "Username exceeds maximum length "
		max += "(" + Configuration::MaxUsernameLength.to_s + ")"
		client.puts(max)
		return false
	end

	# First determine if the account exists, or if we should start
	# registration
	userExists = false
	userlock.synchronize {
		if( users[username] != nil )
			userExists = true
		end
	}

	# If the user does exist then we just need to check if the password is
	# correct and return that.
	if( userExists )
		correctPassword = false
		userlock.synchronize {
			if( users[username] != nil )
				if( users[username].isCorrectPassword?(password) )
					client.name = username
					Log.log(Log::Info, "Logged in '" + username + "'")
					correctPassword = true
				end
			end
		}
		return correctPassword
	# If the user does not exist then we need to ask the user if they want
	# to register. Only if they want to register and the username is still
	# available can the account be created and the user auto-logged in.
	else
		register = registerUser(client, users)
		if( register == true )
			success = false
			userlock.synchronize {
				if( users[username] == nil )
					users[username] = User.new(username, password, false)
					success = true
				end
			}
			if( success )
				client.name = username
				client.puts("Successfully registered user.")
				Log.log(Log::Info, "Registered user '" + username + "'")
				return true
			else
				client.puts("Failed to register user (already exists).")
				return false
			end
		else
			return false
		end
	end
end

# Returns true/false of whether the user would like to register a new account
def registerUser(client, userlist)
	done = false
	while( !done )
		client.putsNow("User does not exist. Register? [Y/N]: ")
		response = client.gets.chomp.upcase
		if( response == "N" )
			return false
		elsif( response == "Y" )
			return true
		end
	end
end
