require 'ls-sparkle/lssparkle'
require 'ls-sparkle/shelve_utils'
require 'ls-sparkle/config'

#a=Config::Options.new()
#p a.load_directories
a=LsSparkle::Clean.new
a.disinfect
