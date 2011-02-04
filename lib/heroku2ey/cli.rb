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
        begin
          heroku_repo = `git config remote.heroku.url`.strip
          if heroku_repo.empty?
            error "'heroku2ey migrate #{path}' is for migrating heroku applications."
          end
          heroku_repo =~ /git@heroku\.com:(.*)\.git/
          heroku_app_name = $1
          say "heroku app:    "; say heroku_app_name, :green
          say ""

          say "Requesting AppCloud account information..."; $stdout.flush
          app, environment = fetch_app_and_environment(options[:app], options[:environment], options[:account])
          @appcloud_app_name = app.name
          say "account:       "; say "#{environment.account.name}", :green
          say "environment:   "; say "#{environment.name}", :green
          say "framework_env: "; say "#{environment.framework_env}", :green
          say "cluster size:  "; say "#{environment.instances_count}", :green
          say "application:   "; say "#{app.name}", :yellow
          say ""
      
          require "json"
          require "yaml"
          require "fog"
          require "ap"

          say "Fetching AppCloud credentials..."; $stdout.flush
          dna_json    = ssh_appcloud "sudo cat /etc/chef/dna.json"
          dna         = JSON.parse(dna_json)
          dna_env = dna["engineyard"]["environment"]
      
          db_stack_name = dna_env["db_stack_name"]
          say "Database type: "; say db_stack_name, :green
      
          connection = Fog::Compute.new(
            :provider              => 'AWS',
            :aws_access_key_id     => dna["aws_secret_id"],
            :aws_secret_access_key => dna["aws_secret_key"]
          )
          ap security_group = connection.security_groups.last
          # security_group = connection.security_groups.get(SECURITY_GROUP_NAME)
          security_group.revoke_port_range(3000..6000)
          p security_group.authorize_port_range(3000..6000) # 3306 mysql; $PGPORT or 5432 for postgresql

          connection = Fog::Compute.new(
            :provider              => 'AWS',
            :aws_access_key_id     => dna["aws_secret_id"],
            :aws_secret_access_key => dna["aws_secret_key"]
          )
          ap security_group = connection.security_groups.last
      
          say "Fetching AppCloud database credentials..."; $stdout.flush
          db_yml    = ssh_appcloud "cat database.yml", :path => "/data/#{@appcloud_app_name}/shared/config/"
          db_config = YAML::load(db_yml)[environment.framework_env]
          db_host, db_user, db_pass, db_database = db_config["host"], db_config["username"], db_config["password"], db_config["database"]
      
          # only tested on solo
          db_host = dna_env["instances"].first["public_hostname"] if db_host == "localhost"
      
      
          say "Migrating data from Heroku '#{heroku_app_name}' to AppCloud '#{@appcloud_app_name}'..."
          system "heroku db:pull mysql://#{db_user}:#{db_pass}@#{db_host}/#{db_database} --confirm #{heroku_app_name}"

          # TODO - always do this
      
          say "Migration complete!", :green
        rescue Exception => e
          say "Migration failed", :error
          puts e.backtrace
        ensure
          security_group.revoke_port_range(3000..6000)
        end
      end
    end
    
    map "-v" => :version, "--version" => :version, "-h" => :help, "--help" => :help

    private
    def ssh_appcloud(cmd, options = {})
      path  = options[:path] || "/data/#{@appcloud_app_name}/current"
      flags = options[:flags] || "--db-master"
      `ey ssh 'cd #{path}; #{cmd}' #{flags}`
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
