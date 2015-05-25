require_relative 'graber'

raise "URL is not defined" if ARGV[0].nil?

graber = Graber.new
graber.grab(ARGV[0], ARGV[1])