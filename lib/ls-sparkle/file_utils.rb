require File.dirname(__FILE__) + '/error'
require File.dirname(__FILE__) + '/config'
require 'fileutils'

  #XXX needs a sanity check to make sure directories exist before 
  class StorageArea < StandardError 
    attr_accessor :home, :config
    def initialize(agrs={})
      @config=Config::Options.new
      @home = ENV['HOME']
    end
     
    def empty_shelves
       #XXX delete the contents in the shelves(directories)
       @config.load_directories.values.each do |directory|
         begin
           #rm directory if direcotry.exist?
         rescue CleaningError => e
           p e
         end
       end
    end
    def create_shelves
       needs = self.check_shelves
       needs.each do |need|
         p need
       end
    end

    def check_shelves 
      no = []
      @config.load_directories.values.each do |directory|
        if directory == 'Code'
          #Dir["#{build_base_path(directory)}/*/"].each do |dir|
            #p :dir => dir
            no.concat need_to_create_code? 
           #end
        else
          no << join(directory) if !need_to_create?(directory) 
        end 
      end
      return no
    end
    def need_to_create?(dir)
      FileTest.directory? File.join(@home, dir)
    end
    def build_base_path(dir)
      File.join(@home, @config.load_directories[dir.downcase])
    end
    
    def exist?(path)
       FileTest.directory? path
    end
   
    def join(path)
      File.join(@home, path)
    end
    
    def need_to_create_code?
        no = []
        @config.load_filetypes['code'].keys.each do |type|
          no << self.locate_directory(join("/Code/#{type}")) if !FileTest.directory? self.locate_directory(join("/Code/#{type}"))
        end 
        return no
    end
    #XXX this looks for the dir no matter case--nedds refactoring 
    def locate_directory(path)
      dir=File.basename(path)
      base=File.dirname(path)
      if FileTest.directory? "#{base}/#{dir.downcase}"
        result="#{base}/#{dir.downcase}"
      elsif FileTest.directory? "#{base}/#{dir.upcase}"
        result="#{base}/#{dir.upcase}"
      #this is for rehat, ubuntu based Pcitures, Videos, etc..
      elsif FileTest.directory? "#{base}/#{dir.split(/(\W)/).map(&:capitalize).join}"
        result="#{base}/#{dir.split(/(\W)/).map(&:capitalize).join}"
      else
        result=path
      end
    end 

    def put_away(src, dest)
      begin
        temp=locate_directory(dest)
        FileUtils.cp(src, temp, :verbose => true) if FileTest.directory? temp
      rescue CleaningError => e
        puts "Error: #{e}"
      end
    end
    #the config file must have a nested entry or this will fail
    # foo:
    #   bar: hello world
    #XXX Refactor: accept non nested entries in yaml config  
    def pickup_the_mess
       @config.load_filetypes.each do |key, value|
         #p key
         value.each do |k,v|
           Dir.glob("#{@home}/#{v}").each do |file|
             puts "FILE: #{file}.....MOVE: #{build_base_path(key)}"
             #XXX if file is code, need to add code dir to end of build path
             if key == 'code'
               self.put_away file, "#{build_base_path(key)}/#{k}"
             else
               self.put_away file, build_base_path(key)
             end
           end  
         end
       end
    end
end


a=StorageArea.new
#a.need_to_create_code?("dir")
a.check_shelves
a.pickup_the_mess
