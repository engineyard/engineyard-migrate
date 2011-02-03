$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../lib'))
require 'bundler/setup'

[$stdout, $stderr].each { |pipe| pipe.sync = true }

Before do
  @tmp_root      = File.dirname(__FILE__) + "/../../tmp"
  @active_project_folder = @tmp_root
  @home_path     = File.expand_path(File.join(@tmp_root, "home"))
  @lib_path      = File.expand_path(File.dirname(__FILE__) + "/../../lib")
  @fixtures_path = File.expand_path(File.dirname(__FILE__) + "/../../fixtures")
  @mock_world_path = File.expand_path(File.dirname(__FILE__) + "/../../fixtures/mock_world")
  
  @repos_path = File.expand_path(File.dirname(__FILE__) + "/../../fixtures/repos")
  FileUtils.mkdir_p @repos_path
  
  FileUtils.rm_rf   @tmp_root
  FileUtils.mkdir_p @home_path
  ENV['HOME'] = @home_path
end
