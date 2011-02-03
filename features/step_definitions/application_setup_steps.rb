Given /^I have setup my Heroku credentials$/ do
  # create a credential file in ENV['HOME']/.heroku/
end

Given /^I have a Heroku application "([^"]*)"$/ do |name|
  @heroku_name = name
end

Given /^it has "([^"]*)" production data$/ do |data_source|
  @data_source = data_source
end

Given /^the source is hosted at "([^"]*)"$/ do |git_uri|
  @git_uri = git_uri
end

Given /^I have setup my AppCloud credentials$/ do
  # create a credential file in ENV['HOME']/.eyrc
end

Given /^I have an AppCloud account "([^"]*)" with environment "([^"]*)"$/ do |account, environment|
  @appcloud_account, @appcloud_environment = account, environment
end

