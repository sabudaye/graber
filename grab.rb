require 'imggrabber'

Imggrabber.grab(url: ARGV[0], path: ARGV[1], adapter: 'typhoeus')