When /^I visit the application at "([^"]*)"$/ do |host|
  Net::HTTP.start(host) do |http|
    req = http.get("/")
    @response_body = req.body
  end
end

Then /^I should see table$/ do |table|
  doc_table = tableish('table#people tr', 'td,th')
  doc_table.should == table.raw
end

Then /^port "([^"]*)" on "([^"]*)" should be closed$/ do |port, host|
  pending
end
