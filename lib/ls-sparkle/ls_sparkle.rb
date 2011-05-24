"""This is where the artifacts get moved into their respected homes"""
require File.dirname(__FILE__) + '/shelve_utils'
#a=ShelveUtils.new
#a.need_to_create_code?("dir")
#a.check_shelves
#a.pickup_the_mess

module LsSparkle
  class Clean
    def initialize(args={})
      @fu=ShelveUtils.new
    end
    
    def disinfect
      @fu.check_shelves
      @fu.pickup_the_mess
    end

    def white_glove

    end
    def local_methods
      self.methods.sort - Object.methods
    end
  end
end

a=LsSparkle::Clean.new
a.disinfect
