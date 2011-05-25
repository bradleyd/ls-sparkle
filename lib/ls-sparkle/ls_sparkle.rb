require 'ls-sparkle/shelve_utils'

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
    
    def start
      self.disinfect      
    end

    def local_methods
      self.methods.sort - Object.methods
    end
  end
end

