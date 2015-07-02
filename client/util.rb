#!/usr/bin/env ruby

require 'terminfo'

def getScreenDimensions
	return TermInfo.screen_size
end
