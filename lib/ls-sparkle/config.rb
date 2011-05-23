require'yaml'

module Config
  class Options
    attr_accessor :options, :config_file
    def initialize(args={})
      args.each { |key, value| send("#{key}=", value) if respond_to?(key) }
      #XXX could send in config file path on instansiation of class
      @file = File.dirname(__FILE__) + "/../../config/list.yml"
      @options = YAML.load_file(@file)
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
        
      #case meth.to_s
      #  when /^load_directories/
      #    @options['directories'].values
      #  when /^load_filetypes/
      #    @options['filetypes']
      #  else
      #    super
      # end
    end 
  end
end

a=Config::Options.new()
p a.load_directories
