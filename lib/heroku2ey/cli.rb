require 'thor'
require 'uri'
require 'net/http'
require 'net/sftp'
require 'POpen4'
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
            error "Not a Salesforce Heroku application."
          end
          heroku_repo =~ /git@heroku\.com:(.*)\.git/
          heroku_app_name = $1

          say "Requesting Heroku account information..."; $stdout.flush
          say "Heroku app:    "; say heroku_app_name, :green

          heroku_credentials = File.expand_path("~/.heroku/credentials")
          unless File.exists?(heroku_credentials)
            error "Please setup your Salesforce Heroku credentials first."
          end

          say `heroku info`
          say ""
          
          repo = `git config remote.origin.url`.strip
          if repo.empty?
            error "Please host your Git repo externally and add as remote 'origin'.", <<-SUGGESTION.gsub(/^\s{12}/, '')
            You can create a GitHub repository using 'github' gem:
              $ gem install github
              $ gh create-from-local --private
            SUGGESTION
          end
          unless EY::API.read_token
            error "Please create, boot and deploy an AppCloud application for #{repo}."
          end
          
          say "Requesting AppCloud account information..."; $stdout.flush
          app, environment = fetch_app_and_environment(options[:app], options[:environment], options[:account])

          unless app.repository_uri == repo
            error "Please create, boot and deploy an AppCloud application for #{repo}."
          end

          @appcloud_app_name = app.name
          app_master_host = environment.app_master.public_hostname
          app_master_user = environment.username

          say "AppCloud app:  "; say "#{app.name}", :green
          say "AppCloud acct: "; say "#{environment.account.name}", :yellow
          say "Environment:   "; say "#{environment.name}", :yellow
          say "RACK_ENV:      "; say "#{environment.framework_env}", :yellow
          say "Cluster size:  "; say "#{environment.instances_count}", :yellow
          say "Hostname:      "; say "#{app_master_host}", :yellow
          say ""
      
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
      
          say "Setting up Heroku credentials on AppCloud..."

          # setup ~/.heroku/credentials
          home_path = ssh_appcloud("pwd", :path => "~", :return_output => true)
          say "AppCloud $HOME: "; say home_path, :yellow
          ssh_appcloud "mkdir -p .heroku; chmod 700 .heroku", :path => home_path
          
          debug "Uploading Heroku credential file..."
          Net::SFTP.start(app_master_host, app_master_user) do |sftp|
            sftp.upload!(heroku_credentials, "#{home_path}/.heroku/credentials")
          end
          
          ssh_appcloud "sudo gem install heroku taps --no-ri --no-rdoc -q"
          ssh_appcloud "git remote add heroku git@heroku.com:heroku2ey-simple-app.git 2> /dev/null"

          say "Migrating data from Heroku '#{heroku_app_name}' to AppCloud '#{@appcloud_app_name}'..."
          env_vars = %w[RAILS_ENV RACK_ENV MERB_ENV].map {|var| "#{var}=#{environment.framework_env}" }.join(" ")
          ssh_appcloud "#{env_vars} heroku db:pull --confirm #{heroku_app_name}"

          say "Migration complete!", :green
        rescue SystemExit
        rescue Net::SSH::AuthenticationFailed => e
          error "Please setup your SSH credentials for AppCloud."
        rescue Net::SFTP::StatusException => e
          error e.description + ": " + e.text
        rescue Exception => e
          say "Migration failed", :red
          puts e.inspect
          puts e.backtrace
        end
      end
    end
    
    map "-v" => :version, "--version" => :version, "-h" => :help, "--help" => :help

    private
    def ssh_appcloud(cmd, options = {})
      path  = options[:path] || "/data/#{@appcloud_app_name}/current/"
      flags = " #{options[:flags]}" || "" if options[:flags] # app master by default
      ssh_cmd = "ey ssh 'cd #{path}; #{cmd}'#{flags}"
      debug options[:return_output] ? "Capturing: " : "Running: "
      debug ssh_cmd, :yellow; $stdout.flush
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

    def error(text, suggestion = nil)
      shell.say "ERROR: #{text}", :red
      if suggestion
        shell.say ""
        shell.say suggestion
      end
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
