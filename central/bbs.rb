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

	def BBS.printTitles(client)
		# We make a copy of the entries from the array beforehand so we
		# don't have to hold a lock while printing to the user.
		titles = Array.new
		$postlock.synchronize {
			for post in $posts
				titles.push(post.title)
			end
		}
		for x in (0 .. titles.length - 1)
			title = titles[x]
			space = client.width - (6 + title.length)
			# If the user's terminal is too small they have to deal
			if( space < 1 )
				space = 1
			end
			formatstr = "   %03d" + (" "*space) + title + "\n"
			client.out.printf(formatstr, x)
		end
		client.puts("- Press Return to Exit -")
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
