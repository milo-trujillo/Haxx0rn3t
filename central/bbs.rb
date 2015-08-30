#!/usr/bin/env ruby

=begin
	This module is in charge of the central bulletin board system, which hosts
	both new missions and news posts about world events.

	Each post is an object containing a 'title', 'type', and 'body'.
=end

require 'thread'

require_relative 'config'

# This is a bare-bones class representing a news posting
class Post
	attr_accessor :title
	attr_accessor :type
	attr_accessor :body
	def initialize(title, body)
		@title = title
		@type = "news"
		@body = body
	end
end

module BBS
	$postlock = Mutex.new
	$posts = Array.new

	def BBS.menu(client)
		m = Menu.new("Bulletin Board System",
			[["List", proc{ BBS.printTitles(client) }],
			["Read", proc{ BBS.readMessage(client) }],
			["Exit", proc{ return }]])
		while( true )
			m.print(client)
			m.prompt(client)
		end
	end

	def BBS.readMessage(client)
		client.putsNow("Message number (blank to abort): ")
		msg = client.gets
		msg.gsub(/[^\d]/, "") # Leave only digits, ban negative numbers
		if( msg.length == 0 )
			return
		end
		msg = msg.to_i
		title = nil
		body = nil
		$postlock.synchronize {
			if( msg < $posts.length )
				title = $posts[msg].title
				body = $posts[msg].body
			end
		}
		if( title == nil || body == nil )
			client.puts("Error: Message does not exist!")
		else
			client.puts("")
			client.puts("Message title: " + title)
			client.puts("")
			client.puts(body)
			client.puts("")
		end
		client.puts(Configuration::ContinuePrompt)
		foo = client.gets
		return
	end

	def BBS.printTitles(client)
		# We make a copy of the entries from the array beforehand so we
		# don't have to hold a lock while printing to the user.
		titles = Array.new
		$postlock.synchronize {
			for post in $posts
				titles.push(post.title)
			end
		}
		for x in ( 0 .. titles.length - 1 ).to_a.reverse # For loops can't do --
			sleep(0.1)
			title = titles[x]
			space = client.width - (6 + title.length)
			# If the user's terminal is too small they have to deal
			if( space < 1 )
				space = 1
			end
			formatstr = "   %3d" + (" "*space) + title + "\n"
			client.out.printf(formatstr, x)
		end
		client.puts(Configuration::ContinuePrompt)
		foo = client.gets
	end

	def BBS.testFill(size)
		$postlock.synchronize {
			for x in (0 .. size)
				$posts.push(Post.new("Test post " + x.to_s, "This is a test"))
			end
		}
	end
end
