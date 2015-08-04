#!/usr/bin/env ruby

=begin
	This class is for tracking all central server information about a user.
	This mainly includes each user's handle, an ID associated with them (so
	lookups can be done without revealing the handle), and the capabilities
	the user has.
=end

require 'digest/sha2'

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
	puts "User #{u.handle} has id #{u.ID}"
end

# Reverses the user.writeToString() method, for restoring from disk
def createUserFromString(str)
	handle = str.match(/(.*):.*/)
	pass = str.match(/.*:(.*)/)
	return User.new(handle, pass, true)
end

def login(sock, users, userlock)
	puts "Starting login process"
	# Get a username and password out of them first
	printState = sock.sync
	sock.sync = true
	sock.print("Username: ")
	username = sock.gets.chomp
	sock.print("Password: ")
	password = sock.gets.chomp
	sock.sync = printState

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
					correctPassword = true
				end
			end
		}
		return correctPassword
	# If the user does not exist then we need to ask the user if they want
	# to register. Only if they want to register and the username is still
	# available can the account be created and the user auto-logged in.
	else
		register = registerUser(sock, users)
		if( register == true )
			success = false
			userlock.synchronize {
				if( users[username] == nil )
					users[username] = User.new(username, password, false)
					success = true
				end
			}
			if( success )
				sock.puts("Successfully registered user.")
				return true
			else
				sock.puts("Failed to register user (already exists).")
				return false
			end
		else
			return false
		end
	end
end

# Returns true/false of whether the user would like to register a new account
def registerUser(sock, userlist)
	printState = sock.sync
	sock.sync = true
	done = false
	while( !done )
		sock.print("User does not exist. Register? [Y/N]: ")
		response = sock.gets.chomp.upcase
		if( response == "N" )
			sock.sync = printState
			return false
		elsif( response == "Y" )
			sock.sync = printState
			return true
		end
	end
end
