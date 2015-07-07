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

class User
	attr_reader :handle
	attr_reader :ID

	def initialize(handle, password)
		if( handle.class != String )
			raise TypeError, "Handle must be a string!"
		end
		if( password.class != String )
			raise TypeError, "Password must be a string!"
		end
		@handle = handle
		@password = password
		@ID = (Digest::SHA2.new << (handle + UserIDSalt)).to_s
	end

	# Note: Not cryptographically secure, this is vulnerable to timing attacks
	# and uses no cryptography for password storage. Don't really care for a
	# tiny game.
	def isCorrectPassword?(password)
		if( @password == password )
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
			@password = newpass
			return true
		else
			return false
		end
	end
end

def testAccountSystem
	u = User.new("neo", "ch0zen 0n3")
	puts "User #{u.handle} has id #{u.ID}"
end
