Given /^I have setup my SSH keys$/ do
  in_home_folder do
    FileUtils.cp_r(File.join(@fixtures_path, "credentials/ssh"), ".ssh")
    FileUtils.chmod(0700, ".ssh")
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
end

Given /^it has "([^"]*)" production data$/ do |data_source|
  @data_source = data_source
end

Given /^I clone the application "([^"]*)" as "([^"]*)"$/ do |git_uri, app_name|
  @git_uri  = git_uri
  @app_name = app_name
  @stdout = File.expand_path(File.join(@tmp_root, "git.out"))
  @stderr = File.expand_path(File.join(@tmp_root, "git.err"))
  in_home_folder do
    system "git clone #{git_uri} #{app_name} > #{@stdout.inspect} 2> #{@stderr.inspect}"
  end
end

Given /^I have setup my AppCloud credentials$/ do
  in_home_folder do
    FileUtils.cp_r(File.join(@fixtures_path, "credentials/eyrc"), ".eyrc")
    FileUtils.chmod(0700, ".eyrc")
  end
end

Given /^I have an AppCloud account "([^"]*)" with environment "([^"]*)"$/ do |account, environment|
  @appcloud_account, @appcloud_environment = account, environment
end

