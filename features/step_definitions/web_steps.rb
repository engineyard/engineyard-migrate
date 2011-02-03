When /^I visit the Heroku application$/ do
  Net::HTTP.start(@heroku_host) do |http|
    req = http.get("/")
    @response_body = req.body
  end
end

When /^I visit the AppCloud application$/ do
  pending
  Net::HTTP.start(@appcloud_host) do |http|
    req = http.get("/")
    @response_body = req.body
  end
end

Then /^I should see table$/ do |table|
  doc_table = tableish('table#people tr', 'td,th')
  doc_table.should == table.raw
end
