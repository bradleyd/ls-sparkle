"""This is where the artifacts get moved into their respected homes"""
require File.dirname(__FILE__) + '/shelve_utils'


module LsSparkle
  class Clean
    def initialize(args={})
      @fu=ShelveUtils.new
    end
    
    def disinfect
      p @fu.check_shelves
    end

    def white_glove

    end
    def local_methods
      self.methods.sort - Object.methods
    end
  end
end


