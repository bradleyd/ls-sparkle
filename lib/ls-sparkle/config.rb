#the config file must have a nested entry or this will fail
# foo:
#   bar: hello world
# you can call load_"config file key" to get hash of values.
# For example, Config::Options.new.load_log  will yield a hash from the config file with 'log' values .
# Another way to retrieve the values is to chain methods.  FOr example,
# a=Config::Options.new
# a.log
# will return the same results

require'yaml'

module Config
  class Options
    attr_accessor :options, :config_file 
    def initialize(args={})
      args.each { |key, value| send("#{key}=", value) if respond_to?(key) } unless args.empty?
      #XXX could send in config file path on instansiation of class
      @file = File.dirname(__FILE__) + "/../../config/options.yml"
      @options = YAML.load_file(@file)
      @options.each do |k,v|
      self.class.class_eval do 
        define_method k.to_sym do
          self.instance_variable_set("@#{k}",v)
        end
      end
      end
    end 
    
    def get_values
      @options = YAML.load_file(@file)
    end
     #XXX needs refactoring
    def method_missing(method, *args, &block)
      if method.to_s.include?('_')
        type = method.to_s.split('_').last 
        @options[type] 
      else
        super
      end
    end 
  end
end

#a=Config::Options.new
#p a.methods.sort
#p a.smtp

