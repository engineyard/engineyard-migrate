require 'thor'
require 'net/http'
require 'uri'
require 'engineyard/thor'
require "engineyard/cli"
require "engineyard/cli/ui"
require "engineyard/error"

module Heroku2EY
  class CLI < Thor
    include EY::UtilityMethods

    desc "migrate PATH", "Migrate this Heroku app to Engine Yard AppCloud"
    method_option :verbose, :aliases     => ["-V"], :desc => "Display more output"
    method_option :environment, :aliases => ["-e"], :desc => "Environment in which to deploy this application", :type => :string
    method_option :account, :aliases     => ["-c"], :desc => "Name of the account you want to deploy in"
    def migrate(path)
      error "Path '#{path}' does not exist" unless File.exists? path
      FileUtils.chdir(path) do
        heroku_repo = `git config remote.heroku.url`.strip
        if heroku_repo.empty?
          error "'heroku2ey migrate #{path}' is for migrating heroku applications."
        end

        app, environment = fetch_app_and_environment(options[:app], options[:environment], options[:account])
        # [EY::Model::App, EY::Model::Environment]
        say "account:       "; say "#{environment.account.name}", :green
        say "environment:   "; say "#{environment.name}", :green
        say "framework_env: "; say "#{environment.framework_env}", :green
        say "cluster size:  "; say "#{environment.instances_count}", :green
        say "application:   "; say "#{app.name}", :yellow

        @appcloud_app_name = app.name
        
        ssh_appcloud "git remote add heroku #{heroku_repo} 2> /dev/null"
        
      end
      
      
      # Do the following on the AppCloud instance:
      # connection = Fog::Compute.new(
      #   :provider => 'AWS',
      #   :aws_access_key_id => XXX,
      #   :aws_secret_access_key => YYY,
      # )
      # 
      # # fill this in based on the name of the group, should be based on the environment name if I remember right
      # security_group = connection.security_groups.get(SECURITY_GROUP_NAME)
      # 
      # security_group.authorize_port_range(5000..5000) # 3306 mysql; $PGPORT or 5432 for postgresql
      # 
      # heroku db:pull mysql://root:pass@myapplicationip/database
      # 
      # security_group.revoke_port_range(5000..5000)
      
      # To run commands:
      
      # ey ssh "echo `pwd`" --db-master
      
      say "Migration complete!", :green
    end
    
    map "-v" => :version, "--version" => :version, "-h" => :help, "--help" => :help

    private
    def ssh_appcloud(cmd, options = {})
      path  = options[:path] || "/data/#{@appcloud_app_name}/current"
      flags = options[:flags] || "--db-master"
      system "ey ssh 'cd #{path}; #{cmd}' #{flags}"
    end
    
    def say(msg, color = nil)
      color ? shell.say(msg, color) : shell.say(msg)
    end

    def display(text)
      shell.say text
      exit
    end

    def error(text)
      shell.say "ERROR: #{text}", :red
      exit
    end

    def no_environments_discovered
      say "No AppCloud environments found for this application.", :red
      say "Either:"
      say "  * Create an AppCloud environment for this application/git URL"
      say "  * Use --environment/--account flags to select an AppCloud environment"
    end
    
    def too_many_environments_discovered(task, environments)
      say "Multiple environments possible, please be more specific:", :red
      say ""
      environments.each do |env_name, account_name, environment|
        say "  heroku2ey #{task} --environment "; say "'#{env_name}' ", :yellow; 
          say "--account "; say "'#{account_name}'", :yellow
      end
    end
    
  end
end
