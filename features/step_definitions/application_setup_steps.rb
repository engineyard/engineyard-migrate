Given /^I have setup my SSH keys$/ do
  in_home_folder do
    FileUtils.cp_r(File.join(@fixtures_path, "credentials/ssh"), ".ssh")
    FileUtils.chmod(0700, ".ssh")
  end
end

Given /^I clone the application "([^"]*)" as "([^"]*)"$/ do |git_uri, app_name|
  @git_uri  = git_uri
  @app_name = app_name
  repo_folder = File.expand_path(File.join(@repos_path, app_name))
  unless File.exists?(repo_folder)
    @stdout = File.expand_path(File.join(@tmp_root, "git.out"))
    @stderr = File.expand_path(File.join(@tmp_root, "git.err"))
    FileUtils.chdir(@repos_path) do
      system "git clone #{git_uri} #{app_name} > #{@stdout.inspect} 2> #{@stderr.inspect}"
    end
  end
  in_home_folder do
    FileUtils.rm_rf(app_name)
    FileUtils.cp_r(repo_folder, app_name)
  end
  @active_project_folder = File.join(@home_path, app_name)
  @project_name = app_name
  @stdout = File.expand_path(File.join(@tmp_root, "bundle.out"))
  @stderr = File.expand_path(File.join(@tmp_root, "bundle.err"))
  in_project_folder do
    system "bundle > #{@stdout.inspect} 2> #{@stderr.inspect}"
  end
end

Given /^I have setup my Heroku credentials$/ do
  in_home_folder do
    FileUtils.cp_r(File.join(@fixtures_path, "credentials/heroku"), ".heroku")
    FileUtils.chmod(0700, ".heroku")
  end
end
# note, when setting up the heroku credentials for the first time:
# set the new $HOME
# cd $HOME
# mkdir .ssh
# chmod 700 .ssh
# heroku list # will go through process of setting up and creating ssh keys


Given /^I have a Heroku application "([^"]*)"$/ do |name|
  @heroku_name = name
  @heroku_host = "#{name}.heroku.com"
  in_project_folder do
    system "git remote rm heroku 2> /dev/null"
    system "git remote add heroku git@heroku.com:#{name}.git"
  end
end

Given /^it has production data$/ do
  unless @production_data_installed
    in_project_folder do
      # TODO - currently hard coded into fixtures/data/APPNAME.sqlite3 as the commented code below isn't working
      
      `rm -f db/development.sqlite3`
      `bundle exec rake db:schema:load`
      cmds = ['Dr Nic', 'Danish'].map do |name|
        "Person.create(:name => '#{name}')"
      end.join("; ")
      `bundle exec rails runner "#{cmds}"`
      
      data_file = File.expand_path(File.join(@fixtures_path, "data", "#{@app_name}.sqlite3"))
      raise "Missing production data for '#{@app_name}' at #{data_file}; run 'rake db:seed' in fixtures/repos/#{app_name}" unless File.exists?(data_file)
      FileUtils.cp_r(data_file, "db/development.sqlite3")
      @stdout = File.expand_path(File.join(@tmp_root, "heroku.out"))
      @stderr = File.expand_path(File.join(@tmp_root, "heroku.err"))
      system "heroku db:push --confirm #{@heroku_name} > #{@stdout.inspect} 2> #{@stderr.inspect}"
      @production_data_installed = true
    end
  end
end

Given /^I have setup my AppCloud credentials$/ do
  in_home_folder do
    FileUtils.cp_r(File.join(@fixtures_path, "credentials/eyrc"), ".eyrc")
    FileUtils.chmod(0700, ".eyrc")
  end
end

Given /^I reset the AppCloud "([^"]*)" application "([^"]*)" database$/ do |environment, app_name|
  in_project_folder do
    @stdout = File.expand_path(File.join(@tmp_root, "eyssh.out"))
    @stderr = File.expand_path(File.join(@tmp_root, "eyssh.err"))
    system "ey ssh 'cd /data/#{app_name}/current/; RAILS_ENV=production rake db:schema:load' -e #{environment} > #{@stdout.inspect} 2> #{@stderr.inspect}"
  end
end

# Actually moves it to .../current.bak; which is restored after the scenario
Given /^I remove AppCloud "([^"]*)" application "([^"]*)" folder$/ do |environment, app_name|
  in_project_folder do
    remove_from_appcloud("/data/#{app_name}/current", environment)
  end
end


