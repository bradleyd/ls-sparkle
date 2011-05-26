require 'helper'
require '../lib/ls-sparkle/config'
require '../lib/ls-sparkle/shelve_utils'

class TestLsSparkle < Test::Unit::TestCase
  def setup 
    @home = ENV['HOME']
    @config = Config::Options.new
    @shelve = ShelveUtils.new
  end

  def test_config
    #({:log_file => 'ls_sparkle.log', :log_level => 'info', :name => 'ls_sparkle'}, Config::Options.new.load_log)
     assert_instance_of(Hash, @config.load_log)
  end

  def test_need_to_create
     assert_equal(true, @shelve.need_to_create?('Videos'))
  end
  
  def test_build_base_path
    dir = 'Archives'
    assert_equal("#{@home}/#{dir}", @shelve.build_base_path(dir))
  end

  def test_exist
    path = '/tmp'
    assert_equal(true, @shelve.exist?(path))
  end


end
