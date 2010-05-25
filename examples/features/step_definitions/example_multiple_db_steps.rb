Given /^I have setup databasecleaner to clean multiple dbs$/ do
  DatabaseCleaner
end

When /^I create a widget in one db$/ do
  Widget.establish_connection_one
  Widget.create!
end

When /^I create a widget in another db$/ do
  Widget.establish_connection_two
  Widget.create!
end

Then /^I should see ([\d]+) widget in one db$/ do |widget_count|
  Widget.establish_connection_one
  Widget.count.should == widget_count.to_i
end

Then /^I should see ([\d]+) widget in another db$/ do |widget_count|
  Widget.establish_connection_two
  Widget.count.should == widget_count.to_i
end