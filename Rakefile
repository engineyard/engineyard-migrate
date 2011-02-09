require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

desc "Run all examples"
RSpec::Core::RakeTask.new

namespace :cucumber do
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:wip, 'Run features that are being worked on') do |t|
    t.cucumber_opts = "--tags @wip"
  end
  Cucumber::Rake::Task.new(:ok, 'Run features that should be working') do |t|
    t.cucumber_opts = "--tags ~@wip"
  end
  task :all => [:ok, :wip]

  desc "Setup IdentityFile for SSH keys for running tests"
  task :ssh_config do
    puts "Installing SSH credentials for running integration tests..."
    config_file = File.expand_path("~#{ENV['USER']}/.ssh/config")
    identity_file = File.expand_path("../tmp/home/.ssh/id_rsa", __FILE__)
    if File.exist? config_file
      sh "ssh-config set ec2-50-17-248-148.compute-1.amazonaws.com IdentityFile #{identity_file}"
    else
      system "touch #{config_file}"
      sh "ssh-config set ec2-50-17-248-148.compute-1.amazonaws.com IdentityFile #{identity_file}"
    end
  end
end

desc 'Alias for cucumber:ok'
task :cucumber => ['cucumber:ssh_config', 'cucumber:ok']

desc "Start test server; Run cucumber:ok; Kill Test Server;"
task :default => ["spec", "cucumber"]

desc "Clean out cached git app repos"
task :clean_app_repos do
  repos_path = File.dirname(__FILE__) + "/fixtures/repos"
  FileUtils.rm_rf(repos_path)
  puts "Removed #{repos_path}..."
end

