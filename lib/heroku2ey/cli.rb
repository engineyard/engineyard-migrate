require 'thor'
require 'net/http'
require 'uri'
require 'heroku2ey/engineyard/appcloud_env'

module Heroku2EY
  class CLI < Thor

    desc "migrate PATH", "Migrate this Heroku app to Engine Yard AppCloud"
    method_option :verbose, :aliases     => ["-V"], :desc => "Display more output"
    method_option :environment, :aliases => ["-e"], :desc => "Environment in which to deploy this application", :type => :string
    method_option :account, :aliases     => ["-c"], :desc => "Name of the account you want to deploy in"
    def migrate(path)
      environments = Heroku2EY::Engineyard::AppcloudEnv.new.find_environments(options)
      if environments.size == 0
        no_environments_discovered and return
      elsif environments.size > 1
        too_many_environments_discovered("migrate", environments) and return
      end
      
      env_name, account_name, environment = environments.first
      say [env_name, account_name, environment].inspect, :green
    end
    
    map "-v" => :version, "--version" => :version, "-h" => :help, "--help" => :help

    private
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
        say "  heroku2ey #{tasks} --environment "; say "'#{env_name}' ", :yellow; 
          say "--account "; say "'#{account_name}'", :yellow
      end
    end
    
  end
end
