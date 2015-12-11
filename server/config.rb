#!/usr/bin/env ruby

=begin
	This file contains global constants used to configure the server,
	such as pathnames and port numbers. It does *not* contain gameplay
	configuration, which is stored in the state directory.
=end

module Configuration
	Port = 1234
	StateDir = "state"
	LoginFile = StateDir + "/" + "login.csv"
end
