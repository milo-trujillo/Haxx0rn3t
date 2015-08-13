#!/usr/bin/env ruby

=begin
	This class is basically a menu for launching different functions by user
	request. It takes an array of tuples of menu options to present and
	callbacks to the appropriate functions. For example, if created with:

		[["foo", proc{ foo }], ["bar", proc{ bar }], ["quit", proc{ logOut }]]

	then three menu items will be created: "foo", "bar", and "quit", which will
	launch the functions "foo", "bar", and "logOut", when accessed.
=end

require_relative('client')

class Menu
	ItemDelay = 0.2

	def initialize(menuName, list)
		if( list.class != Array )
			raise TypeError, "Menu expects a list of (name, callback)"
		end
		@name = menuName
		@list = list
	end

	def print(client)
		if( client.class != Client )
			raise TypeError, "Need a client to print menu data to!"
		end
		client.clearScreen
		client.puts((" " * ((client.width - @name.length) / 2)) + @name)
		client.puts("=" * client.width)
		client.puts("")
		for entry in @list
			sleep(ItemDelay)
			client.puts(" * " + entry[0])
			client.puts("")
		end
	end

	# Read one item from user then call that function if it exists
	def prompt(client)
		if( client.class != Client )
			raise TypeError, "Need a client to print menu data to!"
		end
		client.putsNow(" > ")
		choice = client.gets.chomp
		for entry in @list
			if( choice.downcase == entry[0].downcase )
				entry[1].call
				return
			end
		end
		client.puts(" -- Item not found -- ")
	end
end
