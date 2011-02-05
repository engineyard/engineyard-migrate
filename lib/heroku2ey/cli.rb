require 'thor'
require 'net/http'
require 'uri'
require 'POpen4'
require 'net/sftp'
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
          heroku_credentials = File.expand_path("~/.heroku/credentials")
          unless File.exists?(heroku_credentials)
            error "Please setup your local Heroku credentials first."
          end

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
          dna_json = ssh_appcloud "sudo cat /etc/chef/dna.json", :return_output => true
          dna      = JSON.parse(dna_json)
          dna_env  = dna["engineyard"]["environment"]
          
          # TODO - what if no application deployed yet?
          # bash: line 0: cd: /data/heroku2eysimpleapp/current: No such file or directory

          # TODO - to test for cron setup:
          # dna_env["cron"] - list of:
          # [0] {
          #      "minute" => "0",
          #        "name" => "rake cron",
          #     "command" => "cd /data/heroku2eysimpleapp/current && RAILS_ENV=production rake cron",
          #       "month" => "*",
          #        "hour" => "1",
          #         "day" => "*/1",
          #        "user" => "deploy",
          #     "weekday" => "*"
          # }
      
          db_stack_name = dna_env["db_stack_name"]
          say "Database type: "; say db_stack_name, :green
      
          connection = Fog::Compute.new(
            :provider              => 'AWS',
            :aws_access_key_id     => dna["aws_secret_id"],
            :aws_secret_access_key => dna["aws_secret_key"]
          )
          security_group = connection.security_groups.first
          # security_group.revoke_port_range(3000..6000)
          # security_group.authorize_port_range(3000..6000) # 3306 mysql; $PGPORT or 5432 for postgresql
          # Fog.wait_for do
          #   security_group.reload.ip_permissions.detect do |ip_permission|
          #     ip_permission['ipRanges'].first && ip_permission['ipRanges'].first['cidrIp'] == '0.0.0.0/0' &&
          #     ip_permission['ipProtocol'] == 'tcp' &&
          #     ip_permission['fromPort'] == 3000 &&
          #     ip_permission['toPort'] == 6000
          #   end
          # end
          
          say "Setting up Heroku credentials on AppCloud..."

          # setup ~/.heroku/credentials
          ssh_appcloud "mkdir -p .heroku; chmod 700 .heroku", :path => "~"
          home_path = ssh_appcloud "pwd", :path => "~", :return_output => true
          
          db_host = dna_env['instances'].first['public_hostname'] # which is DB instance?
          db_host_user = 'deploy'
          
          debug "Uploding Heroku credential file..."
          begin
            Net::SFTP.start(db_host, db_host_user) do |sftp|
               sftp.upload!(heroku_credentials, "#{home_path}/.heroku/credentials")
            end
          rescue Net::SFTP::StatusException => e
            error e.description + ": " + e.text
          end
          # add ssh keys to heroku
          
          ssh_appcloud "sudo gem install heroku taps"
          ssh_appcloud "git remote add heroku git@heroku.com:heroku2ey-simple-app.git 2> /dev/null"

          # This wasn't working from my [drnic's] home network; so moving to 
          # say "Fetching AppCloud database credentials..."; $stdout.flush
          # db_yml    = ssh_appcloud "cat /data/#{@appcloud_app_name}/shared/config/database.yml"
          # db_config = YAML::load(db_yml)[environment.framework_env]
          # db_host, db_user, db_pass, db_database = db_config["host"], db_config["username"], db_config["password"], db_config["database"]
          #       
          # # only tested on solo
          # db_host = dna_env["instances"].first["public_hostname"] if db_host == "localhost"
          # db_host = "50.17.248.148" # IPs might work better; if it worked at all
      
          say "Migrating data from Heroku '#{heroku_app_name}' to AppCloud '#{@appcloud_app_name}'..."
          env_vars = %w[RAILS_ENV RACK_ENV MERB_ENV].map {|var| "#{var}=#{environment.framework_env}" }.join(" ")
          ssh_appcloud "#{env_vars} heroku db:pull --confirm #{heroku_app_name}"

          say "Migration complete!", :green
        rescue Exception => e
          say "Migration failed", :red
          puts e.inspect
          puts e.backtrace
        ensure
          # security_group.revoke_port_range(3000..6000)
        end
        
        # or 
        
      end
    end
    
    map "-v" => :version, "--version" => :version, "-h" => :help, "--help" => :help

    private
    def ssh_appcloud(cmd, options = {})
      path  = options[:path] || "/data/#{@appcloud_app_name}/current/"
      flags = options[:flags] || "" # app master by default
      ssh_cmd = "ey ssh 'cd #{path}; #{cmd}' #{flags}"
      debug options[:return_output] ? "Capturing: " : "Running: "
      debug ssh_cmd, :yellow
      out = ""
      status =
        POpen4::popen4(ssh_cmd) do |stdout, stderr, stdin, pid|
          if options[:return_output]
            out += stdout.read.strip
          else
            out = stdout.read.strip
            say out unless out.empty?
          end
          err = stderr.read.strip
          say err unless err.empty?
        end
        
       puts "exitstatus : #{ status.exitstatus }" unless status.exitstatus == 0
       debug ""
       out if options[:return_output]
    end
    
    def say(msg, color = nil)
      color ? shell.say(msg, color) : shell.say(msg)
    end
    
    def debug(msg, color = nil)
      say(msg, color)
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
