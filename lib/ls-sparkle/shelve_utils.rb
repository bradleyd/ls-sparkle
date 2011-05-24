require File.dirname(__FILE__) + '/error'
require File.dirname(__FILE__) + '/config'
require File.dirname(__FILE__) + '/log'
require 'fileutils'

  #XXX needs a sanity check to make sure directories exist before 
  class ShelveUtils < CleaningError 
    attr_accessor :home, :config, :verbose
    def initialize(args={})
      args.each { |key, value| send("#{key}=", value) if respond_to?(key) }
      @config=Config::Options.new
      @log=Log.new
      @home = ENV['HOME']
    end

    def local_methods
      self.methods.sort - Object.methods
    end
     
    def empty_shelves
       #XXX delete the contents in the shelves(directories)
       @config.load_directories.values.each do |directory|
         begin
           #rm directory if direcotry.exist?
         rescue CleaningError => e
           @log.write('error', "Connection ERROR: #{e}")
         end
       end
    end
 
    def create_shelves(path)
      begin
        FileUtils.mkdir_p path 
        @log.write('info', "Create directory(s): #{path}")
      rescue CleaningError => e
        puts "Error: #{e}"
        @log.write('error', "Connection ERROR: #{e}")
      end
    end

    def check_shelves 
      no = []
      @config.load_directories.values.each do |directory|
        if directory == 'Code'
          no.concat need_to_create_code? 
        else
          no << join(directory) if !need_to_create?(directory) 
        end 
      end
      #create shelves if need be
      self.create_shelves no unless no.empty?
    end

    def need_to_create?(dir)
      self.exist? File.join(@home, dir)
    end
   
    def need_to_create_code?
      no = []
      @config.load_filetypes['code'].keys.each do |type|
        if !self.exist? self.locate_directory(join("/Code/#{type}"))
          no << self.locate_directory(join("/Code/#{type}")) 
        end
      end
      return no
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
        FileUtils.cp(src, temp, :verbose => false) if FileTest.directory? temp
      rescue CleaningError => e
        puts "Error: #{e}"
        @log.write('error', "Connection ERROR: #{e}")
      end
    end
    #XXX Refactor: accept non nested entries in yaml config  
    def pickup_the_mess
       @config.load_filetypes.each do |key, value|
         value.each do |k,v|
           Dir.glob("#{@home}/#{v}").each do |file|
             #puts "FILE: #{file}.....MOVE: #{build_base_path(key)}"
             #XXX if file is code, need to add code dir to end of build path
             if key == 'code'
               self.put_away file, "#{build_base_path(key)}/#{k}"
               @log.write('info', "Cleaned up file(s): #{file} to #{build_base_path(key)}/#{k}")
             else
               self.put_away file, build_base_path(key)
               @log.write('info', "Cleaned up file(s): #{file} to #{build_base_path(key)}/#{k}")
             end
           end  
         end
       end
    end
end


#a=ShelveUtils.new
#a.need_to_create_code?("dir")
#a.check_shelves
#a.pickup_the_mess
