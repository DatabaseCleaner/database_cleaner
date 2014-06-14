Given /^I have setup database cleaner to clean multiple databases using redic$/ do
  #DatabaseCleaner
  # require "#{File.dirname(__FILE__)}/../../../lib/redis_models"
  #
  # DatabaseCleaner[:redic, {:connection => ENV['REDIS_URL_ONE']} ].strategy = :truncation
  # DatabaseCleaner[:redic, {:connection => ENV['REDIS_URL_TWO']} ].strategy = :truncation
end

When /^I create a widget using redic$/ do
  RedisWidget.create!
end

Then /^I should see ([\d]+) widget using redic$/ do |widget_count|
  RedisWidget.count.should == widget_count.to_i
end

When /^I create a widget in one db using redic$/ do
  RedisWidgetUsingDatabaseOne.create!
end

When /^I create a widget in another db using redic$/ do
  RedisWidgetUsingDatabaseTwo.create!
end

Then /^I should see ([\d]+) widget in one db using redic$/ do |widget_count|
  RedisWidgetUsingDatabaseOne.count.should == widget_count.to_i
end

Then /^I should see ([\d]+) widget in another db using redic$/ do |widget_count|
  RedisWidgetUsingDatabaseTwo.count.should == widget_count.to_i
end
